//
//  GBObjectsAssertor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <GRMustache/GRMustache.h>
#import "GBDataObjects.h"
#import "GBObjectsAssertor.h"

@implementation GBObjectsAssertor

#pragma mark Store objects

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
		assertThat(ivar.ivarTypes[i], is(arguments[i]));
	
	assertThat(ivar.nameOfIvar, is([arguments lastObject]));
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

- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args {
	// Note that we flatten all the arguments to make assertion methods simpler; nice trick but we do need to
	// use custom macros instead of hamcrest to get more meaningful description in case of failure :(
	GHAssertEquals(method.methodType, type, @"Method %@ type doesn't match!", method);
	
	NSMutableArray *arguments = [@[first] mutableCopy];
	NSString *arg;
	while ((arg = va_arg(args, NSString*))) {
		[arguments addObject:arg];
	}
	
	NSUInteger i=0;

	for (NSString *attribute in method.methodAttributes) {
		GHAssertEqualObjects(attribute, arguments[i++], @"Property %@ attribute doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (NSString *type in method.methodResultTypes) {
		GHAssertEqualObjects(type, arguments[i++], @"Method %@ result doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (GBMethodArgument *argument in method.methodArguments) {
		GHAssertEqualObjects(argument.argumentName, arguments[i++], @"Method %@ argument name doesn't match at flat idx %ld!", method, i-1);
		if (argument.argumentTypes) {
			for (NSString *type in argument.argumentTypes) {
				GHAssertEqualObjects(type, arguments[i++], @"Method %@ argument type doesn't match at flat idx %ld!", method, i-1);
			}
		}
		if (argument.argumentVar) {
			GHAssertEqualObjects(argument.argumentVar, arguments[i++], @"Method %@ argument var doesn't match at flat idx %ld!", method, i-1);
		}
		if (argument.isVariableArg) {
			GHAssertEqualObjects(@"...", arguments[i++], @"Method %@ argument va_arg ... doesn't match at flat idx %ld!", method, i-1);
			for (NSString *macro in argument.terminationMacros) {
				GHAssertEqualObjects(macro, arguments[i++], @"Method %@ argument va_arg termination macro doesn't match at flat idx %ld!", method, i-1);
			}
		}
	}
	
	GHAssertEquals(i, [arguments count], @"Flattened method %@ has %ld components, expected %ld!", method, i, [arguments count]);
}

- (void)assertFormattedComponents:(NSArray *)components match:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	NSString *value = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		NSNumber *style = @(va_arg(args, NSUInteger));
		NSString *href = va_arg(args, NSString *);
		if (!href) [NSException raise:@"Href not given for value %@ at index %ld!", value, [arguments count]];
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:4];
		data[@"value"] = value;
		data[@"style"] = style;
		data[@"href"] = href;
		if ([style unsignedIntValue] == 1) data[@"emphasized"] = @YES;
		[arguments addObject:data];
		
		value = va_arg(args, NSString *);
		if (!value) break;
	}
	va_end(args);
	
	assertThatInteger([components count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[components count]; i++) {
		NSDictionary *actual = components[i];
		NSDictionary *expected = arguments[i];
		
		assertThat(actual[@"value"], is(expected[@"value"]));
		assertThat(actual[@"emphasized"], is(expected[@"emphasized"]));
		
		NSNumber *expectedStyle = expected[@"style"];
		NSNumber *actualStyle = actual[@"style"];
		if ([expectedStyle unsignedIntValue] != 0)
			assertThat(actualStyle, is(expectedStyle));
		else
			assertThat(actualStyle, is(nil));
		
		NSString *expectedHref = expected[@"href"];
		NSString *actualHref = actual[@"href"];
		if ((NSNull *)expectedHref != GBNULL)
			assertThat(actualHref, is(expectedHref));
		else
			assertThat(actualHref, is(nil));
	}
}

#pragma mark Comment assertion methods

- (void)assertCommentComponents:(GBCommentComponentsList *)components matchesValues:(NSString *)first values:(va_list)args {
	NSMutableArray *expected = [NSMutableArray array];
	if (first) {
		[expected addObject:first];
		NSString *value;
		while ((value = va_arg(args, NSString *))) {
			[expected addObject:value];
		}
	}
	assertThatInteger([components.components count], equalToInteger([expected count]));
	for (NSUInteger i=0; i<[components.components count]; i++) {
		NSString *expectedValue = expected[i];
		NSString *actualValue = [components.components[i] stringValue];
		assertThat(actualValue, is(expectedValue));
	}
}

- (void)assertCommentComponents:(GBCommentComponentsList *)components matchesStringValues:(NSString *)first, ... {
	va_list args;
	va_start(args, first);
	[self assertCommentComponents:components matchesValues:first values:args];
	va_end(args);
}

- (void)assertComment:(GBComment *)comment matchesShortDesc:(NSString *)shortValue longDesc:(NSString *)first, ... {
	assertThat(comment.shortDescription.stringValue, is(shortValue));
	va_list args;
	va_start(args, first);
	[self assertCommentComponents:comment.longDescription matchesValues:first values:args];
	va_end(args);
}

- (void)assertMethodArguments:(NSArray *)arguments matches:(NSString *)name, ... {
	NSMutableArray *expected = [NSMutableArray array];
	if (name) {
		va_list args;
		va_start(args, name);
		NSString *value;
		NSMutableArray *strings = [NSMutableArray array];
		while ((value = va_arg(args, NSString *))) {
			if (!name) {
				name = value;
			} else if (value != (id)GBEND) {
				[strings addObject:value];
			} else {
				NSDictionary *data = @{@"name" : name, @"comps" : strings};
				[expected addObject:data];
				[strings removeAllObjects];
				name = nil;
			}
		}
		va_end(args);
		if (name) [NSException raise:@"Expecting GBEND to end method argument descriptions list!"];
	}
	assertThatInteger([arguments count], equalToInteger([expected count]));
	for (NSUInteger i=0; i<[arguments count]; i++) {
		GBCommentArgument *argument = arguments[i];
		NSDictionary *data = expected[i];
		
		NSString *expectedName = data[@"name"];
		assertThat(argument.argumentName, is(expectedName));

		NSMutableArray *expectedComps = data[@"comps"];
		if ([expectedComps count] > 0) {
			NSString *firstExpectedComp = [expectedComps firstObject];
			[expectedComps removeObjectAtIndex:0];
			void *argList = NULL;
			if ([expectedComps count] > 0) {
				argList = malloc(sizeof(void*) * [expectedComps count]);
				[expectedComps getObjects:(id __unsafe_unretained *)argList];
			}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
			[self assertCommentComponents:argument.argumentDescription matchesValues:firstExpectedComp values:argList];
#pragma clang diagnostic pop
		}
	}
}

@end
