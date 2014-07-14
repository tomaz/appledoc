//
//  GBSourceInfo.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBSourceInfo.h"

@interface GBSourceInfo ()

@property (readwrite, copy) NSString *fullpath;
@property (readwrite, copy) NSString *filename;
@property (readwrite, assign) NSUInteger lineNumber;

@end

#pragma mark -

@implementation GBSourceInfo

#pragma mark Initialization & disposal

+ (id)infoWithFilename:(NSString *)filename lineNumber:(NSUInteger)lineNumber {
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);
	GBSourceInfo *result = [[GBSourceInfo alloc] init];
	result.fullpath = [filename stringByStandardizingPath];
	result.filename = [filename lastPathComponent];
	result.lineNumber = lineNumber;
	return result;
}

#pragma mark Helper methods

- (NSComparisonResult)compare:(GBSourceInfo *)data {
	NSComparisonResult result = [self.filename compare:data.filename];
	if (result == NSOrderedSame) {
		if (data.lineNumber > self.lineNumber) return NSOrderedAscending;
		if (data.lineNumber < self.lineNumber) return NSOrderedDescending;
	}
	return result;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"%@@%lu", self.filename, self.lineNumber];
}

#pragma mark Properties

@synthesize fullpath;
@synthesize filename;
@synthesize lineNumber;

@end
