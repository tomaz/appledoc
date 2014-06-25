//
//  DDZipReader.mm
//  updated 2011, Dominik Pich
//

#import "DDZipReader.h"
#import "zlib.h"
#import "zconf.h"

@implementation DDZipReader

@synthesize delegate = _delegate;

-(id) init
{
	if( (self=[super init]) != nil )
	{
		_unzFile = NULL;
	}
	return self;
}

-(void) dealloc
{
	[self closeZipFile];
    [super dealloc];
}

#pragma mark - unzipping 

-(BOOL)openZipFile:(NSString *)zipFile
{
	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile )
	{
		unz_global_info  globalInfo = {0};
		unzGetGlobalInfo(_unzFile, &globalInfo );
		/*if( ==UNZ_OK )
		{
			//Log(@"%d entries in the zip file",globalInfo.number_entry);
		}
		 */
	}
	return _unzFile!=NULL;
}

-(NSInteger) unzipFileTo:(NSString *)path flattenStructure:(BOOL)flatten
{
    NSInteger cFiles = 0;
	BOOL success = YES;
	int ret = unzGoToFirstFile( _unzFile );
	unsigned char		buffer[4096] = {0};
	NSFileManager* fman = [NSFileManager defaultManager];
	if( ret!=UNZ_OK )
	{
		[self outputErrorMessage:@"Failed"];
	}
	
	do{
		ret = unzOpenCurrentFile( _unzFile );
		if( ret!=UNZ_OK )
		{
			[self outputErrorMessage:@"Error occurs"];
			success = NO;
			break;
		}
		// reading data and write to file
		int read ;
		unz_file_info	fileInfo ={0};
		ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
		if( ret!=UNZ_OK )
		{
			[self outputErrorMessage:@"Error occurs while getting file info"];
			success = NO;
			unzCloseCurrentFile( _unzFile );
			break;
		}
		char* filename = (char*) malloc( fileInfo.size_filename +1 );
		unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
		filename[fileInfo.size_filename] = '\0';

		//get zipped path
		NSString * strPath = [NSString  stringWithUTF8String:filename];
		BOOL isDirectory = NO;
		if(flatten) {
			strPath = [strPath lastPathComponent];
		}
		else {
			if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\') {
				isDirectory = YES;
            }
		}
		free( filename );
        
        //convert to /
		if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound ) {
			strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		}
        
        //ask delegate if he wants to proceed
        if( ![self shouldExtractFile:strPath] )
        {
            unzCloseCurrentFile( _unzFile );
            ret = unzGoToNextFile( _unzFile );
            continue;
        }

        //get full target path 
		NSString* fullPath = [path stringByAppendingPathComponent:strPath];
		
        //create target dir
		if( isDirectory )
			[fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
		else
			[fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        
        //test
        DDZippedFileInfo *info = [[DDZippedFileInfo alloc] initWithName:strPath andNativeInfo:fileInfo];
        NSLog(@"%@", info.date);
        
              //ask delegate for overwrite
		if( [fman fileExistsAtPath:fullPath] && !isDirectory )
		{
			if( ![self shouldOverwrite:fullPath withName:strPath andFileInfo:fileInfo] )
			{
				unzCloseCurrentFile( _unzFile );
				ret = unzGoToNextFile( _unzFile );
				continue;
			}
		}
        
        //write file
		FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
		while( fp )
		{
			read=unzReadCurrentFile(_unzFile, buffer, 4096);
			if( read > 0 )
			{
				fwrite(buffer, read, 1, fp );
			}
			else if( read<0 )
			{
				[self outputErrorMessage:@"Failed to reading zip file"];
				break;
			}
			else 
				break;				
		}
		if( fp )
		{
			fclose( fp );
			// set the orignal datetime property
			if( fileInfo.dosDate!=0 )
			{
				NSDate* orgDate = [DDZippedFileInfo dateWithMUDate:fileInfo.tmu_date];

				NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
				if( attr )
				{
				//	[attr  setValue:orgDate forKey:NSFileCreationDate];
					if( ![[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPath error:nil] )
					{
						// cann't set attributes 
						//Log(@"Failed to set attributes");
					}
					
				}
//				[orgDate release];
				orgDate = nil;
			}
            
            cFiles++;
			
		}
		unzCloseCurrentFile( _unzFile );
		ret = unzGoToNextFile( _unzFile );
	}while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
	return success ? cFiles : -1;
}

-(BOOL) closeZipFile
{
	if( _unzFile ) {
        BOOL br = unzClose( _unzFile )==UNZ_OK;
        _unzFile = NULL;
		return br;
    }
	return YES;
}

#pragma mark wrapper for delegate

- (BOOL)shouldExtractFile:(NSString*)file {
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:shouldExtractFile:)] )
		return [_delegate zipArchive:self shouldExtractFile:file];
	return YES;
}

-(void) outputErrorMessage:(NSString*) msg
{
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:errorMessage:)] )
		[_delegate zipArchive:self errorMessage:msg];
}

-(BOOL) shouldOverwrite:(NSString*)file withName:(NSString*)name andFileInfo:(unz_file_info)fileInfo
{
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:shouldOverwriteFile:withZippedFile:)] ) {
        DDZippedFileInfo *info = [[DDZippedFileInfo alloc] initWithName:name andNativeInfo:fileInfo];    
		return [_delegate zipArchive:self shouldOverwriteFile:file withZippedFile:info];
    }
	return NO;
}

@end
