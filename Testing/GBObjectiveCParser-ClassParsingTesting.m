//
//  GBObjectiveCParser-ClassParsingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParserClassParsingTesting : SenTestCase

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesInstanceComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesClassComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesPropertyComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args;

@end

@implementation GBObjectiveCParserClassParsingTesting

#pragma mark Classes common data parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(1));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass"));
}

- (void)testParseObjectsFromString_shouldRegisterAllClassDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass1 @end   @interface MyClass2 @end" toStore:store];
	// verify
	NSArray *classes = [store classesSortedByName];
	assertThatInteger([classes count], equalToInteger(2));
	assertThat([[classes objectAtIndex:0] className], is(@"MyClass1"));
	assertThat([[classes objectAtIndex:1] className], is(@"MyClass2"));
}

- (void)testParseObjectsFromString_shouldRegisterRootClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(nil));
}

- (void)testParseObjectsFromString_shouldRegisterDerivedClass {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass : NSObject @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	assertThat(class.superclassName, is(@"NSObject"));
}

#pragma mark Classes adopted protocols parsing testing

- (void)testParseObjectsFromString_shouldRegisterAdoptedProtocol {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <MyProtocol> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [[class adoptedProtocols] protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(1));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"MyProtocol"));
}

- (void)testParseObjectsFromString_shouldRegisterAllAdoptedProtocols {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass <MyProtocol1, MyProtocol2> @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *protocols = [[class adoptedProtocols] protocolsSortedByName];
	assertThatInteger([protocols count], equalToInteger(2));
	assertThat([[protocols objectAtIndex:0] protocolName], is(@"MyProtocol1"));
	assertThat([[protocols objectAtIndex:1] protocolName], is(@"MyProtocol2"));
}

#pragma mark Ivars parsing testing

- (void)testParseObjectsFromString_shouldRegisterIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"int", @"_var", nil];
}

- (void)testParseObjectsFromString_shouldRegisterAllIVars {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { int _var1; long _var2; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(2));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"int", @"_var1", nil];
	[self assertIvar:[ivars objectAtIndex:1] matches:@"long", @"_var2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterComplexIVar {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass { id<Protocol>* _var; } @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *ivars = [[class ivars] ivars];
	assertThatInteger([ivars count], equalToInteger(1));
	[self assertIvar:[ivars objectAtIndex:0] matches:@"id", @"<", @"Protocol", @">", @"*", @"_var", nil];
}

#pragma mark Methods parsing testing

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithNoArguments {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(id)method; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", nil];
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithArguments {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(id)method:(NSString*)var; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method", @"NSString", @"*", @"var", nil];
}

- (void)testParseObjectsFromString_shouldRegisterMethodDefinitionWithMutlipleArguments {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(id)arg1:(int)var1 arg2:(long)var2; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"arg1", @"int", @"var1", @"arg2", @"long", @"var2", nil];
}

- (void)testParseObjectsFromString_shouldRegisterAllMethodDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass -(id)method1; +(void)method2; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesInstanceComponents:@"id", @"method1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesClassComponents:@"void", @"method2", nil];
}

#pragma mark Properties parsing testing

- (void)testParseObjectsFromString_shouldRegisterSimplePropertyDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"readonly", @"int", @"name", nil];
}

- (void)testParseObjectsFromString_shouldRegisterComplexPropertyDefinition {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @property(retain,nonatomic) IBOutlet NSString *name; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(1));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"retain", @"nonatomic", @"IBOutlet", @"NSString", @"*", @"name", nil];
}

- (void)testParseObjectsFromString_shouldRegisterAllPropertyDefinitions {
	// setup
	GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
	GBStore *store = [[GBStore alloc] init];
	// execute
	[parser parseObjectsFromString:@"@interface MyClass @property(readonly) int name1; @property(readwrite)long name2; @end" toStore:store];
	// verify
	GBClassData *class = [[store classes] anyObject];
	NSArray *methods = [[class methods] methods];
	assertThatInteger([methods count], equalToInteger(2));
	[self assertMethod:[methods objectAtIndex:0] matchesPropertyComponents:@"readonly", @"int", @"name1", nil];
	[self assertMethod:[methods objectAtIndex:1] matchesPropertyComponents:@"readwrite", @"long", @"name2", nil];
}

#pragma mark Complex parsing testing

- (void)testParseObjectsFromString_shouldRegisterClassFromRealLifeInput {
	// setup
}

#pragma mark Assertion methods

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... {
	NSMutableArray *arguments = [NSMutableArray array];
	va_list args;
	va_start(args, firstType);
	for (NSString *arg=firstType; arg != nil; arg=va_arg(args, NSString*)) {
		[arguments addObject:arg];
	}
	va_end(args);
	
	assertThatInteger([[ivar ivarTypes] count], equalToInteger([arguments count] - 1));
	for (NSUInteger i=0; i<[arguments count] - 1; i++)
		assertThat([ivar.ivarTypes objectAtIndex:i], is([arguments objectAtIndex:i]));
	
	assertThat(ivar.ivarName, is([arguments lastObject]));
}

- (void)assertMethod:(GBMethodData *)method matchesInstanceComponents:(NSString *)firstItem,... {
	va_list args;
	va_start(args,firstItem);
	[self assertMethod:method matchesType:GBMethodTypeInstance start:firstItem components:args];
	va_end(args);
}
- (void)assertMethod:(GBMethodData *)method matchesClassComponents:(NSString *)firstItem,... {
	va_list args;
	va_start(args,firstItem);
	[self assertMethod:method matchesType:GBMethodTypeClass start:firstItem components:args];
	va_end(args);
}

- (void)assertMethod:(GBMethodData *)method matchesPropertyComponents:(NSString *)firstItem,... {
	va_list args;
	va_start(args,firstItem);
	[self assertMethod:method matchesType:GBMethodTypeProperty start:firstItem components:args];
	va_end(args);
}

//- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type components:(NSString *)firstItem,... {
- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args {
	// Note that we flatten all the arguments to make assertion methods simpler; nice trick but we do need to
	// use ST macros instead of hamcrest to get more meaningful description in case of failure :(
	STAssertEquals(method.methodType, type, @"Method type doesn't match!");
	
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:first];
	NSString *arg;
	while ((arg = va_arg(args, NSString*))) {
		[arguments addObject:arg];
	}

	NSUInteger i=0;
	
	for (NSString *attribute in method.methodAttributes) {
		STAssertEqualObjects(attribute, [arguments objectAtIndex:i++], @"Property attribute doesn't match at flat idx %ld!", i-1);
	}
	
	for (NSString *type in method.methodResultTypes) {
		STAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method result doesn't match at flat idx %ld!", i-1);
	}
	
	for (GBMethodArgument *argument in method.methodArguments) {
		STAssertEqualObjects(argument.argumentName, [arguments objectAtIndex:i++], @"Method argument name doesn't match at flat idx %ld!", i-1);
		if (argument.argumentTypes) {
			for (NSString *type in argument.argumentTypes) {
				STAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method argument type doesn't match at flat idx %ld!", i-1);
			}
		}
		if (argument.argumentVar) {
			STAssertEqualObjects(argument.argumentVar, [arguments objectAtIndex:i++], @"Method argument var doesn't match at flat idx %ld!", i-1);
		}
	}
	
	STAssertEquals(i, [arguments count], @"Flattened method has %ld components, expected %ld!", i, [arguments count]);
}

@end
