//
//  MethodGroupInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "MethodGroupInfo.h"

@implementation MethodGroupInfo

@synthesize nameOfMethodGroup = _nameOfMethodGroup;
@synthesize methodGroupMethods = _methodGroupMethods;

+ (id)MethodGroupInfoWithName:(NSString *)name {
	MethodGroupInfo *result = [[self alloc] init];
	result.nameOfMethodGroup = name;
	return result;
}

- (NSMutableArray *)methodGroupMethods {
	if (_methodGroupMethods) return _methodGroupMethods;
	LogIntDebug(@"Initializing methods array due to first access...");
	_methodGroupMethods = [[NSMutableArray alloc] init];
	return _methodGroupMethods;
}

@end

#pragma mark - 

@implementation NSArray (MethodGroupInfoExtensions)

- (BOOL)gb_containsMethodGroupInfoWithName:(NSString *)name {
	return [self gb_containsObjectWithValue:name forSelector:@selector(nameOfMethodGroup)];
}

- (NSUInteger)gb_indexOfMethodGroupInfoWithName:(NSString *)name {
	return [self gb_indexOfObjectWithValue:name forSelector:@selector(nameOfMethodGroup)];
}

@end
