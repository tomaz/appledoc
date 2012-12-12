//
//  DDZippedFileInfo.m
//  DDMinizip
//
//  Created by Dominik Pich on 07.06.12.
//  Copyright (c) 2012 medicus42. All rights reserved.
//

#import "DDZippedFileInfo.h"

@implementation DDZippedFileInfo	

@synthesize name;
@synthesize size;
@synthesize level;
@synthesize crypted;
@synthesize zippedSize;
@synthesize date;
@synthesize crc32;

- (id) initWithName:(NSString*)aName andNativeInfo:(unz_file_info)info {
    self=[super init];
    if(self) {
        name = [aName copy];
        size = info.uncompressed_size;
        
        level = DDZippedFileInfoCompressionLevelNone;
        if (info.compression_method != 0) {
            switch ((info.flag & 0x6) / 2) {
                case 0:
                    level = DDZippedFileInfoCompressionLevelDefault;
                    break;
                    
                case 1:
                    level = DDZippedFileInfoCompressionLevelBest;
                    break;
                    
                default:
                    level = DDZippedFileInfoCompressionLevelFastest;
                    break;
            }
        }
        
        crypted = ((info.flag & 1) != 0);
        zippedSize = info.compressed_size;
        date = [[self class] dateWithMUDate:info.tmu_date];
        crc32 = info.crc;
    }
    return self;
}


#pragma mark get NSDate object for zip

+(NSDate*) dateWithMUDate:(tm_unz)mu_date
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setSecond:mu_date.tm_sec];
    [comps setMinute:mu_date.tm_min];
    [comps setHour:mu_date.tm_hour];
	[comps setDay:mu_date.tm_mday];
	[comps setMonth:mu_date.tm_mon];
    [comps setYear:mu_date.tm_year];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	return date;
}

+(tm_zip) mzDateWithDate:(NSDate*)date
{
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    tm_zip mu_date;
    mu_date.tm_sec = (uInt)comps.second;
    mu_date.tm_min = (uInt)comps.minute;
    mu_date.tm_hour = (uInt)comps.hour;
    mu_date.tm_mday = (uInt)comps.day;
    mu_date.tm_mon = (uInt)comps.month;
    mu_date.tm_year = (uInt)comps.year;
        
	return mu_date;
}

#pragma mark get NSDate object based off of 1980-01-01

+(NSDate*) dateWithTimeIntervalSince1980:(NSTimeInterval)interval
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:1];
	[comps setMonth:1];
	[comps setYear:1980];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = [gregorian dateFromComponents:comps];
	
    //	[comps release];
    //	[gregorian release];
	return [date dateByAddingTimeInterval:interval];
}

@end