//
//  GBMethodsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBTestObjectsRegistry.h"
#import "GBMethodsProvider.h"

@interface GBMethodsProviderTesting : SenTestCase
@end

@implementation GBMethodsProviderTesting

#pragma mark Method registration testing

- (void)testRegisterMethod_shouldAddMethodToList {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
	assertThat([[provider.methods objectAtIndex:0] methodSelector], is(@"method:"));
}

- (void)testRegisterMethod_shouldIgnoreSameInstance {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *method = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	// execute
	[provider registerMethod:method];
	// verify
	assertThatInteger([provider.methods count], equalToInteger(1));
}

- (void)testRegisterMethod_shouldPreventAddingDifferentInstanceWithSameName {
	// setup
	GBMethodsProvider *provider = [[GBMethodsProvider alloc] init];
	GBMethodData *method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	GBMethodData *method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method", nil];
	[provider registerMethod:method1];
	// execute & verify
	STAssertThrows([provider registerMethod:method2], nil);
}

@end
