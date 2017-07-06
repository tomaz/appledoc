#About
this project providers a wrapper around libz for iOS5 and OSX.

Based on code from acsolu@gmail.com for iOS I expanded and modified it to work as a 'drop-in' static library for OSX 10.7 and IOS 5. You have to link against libzib dylib still.

I split the code into a Writer and a Reader, added a proper Delegate that gets asked about what to extract and and made the original framework compile as a separate lib and use ARC. 

#example usage
there is a simple CLI tool included, that shows the usage of DDZipWriter and DDZipReader.

apart from that, below you find info on how to use the classes in your app as well as info on the available unzip delegate that enables you to determine what files to extract

##zip
	DDZipWriter *w = [[DDZipWriter alloc] init];
	[w newZipFile:@"testfile.zip"];
	for(NSString *file in files) {
	    BOOL res = [w addFileToZip:file newname:[NSString stringWithFormat:@"modified_%@", file]];
    
	    if(res) {
	        NSString *n = [file lastPathComponent];
	        NSLog(@"added file to zip: %@", n);
	    }       
	}
	[w closeZipFile];

##unzip
	DDZipReader *z = [[DDZipReader alloc] init];
	z.delegate = self;
	for(NSString *zip in zips) {
	    [z openZipFile:zip];
	    BOOL res = [z unzipFileTo:path flattenStructure:NO];
	    [z closeZipFile];

	    if(res) {
	        NSString *n = [zip lastPathComponent];
	        NSLog(@"Extracted zip file: %@", n);
	    }       
	}
	...
	- (BOOL)zipArchive:(DDZipReader *)zip shouldExtractFile:(NSString *)file {
	    return ([file rangeOfString:@"__MACOSX"].location==NSNotFound);
	}

	- (BOOL)zipArchive:(DDZipReader *)zip shouldOverwriteFile:(NSString *)file {
	    id fileDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil] fileModificationDate];
	    id fileInfoDate = fileInfo.date;

	    return ([fileDate compare:fileInfoDate]==NSOrderedAscending);
	}

#DDMinizip is available under the original libz license