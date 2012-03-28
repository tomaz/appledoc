//
//  TestStrings.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "TestStrings.h"

static NSMutableDictionary *GBCachedFiles = nil;

@implementation TestStrings

+ (NSDictionary *)dataFromFile:(NSString *)file {
	if (!GBCachedFiles) GBCachedFiles = [NSMutableDictionary dictionary];
	NSDictionary *result = [GBCachedFiles objectForKey:file];
	if (result) return result;
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:file ofType:@"plist"];
	result = [NSDictionary dictionaryWithContentsOfFile:path];
	if (result) [GBCachedFiles setObject:result forKey:file];
	return result;
}

+ (NSString *)stringFromFile:(NSString *)file key:(NSString *)key {
	NSDictionary *data = [self dataFromFile:file];
	return [data objectForKey:key];
}

@end
