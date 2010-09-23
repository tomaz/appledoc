//
//  GBDeclaredFileData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDeclaredFileData.h"

@interface GBDeclaredFileData ()

@property (readwrite, copy) NSString *filename;
@property (readwrite, assign) NSUInteger lineNumber;

@end

#pragma mark -

@implementation GBDeclaredFileData

#pragma mark Initialization & disposal

+ (id)fileDataWithFilename:(NSString *)filename lineNumber:(NSUInteger)lineNumber {
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);
	GBDeclaredFileData *result = [[[GBDeclaredFileData alloc] init] autorelease];
	result.filename = filename;
	result.lineNumber = lineNumber;
	return result;
}

#pragma mark Helper methods

- (NSComparisonResult)compare:(GBDeclaredFileData *)data {
	NSComparisonResult result = [self.filename compare:data.filename];
	if (result == NSOrderedSame) {
		if (data.lineNumber > self.lineNumber) return NSOrderedAscending;
		if (data.lineNumber < self.lineNumber) return NSOrderedDescending;
	}
	return result;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"%@{ %@ @%ld }", [self className], self.filename, self.lineNumber];
}

#pragma mark Properties

@synthesize filename;
@synthesize lineNumber;

@end
