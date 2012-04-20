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

+ (id)handleCachedFile:(NSString *)file block:(void(^)(NSString *path, id *contents))handler {
	if (!GBCachedFiles) GBCachedFiles = [NSMutableDictionary dictionary];
	id result = [GBCachedFiles objectForKey:file];
	if (result) return result;
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *filename = [file stringByDeletingPathExtension];
	NSString *extension = [file pathExtension];
	NSString *path = [bundle pathForResource:filename ofType:extension];
	handler(path, &result);
	if (result) [GBCachedFiles setObject:result forKey:file];
	return result;
}

+ (NSDictionary *)dictionaryFromResourceFile:(NSString *)file {
	return [self handleCachedFile:file block:^(NSString *path, id *contents) {
		*contents = [NSDictionary dictionaryWithContentsOfFile:path];
	}];
}

+ (NSString *)stringFromResourceFile:(NSString *)file {
	return [self handleCachedFile:file block:^(NSString *path, id *contents) {
		*contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	}];
}

@end
