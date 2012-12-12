//
//  DDEmbeddedDataReader.m
//  cocoa-interpreter
//
//  Created by Dominik Pich on 7/15/12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//  Based on BVPlistExtractor by Bavarious
//

#import "DDEmbeddedDataReader.h"

#include <mach-o/dyld.h>	/* _NSGetExecutablePath */
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>
#include <mach/machine.h>
#include <sys/mman.h>
#include <sys/stat.h>

#pragma mark - Declaration of private functions
static NSData *_BVMachOSection(NSURL *url, char *segname, char *sectname, NSError **error);
static NSData *_BVMachOSectionFromMachOHeader(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error);
static NSData *_BVMachOSectionFromMachOHeader32(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error);
static NSData *_BVMachOSectionFromMachOHeader64(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error);

#pragma mark - Declaration of private functions for error reporting
static NSError *_BVPOSIXError(NSURL *url);
static NSError *_BVGenericError(NSURL *url, NSString *fileQualifier, NSInteger errorCode);
static NSError *_BVEmptyFileError(NSURL *url);
static NSError *_BVCorruptMachOError(NSURL *url);

#pragma mark - Definition of constants for error reporting
NSString * const BVPlistExtractorErrorDomain = @"com.bavarious.PlistExtractor.ErrorDomain";
const NSInteger BVPlistExtractorErrorOpenFile = 1;
const NSInteger BVPlistExtractorErrorEmptyFile = 2;
const NSInteger BVPlistExtractorErrorCorruptMachO = 3;

#pragma mark - Definition of private functions
NSData *_BVMachOSection(NSURL *url, char *segname, char *sectname, NSError **error) {
    NSData *data = nil;
    int fd;
    struct stat stat_buf;
    long size, bytes_left;
    
    char *addr = NULL;
    char *start_addr = NULL;
    
    // Open the file and get its size
    fd = open([[url path] UTF8String], O_RDONLY);
    if (fd == -1) {
        if (error) *error = _BVPOSIXError(url);
        goto END_FUNCTION;
    }
    
    if (fstat(fd, &stat_buf) == -1) {
        if (error) *error = _BVPOSIXError(url);
        goto END_FILE;
    }
    
    size = stat_buf.st_size;
    
    if (size == 0) {
        if (error) *error = _BVEmptyFileError(url);
        goto END_FILE;
    }
    
    bytes_left = size;
    
    // Map the file to memory
    addr = start_addr = mmap(0, size, PROT_READ, MAP_FILE | MAP_PRIVATE, fd, 0);
    if (addr == MAP_FAILED) {
        if (error) *error = _BVPOSIXError(url);
        goto END_FILE;
    }
    
    // Check if it's a fat file
    //   Make sure the file is long enough to hold a fat_header
    if (size < sizeof(struct fat_header)) goto END_MMAP;
    struct fat_header *fh = (struct fat_header *)addr;
    uint32_t magic = NSSwapBigIntToHost(FAT_MAGIC);
    
    // It's a fat file
    if (fh->magic == magic) {
        int nfat_arch = NSSwapBigIntToHost(fh->nfat_arch);
        
        bytes_left -= sizeof(struct fat_header);
        addr += sizeof(struct fat_header);
        
        if (bytes_left < (nfat_arch * sizeof(struct fat_arch))) {
            if (error) *error = _BVCorruptMachOError(url);
            goto END_MMAP;
        }
        
        // Read the architectures
        for (int ifat_arch = 0; ifat_arch < nfat_arch; ifat_arch++) {
            struct fat_arch *fa = (struct fat_arch *)addr;
            int offset = NSSwapBigIntToHost(fa->offset);
            addr += sizeof(struct fat_arch);
            
            if (bytes_left < offset) {
                if (error) *error = _BVCorruptMachOError(url);
                goto END_MMAP;
            }
            
            data = _BVMachOSectionFromMachOHeader(start_addr + offset, bytes_left, segname, sectname, url, error);
            if (data) break;
        }
    }
    // It's a thin file
    else {
        data = _BVMachOSectionFromMachOHeader(start_addr, bytes_left,segname, sectname, url, error);
    }
    
END_MMAP:
    munmap(addr, size);
    
END_FILE:
    close(fd);
    
END_FUNCTION:
    return data;
}

NSData *_BVMachOSectionFromMachOHeader(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error) {
    NSData *data = nil;
    struct mach_header *mh;
    
    if (bytes_left < sizeof(struct mach_header)) {
        if (error) *error = _BVCorruptMachOError(url);
        return nil;
    }
    
    // The first bytes are the Mach-O header
    mh = (struct mach_header *)addr;
    
    if (mh->magic == MH_MAGIC) { // 32-bit
        data = _BVMachOSectionFromMachOHeader32(addr, bytes_left, segname, sectname, url, error);
    }
    else if (mh->magic == MH_MAGIC_64) { // 64-bit
        data = _BVMachOSectionFromMachOHeader64(addr, bytes_left, segname, sectname, url, error);
    }
    
    return data;
}

#pragma mark - Definition of private functions for error reporting
NSError *_BVPOSIXError(NSURL *url) {
    NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                          code:errno
                                                      userInfo:nil];
    NSString *errorDescription = [NSString stringWithFormat:@"File %@ could not be opened. %s.",
                                  [url path], strerror(errno)];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorDescription, NSLocalizedDescriptionKey,
                              underlyingError, NSUnderlyingErrorKey,
                              [url path], NSFilePathErrorKey,
                              nil];
    NSError *error = [[NSError alloc] initWithDomain:BVPlistExtractorErrorDomain
                                                code:BVPlistExtractorErrorOpenFile
                                            userInfo:userInfo];
    
    return error;
}

NSError *_BVGenericError(NSURL *url, NSString *fileQualifier, NSInteger errorCode) {
    NSString *errorDescription = [NSString stringWithFormat:@"File %@ is %@.", [url path], fileQualifier];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorDescription, NSLocalizedDescriptionKey,
                              [url path], NSFilePathErrorKey,
                              nil];
    NSError *error = [[NSError alloc] initWithDomain:BVPlistExtractorErrorDomain
                                                code:errorCode
                                            userInfo:userInfo];
    
    return error;
}

NSError *_BVEmptyFileError(NSURL *url) {
    return _BVGenericError(url, @"empty", BVPlistExtractorErrorEmptyFile);
}

NSError *_BVCorruptMachOError(NSURL *url) {
    return _BVGenericError(url, @"corrupt", BVPlistExtractorErrorCorruptMachO);
}

#pragma mark - Instantiation of private template functions
NSData *_BVMachOSectionFromMachOHeader32(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error) {
    NSData *data = nil;
    char *base_macho_header_addr = addr;
    struct mach_header *mh = NULL;
    struct load_command *lc = NULL;
    struct segment_command *sc = NULL;
    struct section *sect = NULL;
    
    long bytes_left_from_macho_header = bytes_left;
    
    if (bytes_left < sizeof(struct mach_header)) {
        if (error) *error = _BVCorruptMachOError(url);
        goto END_FUNCTION;
    }
    
    mh = (struct mach_header *)addr;
    addr += sizeof(struct mach_header);
    bytes_left -= sizeof(struct mach_header);
    
    for (int icmd = 0; icmd < mh->ncmds; icmd++) {
        if (bytes_left < 0) {
            if (error) *error = _BVCorruptMachOError(url);
            goto END_FUNCTION;
        }
        
        lc = (struct load_command *)addr;
        
        if (lc->cmdsize == 0) continue;
        bytes_left -= lc->cmdsize;
        if (bytes_left < 0)  {
            if (error) *error = _BVCorruptMachOError(url);
            goto END_FUNCTION;
        }
        
        if (lc->cmd != LC_SEGMENT) {
            addr += lc->cmdsize;
            continue;
        }
        
        // It's a segment
        sc = (struct segment_command *)addr;
        
        if (strcmp(segname, sc->segname) != 0 || sc->nsects == 0) {
            addr += lc->cmdsize;
            continue;
        }
        
        // It's the segment we want and it has at least one section
        // Section data follows segment data
        addr += sizeof(struct segment_command);
        
        for (int isect = 0; isect < sc->nsects; isect++) {
            bytes_left -= sizeof(struct section);
            if (bytes_left < 0) goto END_FUNCTION;
            
            sect = (struct section *)addr;
            addr += sizeof(struct section);
            
            if (strcmp(sectname, sect->sectname) != 0) continue;
            
            // It's the section we want
            if (bytes_left_from_macho_header < (sect->offset + sect->size)) {
                if (error) *error = _BVCorruptMachOError(url);
                goto END_FUNCTION;
            }
            data = [NSData dataWithBytes:(base_macho_header_addr + sect->offset) length:sect->size];
            goto END_FUNCTION;
        }
    }
    
END_FUNCTION:
    return data;
}

NSData *_BVMachOSectionFromMachOHeader64(char *addr, long bytes_left, char *segname, char *sectname, NSURL *url, NSError **error) {
    NSData *data = nil;
    char *base_macho_header_addr = addr;
    struct mach_header_64 *mh = NULL;
    struct load_command *lc = NULL;
    struct segment_command_64 *sc = NULL;
    struct section_64 *sect = NULL;
    
    long bytes_left_from_macho_header = bytes_left;
    
    if (bytes_left < sizeof(struct mach_header_64)) {
        if (error) *error = _BVCorruptMachOError(url);
        goto END_FUNCTION;
    }
    
    mh = (struct mach_header_64 *)addr;
    addr += sizeof(struct mach_header_64);
    bytes_left -= sizeof(struct mach_header_64);
    
    for (int icmd = 0; icmd < mh->ncmds; icmd++) {
        if (bytes_left < 0) {
            if (error) *error = _BVCorruptMachOError(url);
            goto END_FUNCTION;
        }
        
        lc = (struct load_command *)addr;
        
        if (lc->cmdsize == 0) continue;
        bytes_left -= lc->cmdsize;
        if (bytes_left < 0)  {
            if (error) *error = _BVCorruptMachOError(url);
            goto END_FUNCTION;
        }
        
        if (lc->cmd != LC_SEGMENT_64) {
//            printf("\nskip command %d", lc->cmd);
            addr += lc->cmdsize;
            continue;
        }
        
        // It's a segment
        sc = (struct segment_command_64 *)addr;
        
        if (strcmp(segname, sc->segname) != 0 || sc->nsects == 0) {
//            printf("\nskip segment name %s", sc->segname);
            addr += lc->cmdsize;
            continue;
        }
        
        // It's the segment we want and it has at least one section
        // Section data follows segment data
        addr += sizeof(struct segment_command_64);
        
        for (int isect = 0; isect < sc->nsects; isect++) {
            bytes_left -= sizeof(struct section_64);
            if (bytes_left < 0) goto END_FUNCTION;
            
            sect = (struct section_64 *)addr;
            addr += sizeof(struct section_64);
            
            if (strcmp(sectname, sect->sectname) != 0) {
//                printf("\nskip section name %s", sect->sectname);
                continue;
            }
            
            // It's the section we want
            if (bytes_left_from_macho_header < (sect->offset + sect->size)) {
                if (error) *error = _BVCorruptMachOError(url);
                goto END_FUNCTION;
            }
            data = [NSData dataWithBytes:(base_macho_header_addr + sect->offset) length:sect->size];
            goto END_FUNCTION;
        }
    }
    
END_FUNCTION:
    return data;
}

#pragma mark - Definition of public class

@implementation DDEmbeddedDataReader

+ (NSData*)dataFromSegment:(NSString*)segment inSection:(NSString*)section ofExecutableAtURL:(NSURL*)url error:(NSError**)error {
    return _BVMachOSection(url, (char*)[segment UTF8String], (char*)[section UTF8String], error);
}

+ (NSData*)dataFromSegment:(NSString*)segment inSection:(NSString*)section ofExecutableAtPath:(NSString*)path error:(NSError**)error {
    return [self dataFromSegment:segment inSection:section ofExecutableAtURL:[NSURL fileURLWithPath:path] error:error];
}

+ (NSData *)embeddedDataFromSegment:(NSString *)segment inSection:(NSString *)section error:(NSError *__autoreleasing *)error {
    uint32_t size = MAXPATHLEN*2;
    char ch[size];
    if(_NSGetExecutablePath(ch, &size)!=0) {
        return nil;
    }
    NSString *s = [NSString stringWithUTF8String:ch];
    return [self dataFromSegment:segment inSection:section ofExecutableAtPath:s error:error];
}

#pragma mark -

+ (NSData*)dataFromSection:(NSString*)section ofExecutableAtURL:(NSURL*)url error:(NSError**)error {
    return _BVMachOSection(url, "__TEXT", (char*)[section UTF8String], error);
}

+ (NSData*)dataFromSection:(NSString*)section ofExecutableAtPath:(NSString*)path error:(NSError**)error {
    return [self dataFromSection:section ofExecutableAtURL:[NSURL fileURLWithPath:path] error:error];
}

+ (NSData *)embeddedDataFromSection:(NSString *)section error:(NSError *__autoreleasing *)error {
    uint32_t size = MAXPATHLEN*2;
    char ch[size];
    if(_NSGetExecutablePath(ch, &size)!=0) {
        return nil;
    }
    NSString *s = [NSString stringWithUTF8String:ch];
    return [self dataFromSection:section ofExecutableAtPath:s error:error];
}
#pragma mark -

+ (id)defaultPlistOfExecutableAtURL:(NSURL*)url error:(NSError**)error {
    id plist = nil;
    NSData *data = _BVMachOSection(url, "__TEXT", "__info_plist", error);
    if (data) {
        plist = [NSPropertyListSerialization propertyListWithData:data
                                                          options:NSPropertyListImmutable
                                                           format:NULL
                                                            error:error];
        
    }
    return plist;
}

+ (id)defaultPlistOfExecutableAtPath:(NSString*)path error:(NSError**)error {
    return [self defaultPlistOfExecutableAtURL:[NSURL fileURLWithPath:path] error:error];
}

+ (id)defaultEmbeddedPlist:(NSError**)error {
    uint32_t size = MAXPATHLEN*2;
    char ch[size];
    if(_NSGetExecutablePath(ch, &size)!=0) {
        return nil;
    }
    NSString *s = [NSString stringWithUTF8String:ch];
    return [self defaultPlistOfExecutableAtPath:s error:error];
}

@end

