//
//  GBObjectsAssertor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBObjectsAssertor.h"

@implementation GBObjectsAssertor

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
	STAssertEquals(method.methodType, type, @"Method %@ type doesn't match!", method);
	
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:first];
	NSString *arg;
	while ((arg = va_arg(args, NSString*))) {
		[arguments addObject:arg];
	}
	
	NSUInteger i=0;
	
	for (NSString *attribute in method.methodAttributes) {
		STAssertEqualObjects(attribute, [arguments objectAtIndex:i++], @"Property %@ attribute doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (NSString *type in method.methodResultTypes) {
		STAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method %@ result doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (GBMethodArgument *argument in method.methodArguments) {
		STAssertEqualObjects(argument.argumentName, [arguments objectAtIndex:i++], @"Method %@ argument name doesn't match at flat idx %ld!", method, i-1);
		if (argument.argumentTypes) {
			for (NSString *type in argument.argumentTypes) {
				STAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method %@ argument type doesn't match at flat idx %ld!", method, i-1);
			}
		}
		if (argument.argumentVar) {
			STAssertEqualObjects(argument.argumentVar, [arguments objectAtIndex:i++], @"Method %@ argument var doesn't match at flat idx %ld!", method, i-1);
		}
		if (argument.isVariableArg) {
			STAssertEqualObjects(@"...", [arguments objectAtIndex:i++], @"Method %@ argument va_arg ... doesn't match at flat idx %ld!", method, i-1);
			for (NSString *macro in argument.terminationMacros) {
				STAssertEqualObjects(macro, [arguments objectAtIndex:i++], @"Method %@ argument va_arg termination macro doesn't match at flat isx %ld!", method, i-1);
			}
		}
	}
	
	STAssertEquals(i, [arguments count], @"Flattened method %@ has %ld components, expected %ld!", method, i, [arguments count]);
}

@end
