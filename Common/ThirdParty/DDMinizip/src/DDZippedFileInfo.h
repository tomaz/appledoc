//
//  DDZippedFileInfo.h
//  DDMinizip
//
//  Created by Dominik Pich on 07.06.12.
//  Copyright (c) 2012 medicus42. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "unzip.h"
#include  "zip.h"

typedef enum {
	DDZippedFileInfoCompressionLevelDefault= -1,
	DDZippedFileInfoCompressionLevelNone= 0,
	DDZippedFileInfoCompressionLevelFastest= 1,
	DDZippedFileInfoCompressionLevelBest= 9
} DDZippedFileInfoCompressionLevel;	

@interface DDZippedFileInfo : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) DDZippedFileInfoCompressionLevel level;
@property (nonatomic, readonly) BOOL crypted;
@property (nonatomic, readonly) NSUInteger zippedSize;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSUInteger crc32;

- (id) initWithName:(NSString*)aName andNativeInfo:(unz_file_info)info;

/**
 * get NSDate object with date specified by a tm_unz date structure
 * @param mu_date the minzip's unzips C structure
 * @return the NSDate object
 */
+(NSDate*) dateWithMUDate:(tm_unz)mu_date;
+(tm_zip) mzDateWithDate:(NSDate*)date;
+(NSDate*) dateWithTimeIntervalSince1980:(NSTimeInterval)interval;

@end
