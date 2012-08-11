//
//  ObjectLinkInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectLinkInfo.h"

@implementation ObjectLinkInfo

+ (id)ObjectLinkInfoWithName:(NSString *)name {
	ObjectLinkInfo *result = [[self alloc] init];
	result.nameOfObject = name;
	return result;
}

@end

#pragma mark - 

@implementation NSArray (ObjectLinkInfoExtensions)

- (BOOL)gb_containsObjectLinkInfoWithName:(NSString *)name {
	return [self gb_containsObjectWithValue:name forSelector:@selector(nameOfObject)];
}

- (NSUInteger)gb_indexOfObjectLinkInfoWithName:(NSString *)name {
	return [self gb_indexOfObjectWithValue:name forSelector:@selector(nameOfObject)];
}

@end