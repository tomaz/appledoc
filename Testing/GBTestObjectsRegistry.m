//
//  GBTestObjectsRegistry.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBDataObjects.h"
#import "GBTestObjectsRegistry.h"

@implementation GBTestObjectsRegistry

#pragma mark Common objects creation methods

+ (OCMockObject *)mockSettingsProvider {
	return [OCMockObject niceMockForProtocol:@protocol(GBApplicationSettingsProviding)];
}

#pragma mark GBIvarData creation methods

+ (GBIvarData *)ivarWithComponents:(NSString *)first, ... {
	va_list args;
	va_start(args, first);
	NSMutableArray *components = [NSMutableArray array];
	for (NSString *argument=first; argument!=nil; argument=va_arg(args, NSString*)) {
		[components addObject:argument];
	}
	va_end(args);
	return [GBIvarData ivarDataWithComponents:components];
}

#pragma mark GBMethodData creation methods

+ (GBMethodData *)instanceMethodWithArguments:(GBMethodArgument *)first,... {
	va_list args;
	va_start(args, first);
	NSMutableArray *arguments = [NSMutableArray array];
	for (GBMethodArgument *argument=first; argument!=nil; argument=va_arg(args, GBMethodArgument*)) {
		[arguments addObject:argument];
	}
	va_end(args);
	return [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"void"] arguments:arguments];
}

+ (GBMethodData *)classMethodWithArguments:(GBMethodArgument *)first,... {
	va_list args;
	va_start(args, first);
	NSMutableArray *arguments = [NSMutableArray array];
	for (GBMethodArgument *argument=first; argument!=nil; argument=va_arg(args, GBMethodArgument*)) {
		[arguments addObject:argument];
	}
	va_end(args);
	return [GBMethodData methodDataWithType:GBMethodTypeClass result:[NSArray arrayWithObject:@"void"] arguments:arguments];
}

+ (GBMethodData *)instanceMethodWithNames:(NSString *)first,... {
	va_list args;
	va_start(args, first);
	NSMutableArray *arguments = [NSMutableArray array];
	for (NSString *name=first; name!=nil; name=va_arg(args, NSString*)) {
		GBMethodArgument *argument = [self typedArgumentWithName:name];
		[arguments addObject:argument];
	}
	va_end(args);
	return [GBMethodData methodDataWithType:GBMethodTypeInstance result:[NSArray arrayWithObject:@"void"] arguments:arguments];
}

+ (GBMethodData *)classMethodWithNames:(NSString *)first,... {
	va_list args;
	va_start(args, first);
	NSMutableArray *arguments = [NSMutableArray array];
	for (NSString *name=first; name!=nil; name=va_arg(args, NSString*)) {
		GBMethodArgument *argument = [self typedArgumentWithName:name];
		[arguments addObject:argument];
	}
	va_end(args);
	return [GBMethodData methodDataWithType:GBMethodTypeClass result:[NSArray arrayWithObject:@"void"] arguments:arguments];
}

+ (GBMethodData *)propertyMethodWithArgument:(NSString *)name {
	GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:name];
	return [GBMethodData methodDataWithType:GBMethodTypeProperty result:[NSArray arrayWithObject:@"int"] arguments:[NSArray arrayWithObject:argument]];
}

+ (GBMethodArgument *)typedArgumentWithName:(NSString *)name {
	return [GBMethodArgument methodArgumentWithName:name types:[NSArray arrayWithObject:@"id"] var:name];
}

@end
