//
//  DDZipWriter.mm
//  updated 2011, Dominik Pich
//

#import "DDZipWriter.h"
#import "zlib.h"
#import "zconf.h"
#import "DDZippedFileInfo.h"

@implementation DDZipWriter

-(instancetype) init
{
    if( (self = [super init]) != nil )
    {
        _zipFile = NULL;
    }
    return self;
}

-(void) dealloc
{
    [self closeZipFile];
}

#pragma mark - zipping

-(BOOL) newZipFile:(NSString *)zipFile
{
    _zipFile = zipOpen( (const char*)zipFile.UTF8String, 0 );
    return _zipFile != NULL;
}

-(BOOL) addFileToZip:(NSString *)file newname:(NSString *)newname
{
    if( !_zipFile )
        return NO;
    time_t current;
    time( &current );
    
    zip_fileinfo zipInfo = {0,0,0};
    zipInfo.dos_date = (unsigned long) current;
    
    if(!newname)
        newname = file;
    
    NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
    if( attr )
    {
        NSDate* fileDate = (NSDate*)attr[NSFileModificationDate];
        if( fileDate )
        {
            zipInfo.dos_date = [fileDate timeIntervalSinceDate:[DDZippedFileInfo dateWithTimeIntervalSince1980:0]];
        }
    }
    
    int ret = zipOpenNewFileInZip( _zipFile,
                                  (const char*) newname.UTF8String,
                                  &zipInfo,
                                  NULL,0,
                                  NULL,0,
                                  NULL,//comment
                                  Z_DEFLATED,
                                  Z_DEFAULT_COMPRESSION );
    if( ret!=Z_OK )
    {
        return NO;
    }
    NSData* data = [NSData dataWithContentsOfFile:file];
    NSUInteger dataLen = data.length;
    ret = zipWriteInFileInZip( _zipFile, (const void*)data.bytes, (unsigned int)dataLen);
    if( ret!=Z_OK )
    {
        return NO;
    }
    ret = zipCloseFileInZip( _zipFile );
    return ret == Z_OK;
}

-(BOOL) closeZipFile
{
    if( _zipFile == NULL )
        return NO;
    BOOL ret = zipClose( _zipFile, NULL ) == Z_OK;
    _zipFile = NULL;
    return ret;
}


@end
