//
//  DDEmbeddedDataReader.h
//  cocoa-interpreter
//
//  Created by Dominik Pich on 7/15/12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file DDEmbeddedDataReader.h */

/**
 * Based on code from BVPlistExtractor by Bavarious, this class allows easy reading of embedded (linked in) data from any executable. (e.g. a CLI Tool's plist included using the linker flag `-sectcreate __TEXT __info_plist TestInfo.plist`)
 */
@interface DDEmbeddedDataReader : NSObject

//"?", "?"

/**
 * returns the embbedded data for the executable at |url| from a specific section in a specific segment.
 * Segment is %SPECIFIED%
 * Section is %SPECIFIED%
 * @param segment a segment with the |section| to get data from
 * @param section a section to get data from
 * @param url url that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (NSData*)dataFromSegment:(NSString*)segment inSection:(NSString*)section ofExecutableAtURL:(NSURL*)url error:(NSError**)error;

/**
 * returns the embbedded data for the executable at |path| from a specific section in a specific segment.
 * Segment is %SPECIFIED%
 * Section is %SPECIFIED%
 * @param segment a segment with the |section| to get data from
 * @param section a section to get data from
 * @param path the POSIX file path that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (NSData*)dataFromSegment:(NSString*)segment inSection:(NSString*)section ofExecutableAtPath:(NSString*)path error:(NSError**)error;

/**
 * returns the embbedded data for the CURRENT executable from a specific section in a specific segment.
 * Segment is %SPECIFIED%
 * Section is %SPECIFIED%
 * @param segment a segment with the |section| to get data from
 * @param section a section to get data from
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (NSData*)embeddedDataFromSegment:(NSString*)segment inSection:(NSString*)section error:(NSError**)error;

//"__TEXT", "?"

/**
 * returns the embbedded data for the executable at |url| from a specific section in the __TEXT segment.
 * Segment is '__TEXT'
 * Section is %SPECIFIED%
 * @param section a section to get data from
 * @param url url that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (NSData*)dataFromSection:(NSString*)section ofExecutableAtURL:(NSURL*)url error:(NSError**)error;

/**
 * returns the embbedded data for the executable at |path| from a specific section in the __TEXT segment.
 * Segment is '__TEXT'
 * Section is %SPECIFIED%
 * @param section a section to get data from
 * @param path the POSIX file path that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (NSData*)dataFromSection:(NSString*)section ofExecutableAtPath:(NSString*)path error:(NSError**)error;

/**
 * returns the embbedded data for the CURRENT executable from a specific section in the __TEXT segment.
 * Segment is '__TEXT'
 * Section is %SPECIFIED%
 * @param section a section to get data from
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return NSData for anything (zip, txt, png data) or nil
 */
+ (NSData*)embeddedDataFromSection:(NSString*)section error:(NSError**)error;

//
//"__TEXT", "__info_plist"
//

/**
 * returns the embbedded plist for the executable at 'path' from where apple embeds it by default (for Commandline apps that should be codesigned. @see https://developer.apple.com/library/mac/#documentation/security/Conceptual/CodeSigningGuide/Procedures/Procedures.html) )
 * Segment is '__TEXT'
 * Section is '__info_plist'
 * @param url an url that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (id)defaultPlistOfExecutableAtURL:(NSURL*)url error:(NSError**)error;

/**
 * returns the CURRENT's executables embbedded plist from where apple embeds it embeds it by default (for Commandline apps that should be codesigned. @see https://developer.apple.com/library/mac/#documentation/security/Conceptual/CodeSigningGuide/Procedures/Procedures.html) )
 * Segment is '__TEXT'
 * Section is '__info_plist'
 * @param path the POSIX file path that points to a mach executable
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (id)defaultPlistOfExecutableAtPath:(NSString*)path error:(NSError**)error;

/**
 * returns the CURRENT's executables embbedded plist from where apple embeds it by default (for Commandline apps that should be codesigned. @see https://developer.apple.com/library/mac/#documentation/security/Conceptual/CodeSigningGuide/Procedures/Procedures.html) )
 * Segment is '__TEXT'
 * Section is '__info_plist'
 * @param error if a parsing error occurs and nil is returned, this is the NSError that occured
 * @return a NSDictionary or nil
 */
+ (id)defaultEmbeddedPlist:(NSError**)error;
@end
