//
//  ObjectLinkData.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectLinkData.h"

@implementation ObjectLinkData

+ (id)objectLinkDataWithName:(NSString *)name {
	ObjectLinkData *result = [[self alloc] init];
	result.nameOfObject = name;
	return result;
}

@end

#pragma mark - 

@implementation NSArray (ObjectLinkDataExtensions)

- (BOOL)gb_containsObjectLinkDataWithName:(NSString *)name {
	return [self gb_containsObjectWithValue:name forSelector:@selector(nameOfObject)];
}

- (NSUInteger)gb_indexOfObjectLinkDataWithName:(NSString *)name {
	return [self gb_indexOfObjectWithValue:name forSelector:@selector(nameOfObject)];
}

@end