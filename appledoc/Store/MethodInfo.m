//
//  MethodInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "TypeInfo.h"
#import "MethodInfo.h"

@implementation MethodInfo

@synthesize methodType = _methodType;
@synthesize methodResult = _methodResult;

#pragma mark - Properties

- (TypeInfo *)methodResult {
	if (_methodResult) return _methodResult;
	LogStoDebug(@"Initializing method result due to first access...");
	_methodResult = [[TypeInfo alloc] init];
	return _methodResult;
}

@end

#pragma mark - 

@implementation MethodInfo (Registrations)

- (void)beginMethodResults {
	LogStoInfo(@"Starting method results...");
	[self pushRegistrationObject:self.methodResult];
}

- (void)endCurrentObject {
}

@end