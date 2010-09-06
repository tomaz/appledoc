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
	GHAssertEquals(method.methodType, type, @"Method %@ type doesn't match!", method);
	
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:first];
	NSString *arg;
	while ((arg = va_arg(args, NSString*))) {
		[arguments addObject:arg];
	}
	
	NSUInteger i=0;
	
	for (NSString *attribute in method.methodAttributes) {
		GHAssertEqualObjects(attribute, [arguments objectAtIndex:i++], @"Property %@ attribute doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (NSString *type in method.methodResultTypes) {
		GHAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method %@ result doesn't match at flat idx %ld!", method, i-1);
	}
	
	for (GBMethodArgument *argument in method.methodArguments) {
		GHAssertEqualObjects(argument.argumentName, [arguments objectAtIndex:i++], @"Method %@ argument name doesn't match at flat idx %ld!", method, i-1);
		if (argument.argumentTypes) {
			for (NSString *type in argument.argumentTypes) {
				GHAssertEqualObjects(type, [arguments objectAtIndex:i++], @"Method %@ argument type doesn't match at flat idx %ld!", method, i-1);
			}
		}
		if (argument.argumentVar) {
			GHAssertEqualObjects(argument.argumentVar, [arguments objectAtIndex:i++], @"Method %@ argument var doesn't match at flat idx %ld!", method, i-1);
		}
		if (argument.isVariableArg) {
			GHAssertEqualObjects(@"...", [arguments objectAtIndex:i++], @"Method %@ argument va_arg ... doesn't match at flat idx %ld!", method, i-1);
			for (NSString *macro in argument.terminationMacros) {
				GHAssertEqualObjects(macro, [arguments objectAtIndex:i++], @"Method %@ argument va_arg termination macro doesn't match at flat isx %ld!", method, i-1);
			}
		}
	}
	
	GHAssertEquals(i, [arguments count], @"Flattened method %@ has %ld components, expected %ld!", method, i, [arguments count]);
}

#pragma mark Comment objects

- (void)assertParagraph:(GBCommentParagraph *)paragraph containsItems:(Class)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	Class class = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		NSString *value = va_arg(args, NSString *);
		if (!value) [NSException raise:@"Value not given for type %@ at index %ld!", class, [arguments count] * 2];
		
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:class, @"class", value, @"value", nil];
		[arguments addObject:data];
		
		class = va_arg(args, Class);
		if (!class) break;
	}
	va_end(args);
	
	assertThatInteger([paragraph.items count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[paragraph.items count]; i++) {
		GBParagraphItem *item = [paragraph.items objectAtIndex:i];
		NSDictionary *data = [arguments objectAtIndex:i];
		assertThat([item class], is([data objectForKey:@"class"]));
		if ([data objectForKey:@"value"] == [NSNull null]) continue;
		assertThat([item stringValue], is([data objectForKey:@"value"]));
	}
}

- (void)assertList:(GBParagraphListItem *)list isOrdered:(BOOL)ordered containsParagraphs:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	va_list args;
	va_start(args,first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString*)) {
		[arguments addObject:arg];
	}
	va_end(args);
	
	assertThatBool(list.isOrdered, equalToBool(ordered));
	assertThatInteger([arguments count], equalToInteger([list.items count]));
	for (NSUInteger i=0; i<[list.items count]; i++) {
		assertThat([[list.items objectAtIndex:i] class], is([GBCommentParagraph class]));
		assertThat([[list.items objectAtIndex:i] stringValue], is([arguments objectAtIndex:i]));
	}
}

- (void)assertDecoratedItem:(GBParagraphItem *)item describesHierarchy:(Class)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	Class class = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		NSNumber *type = [NSNumber numberWithUnsignedInt:va_arg(args, NSUInteger)];
		NSString *value = va_arg(args, NSString *);
		if (!value) [NSException raise:@"Value not given for type %@ at index %ld!", class, [arguments count] * 2];
		
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:class, @"class", type, @"type", value, @"value", nil];
		[arguments addObject:data];
		
		class = va_arg(args, Class);
		if (!class) break;
	}
	va_end(args);
	
	GBParagraphDecoratorItem *decorator = (GBParagraphDecoratorItem *)item;
	for (NSUInteger i=0; i<[arguments count]; i++) {
		NSDictionary *data = [arguments objectAtIndex:i];
		Class class = [data objectForKey:@"class"];
		NSUInteger type = [[data objectForKey:@"type"] unsignedIntValue];		
		NSString *value = [data objectForKey:@"value"];
		
		NSLog(@"Expecting %@, type %ld, text %@ at level %ld.", class, type, value, i);
		assertThat([decorator class], is(class));
		assertThat([decorator stringValue], is(value));
		if (type != GBDecorationTypeNone) {
			assertThatInteger(decorator.decorationType, equalToInteger(type));
			decorator = (GBParagraphDecoratorItem *)[decorator decoratedItem];
		}
	}
}

@end
