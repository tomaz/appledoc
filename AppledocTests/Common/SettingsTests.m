//
//  SettingsTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Settings+Appledoc.h"
#import "Objects+TestingPrivateAPI.h"
#import "TestCaseBase.h"

@interface SettingsTests : TestCaseBase
@end

@interface SettingsTests (CreationMethods)
- (void)runWithSettings:(void(^)(Settings *settings))handler;
@end

@interface SettingsTests (HelperMethods)
- (NSSet *)registeredOptionsForParser:(CommandLineArgumentsParser *)parser;
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

#pragma mark - setObject:forKey:

- (void)testSetObjectForKeyShouldUseLastValueIfSentMultipleTimes {
	[self runWithSettings:^(Settings *settings) {
		// setup
		[settings setObject:@"1" forKey:@"string"];
		// execute
		[settings setObject:@"2" forKey:@"string"];
		// verify
		assertThat([settings objectForKey:@"string"], is(@"2"));
	}];
}

- (void)testSetObjectForKeyShouldStoreArrayIfKeyIsRegisteredAsArray {
	[self runWithSettings:^(Settings *settings) {
		// setup
		[settings registerArrayForKey:@"string"];
		[settings setObject:@"1" forKey:@"string"];
		// execute
		[settings setObject:@"2" forKey:@"string"];
		// verify
		assertThat([settings objectForKey:@"string"], onlyContains(@"1", @"2", nil));
	}];
}

- (void)testSetObjectForKeyShouldStoreAllValuesIfKeyIsRegisteredAsArrayAndArrayIsPassed {
	[self runWithSettings:^(Settings *settings) {
		// setup
		[settings registerArrayForKey:@"string"];
		[settings setObject:@"1" forKey:@"string"];
		// execute
		[settings setObject:[NSArray arrayWithObjects:@"2", @"3", nil] forKey:@"string"];
		// verify
		assertThat([settings objectForKey:@"string"], onlyContains(@"1", @"2", @"3", nil));
	}];
}

#pragma mark - registerOptionsToCommandLineParser:

- (void)testRegisterOptionsToCommandLineParserShouldRegisterProjectOptions {
	[self runWithSettings:^(Settings *settings) {
		// setup
		CommandLineArgumentsParser *parser = [CommandLineArgumentsParser new];
		// execute
		[settings registerOptionsToCommandLineParser:parser];
		// verify
		NSSet *registeredOptions = [self registeredOptionsForParser:parser];
		assertThat(registeredOptions, hasItems(@"project-name", @"project-version", @"company-name", @"company-id", nil));
	}];
}

@end

#pragma mark -

@implementation SettingsTests (CreationMethods)

- (void)runWithSettings:(void(^)(Settings *settings))handler {
	Settings *settings = [Settings settingsWithName:@"name" parent:nil];
	handler(settings);
}

@end

@implementation SettingsTests (HelperMethods)

- (NSSet *)registeredOptionsForParser:(CommandLineArgumentsParser *)parser {
	NSDictionary *registeredOptions = parser.registeredOptionsByLongNames;
	NSMutableSet *result = [NSMutableSet setWithCapacity:registeredOptions.count];
	[registeredOptions.allValues enumerateObjectsUsingBlock:^(NSDictionary *optionData, NSUInteger idx, BOOL *stop) {
		NSString *optionName = [optionData objectForKey:@"long"];
		[result addObject:optionName];
	}];
	return result;
}

@end
