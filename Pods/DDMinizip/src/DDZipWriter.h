//
//  DDZipWriter.h
//  updated 2011, Dominik Pich
//

#import <Foundation/Foundation.h>
#include "zip.h"

@interface DDZipWriter : NSObject {
@private
	zipFile		_zipFile;
}

-(BOOL) newZipFile:(NSString*) zipFile;
-(BOOL) addFileToZip:(NSString*) file
             newname:(NSString*) newname;
-(BOOL) closeZipFile;

@end
