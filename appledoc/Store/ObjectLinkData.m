//
//  ObjectLinkData.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectLinkData.h"

@implementation ObjectLinkData

@synthesize nameOfObject;
@synthesize linkToObject;

+ (id)objectLinkDataWithName:(NSString *)name {
	ObjectLinkData *result = [[self alloc] init];
	result.nameOfObject = name;
	return result;
}

@end

#pragma mark - 

@implementation NSArray (ObjectLinkDataExtensions)

- (BOOL)gb_containsObjectLinkDataWithName:(NSString *)name {
	NSUInteger index = [self gb_indexOfObjectLinkDataWithName:name];
	return (index != NSNotFound);
}

- (NSUInteger)gb_indexOfObjectLinkDataWithName:(NSString *)name {
	__block NSUInteger result = NSNotFound;
	[self enumerateObjectsUsingBlock:^(ObjectLinkData *data, NSUInteger idx, BOOL *stop) {
		if ([data.nameOfObject isEqual:name]) {
			result = idx;
			*stop = YES;
		}
	}];
	return result;
}

@end