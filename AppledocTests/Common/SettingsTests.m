//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "TestCaseBase.h"
#import "Settings.h"

@interface Settings (TestingPrivateAPI)
@property (nonatomic, strong) Settings *parent;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *storage;
@end

#pragma mark - 

@interface SettingsTests : TestCaseBase
- (void)runWithSettings:(void(^)(Settings *settings))handler;
@end

@implementation SettingsTests

#pragma mark - Validate constructors

- (void)testInitWithNameParentShouldSetupDefaultObjects {
	// setup
	Settings *parent = [Settings settingsWithName:@"p" parent:nil];
	// execute
	Settings *settings = [[Settings alloc] initWithName:@"n" parent:parent];
	// verify
	assertThat(settings.name, is(@"n"));
	assertThat(settings.parent, is(parent));
	assertThat(settings.storage, isNot(nil));
}

#pragma mark - Validate mutators

- (void)testMutatorsShouldChangeValue {
	[self runWithSettings:^(Settings *settings) {
		// execute
		[settings setObject:@"hello" forKey:@"string"];
		[settings setBool:YES forKey:@"bool"];
		[settings setInteger:-12 forKey:@"integer"];
		[settings setUnsignedInteger:50 forKey:@"uinteger"];
		[settings setFloat:4.0 forKey:@"float"];
		// verify
		assertThat([settings objectForKey:@"string"], is(@"hello"));
		assertThatBool([settings boolForKey:@"bool"], equalToBool(YES));
		assertThatInteger([settings integerForKey:@"integer"], equalToInteger(-12));
		assertThatUnsignedInteger([settings unsignedIntegerForKey:@"uinteger"], equalToUnsignedInteger(50));
		assertThatDouble([settings floatForKey:@"float"], equalToDouble(4.0));
	}];
}

- (void)testMutatorsShouldChangeValueOnGivenInstance {
	[self runWithSettings:^(Settings *settings) {
		// setup
		Settings *child = [Settings settingsWithName:@"child" parent:settings];
		// execute
		[child setObject:@"v1" forKey:@"k1"];
		[settings setObject:@"v2" forKey:@"k2"];
		// verify
		assertThat([child.storage objectForKey:@"k1"], is(@"v1"));
		assertThat([child.storage objectForKey:@"k2"], equalTo(nil));
		assertThat([settings.storage objectForKey:@"k1"], equalTo(nil));
		assertThat([settings.storage objectForKey:@"k2"], is(@"v2"));
	}];
}

#pragma mark - Validate accessors

- (void)testAccessorsShouldGetValueFromCurrentInstance {
	[self runWithSettings:^(Settings *settings) {
		// setup
		[settings setObject:@"hello" forKey:@"string"];
		// execute & verify
		assertThat([settings objectForKey:@"string"], is(@"hello"));
	}];
}

- (void)testAccessorsShouldGetValueFromParentIfCurrentInstanceDoesntProvideIt {
	[self runWithSettings:^(Settings *settings) {
		// setup
		Settings *child = [Settings settingsWithName:@"child" parent:settings];
		[settings setObject:@"hello" forKey:@"string"];
		// execute & verify
		assertThat([child objectForKey:@"string"], is(@"hello"));
	}];
}

#pragma mark - Creator methods

- (void)runWithSettings:(void(^)(Settings *settings))handler {
	Settings *settings = [Settings settingsWithName:@"name" parent:nil];
	handler(settings);
}

@end
