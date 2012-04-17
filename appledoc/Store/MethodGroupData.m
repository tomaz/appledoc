//
//  MethodGroupData.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "MethodGroupData.h"

@implementation MethodGroupData

@synthesize nameOfMethodGroup = _nameOfMethodGroup;
@synthesize methodGroupMethods = _methodGroupMethods;

+ (id)methodGroupDataWithName:(NSString *)name {
	MethodGroupData *result = [[self alloc] init];
	result.nameOfMethodGroup = name;
	return result;
}

- (NSMutableArray *)methodGroupMethods {
	if (_methodGroupMethods) return _methodGroupMethods;
	LogStoDebug(@"Initializing methods array due to first access...");
	_methodGroupMethods = [[NSMutableArray alloc] init];
	return _methodGroupMethods;
}

@end

#pragma mark - 

@implementation NSArray (MethodGroupDataExtensions)

- (BOOL)gb_containsMethodGroupDataWithName:(NSString *)name {
	return [self gb_containsObjectWithValue:name forSelector:@selector(nameOfMethodGroup)];
}

- (NSUInteger)gb_indexOfMethodGroupDataWithName:(NSString *)name {
	return [self gb_indexOfObjectWithValue:name forSelector:@selector(nameOfMethodGroup)];
}

@end
