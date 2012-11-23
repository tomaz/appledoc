//
//  ParserTask.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ParserTask.h"

@interface ParserTask ()
@property (nonatomic, strong, readwrite) Store *store;
@property (nonatomic, strong, readwrite) GBSettings *settings;
@property (nonatomic, strong, readwrite) NSString *filename;
@end

#pragma mark - 

@implementation ParserTask

#pragma mark - Running the task

- (NSInteger)parseFile:(NSString *)filename withSettings:(GBSettings *)settings store:(Store *)store {
	LogDebug(@"Parsing '%@'...", filename);
	NSError *error = nil;
	NSString *standardized = [filename gb_stringByStandardizingCurrentDirAndPath];
	NSString *string = [NSString stringWithContentsOfFile:standardized encoding:NSUTF8StringEncoding error:&error];
	if (!string) {
		LogNSError(error, @"Failed reading contents of '%@'!", filename);
		return GBResultSystemError;
	}
	self.filename = standardized;
	self.settings = settings;
	self.store = store;
	return [self parseString:string];
}

@end
