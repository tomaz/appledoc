//
//  GBObjectsAssertor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GRMustache.h"
#import "GBDataObjects.h"
#import "GBObjectsAssertor.h"

@interface GBObjectsAssertor ()

- (NSUInteger)assertDecoratedItem:(GBParagraphItem *)item describesHierarchy:(NSArray *)arguments startingAtIndex:(NSUInteger)index;
- (NSUInteger)assertListItem:(GBParagraphListItem *)item describesHierarchy:(NSArray *)arguments startingAtIndex:(NSUInteger)index atLevel:(NSUInteger)level;
- (void)assertParagraph:(GBCommentParagraph *)paragraph contains:(NSString*)first descriptions:(va_list)args assertItemClass:(Class)class;

@end

#pragma mark -

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

- (void)assertFormattedComponents:(NSArray *)components match:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	NSString *value = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		NSNumber *style = [NSNumber numberWithUnsignedInt:va_arg(args, NSUInteger)];
		NSString *href = va_arg(args, NSString *);
		if (!href) [NSException raise:@"Href not given for value %@ at index %ld!", value, [arguments count]];
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:4];
		[data setObject:value forKey:@"value"];
		[data setObject:style forKey:@"style"];
		[data setObject:href forKey:@"href"];
		if ([style unsignedIntValue] == 1) [data setObject:[GRYes yes] forKey:@"emphasized"];
		[arguments addObject:data];
		
		value = va_arg(args, NSString *);
		if (!value) break;
	}
	va_end(args);
	
	assertThatInteger([components count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[components count]; i++) {
		NSDictionary *actual = [components objectAtIndex:i];
		NSDictionary *expected = [arguments objectAtIndex:i];
		
		assertThat([actual objectForKey:@"value"], is([expected objectForKey:@"value"]));
		assertThat([actual objectForKey:@"emphasized"], is([expected objectForKey:@"emphasized"]));
		
		NSNumber *expectedStyle = [expected objectForKey:@"style"];
		NSNumber *actualStyle = [actual objectForKey:@"style"];
		if ([expectedStyle unsignedIntValue] != 0)
			assertThat(actualStyle, is(expectedStyle));
		else
			assertThat(actualStyle, is(nil));
		
		NSString *expectedHref = [expected objectForKey:@"href"];
		NSString *actualHref = [actual objectForKey:@"href"];
		if ((NSNull *)expectedHref != GBNULL)
			assertThat(actualHref, is(expectedHref));
		else
			assertThat(actualHref, is(nil));
	}
}

#pragma mark Paragraph testing

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
	
	assertThatInteger([paragraph.paragraphItems count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[paragraph.paragraphItems count]; i++) {
		GBParagraphItem *item = [paragraph.paragraphItems objectAtIndex:i];
		NSDictionary *data = [arguments objectAtIndex:i];
		assertThat([item class], is([data objectForKey:@"class"]));
		if ([data objectForKey:@"value"] == GBNULL) continue;
		assertThat([item stringValue], is([data objectForKey:@"value"]));
	}
}

- (void)assertParagraph:(GBCommentParagraph *)paragraph containsLinks:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	NSString *value = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		id context = va_arg(args, id);
		if (!context) [NSException raise:@"Context not given for value %@ at index %ld!", value, [arguments count] * 4];
		
		id member = va_arg(args, id);
		if (!member) [NSException raise:@"Member not given for value %@ at index %ld!", value, [arguments count] * 4];
		
		BOOL local = va_arg(args, BOOL);
		
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"value", context, @"context", member, @"member", [NSNumber numberWithBool:local], @"local", nil];
		[arguments addObject:data];
		
		value = va_arg(args, NSString *);
		if (!value) break;
	}
	va_end(args);
	
	assertThatInteger([paragraph.paragraphItems count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[paragraph.paragraphItems count]; i++) {
		GBParagraphLinkItem *item = [paragraph.paragraphItems objectAtIndex:i];
		NSDictionary *data = [arguments objectAtIndex:i];
		NSString *value = [data objectForKey:@"value"];
		id context = [data objectForKey:@"context"];
		id member = [data objectForKey:@"member"];
		BOOL local = [[data objectForKey:@"local"] boolValue];
		assertThat([item class], is([GBParagraphLinkItem class]));
		assertThat(item.stringValue, is(value));
		assertThat(item.context, is(context != GBNULL ? context : nil));
		assertThat(item.member, is(member != GBNULL ? member : nil));
		assertThatBool(item.isLocal, equalToBool(local));
	}
}

- (void)assertParagraph:(GBCommentParagraph *)paragraph containsTexts:(NSString *)first,... {
	va_list args;
	va_start(args,first);
	[self assertParagraph:paragraph contains:first descriptions:args assertItemClass:[GBParagraphTextItem class]];
	va_end(args);	
}

- (void)assertParagraph:(GBCommentParagraph *)paragraph containsDescriptions:(NSString *)first,... {
	va_list args;
	va_start(args,first);
	[self assertParagraph:paragraph contains:first descriptions:args assertItemClass:NULL];
	va_end(args);	
}

- (void)assertParagraph:(GBCommentParagraph *)paragraph contains:(NSString*)first descriptions:(va_list)args assertItemClass:(Class)class {
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:first];
	NSString *arg;
	while ((arg = va_arg(args, NSString*))) {
		[arguments addObject:arg];
	}
	
	assertThatInteger([paragraph.paragraphItems count], equalToInteger([arguments count]));
	for (NSUInteger i=0; i<[paragraph.paragraphItems count]; i++) {
		GBParagraphItem *item = [paragraph.paragraphItems objectAtIndex:i];
		if (class) assertThat([item class], is(class));
		assertThat(item.stringValue, is([arguments objectAtIndex:i]));
	}
}

#pragma mark Lists testing

- (void)assertList:(GBParagraphListItem *)list isOrdered:(BOOL)ordered containsParagraphs:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	va_list args;
	va_start(args,first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString*)) {
		[arguments addObject:arg];
	}
	va_end(args);
	
	assertThatBool(list.isOrdered, equalToBool(ordered));
	assertThatInteger([arguments count], equalToInteger([list.listItems count]));
	for (NSUInteger i=0; i<[list.listItems count]; i++) {
		assertThat([[list.listItems objectAtIndex:i] class], is([GBCommentParagraph class]));
		assertThat([[list.listItems objectAtIndex:i] stringValue], is([arguments objectAtIndex:i]));
	}
}

- (void)assertList:(GBParagraphListItem *)list describesHierarchy:(NSString *)first,... {
	NSMutableArray *arguments = [NSMutableArray array];
	NSString *value = first;
	va_list args;
	va_start(args,first);
	while (YES) {
		NSNumber *ordered = [NSNumber numberWithBool:va_arg(args, BOOL)];
		NSNumber *level = [NSNumber numberWithUnsignedInt:va_arg(args, NSUInteger)];
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"value", ordered, @"ordered", level, @"level", nil];
		[arguments addObject:data];		
		value = va_arg(args, NSString *);
		if (!value) break;
	}
	va_end(args);
	
	NSUInteger index = [self assertListItem:list describesHierarchy:arguments startingAtIndex:0 atLevel:1];
	assertThatInteger(index, equalToInteger([arguments count]));
}

- (NSUInteger)assertListItem:(GBParagraphListItem *)item describesHierarchy:(NSArray *)arguments startingAtIndex:(NSUInteger)index atLevel:(NSUInteger)expectedLevel {	
	// Verify item's values. Note that each item must have at least one paragraph with item's text description!
	assertThat([item class], is([GBParagraphListItem class]));
	
	// Recursively follow all paragraphs and their subitems hierarchy (skip text items).
	for (GBCommentParagraph *paragraph in item.listItems) {
		for (GBParagraphItem *paragraphsItem in paragraph.paragraphItems) {
			if ([paragraphsItem isKindOfClass:[GBParagraphTextItem class]]) {
				// Get current expected values.
				NSDictionary *data = [arguments objectAtIndex:index];
				NSString *value = [data objectForKey:@"value"];
				BOOL ordered = [[data objectForKey:@"ordered"] boolValue];
				NSUInteger level = [[data objectForKey:@"level"] unsignedIntValue];
				
				// Verify values, note that we also verify parent-list item's values here...
				assertThat([paragraphsItem stringValue], is(value));
				assertThatBool([item isOrdered], equalToBool(ordered));
				assertThatInteger(expectedLevel, equalToInteger(level));
				index++;
			} else if ([paragraphsItem isKindOfClass:[GBParagraphListItem class]]) {
				GBParagraphListItem *list = (GBParagraphListItem *)paragraphsItem;
				index = [self assertListItem:list describesHierarchy:arguments startingAtIndex:index atLevel:expectedLevel+1];
			}
		}
	}
	return index;
}

#pragma mark Decorated items testing

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
	NSUInteger index = [self assertDecoratedItem:item describesHierarchy:arguments startingAtIndex:0];
	assertThatInteger(index, equalToInteger([arguments count]));
}

- (NSUInteger)assertDecoratedItem:(GBParagraphItem *)item describesHierarchy:(NSArray *)arguments startingAtIndex:(NSUInteger)index {
	// Get current expected values.
	NSDictionary *data = [arguments objectAtIndex:index];
	Class class = [data objectForKey:@"class"];
	NSUInteger type = [[data objectForKey:@"type"] unsignedIntValue];
	NSString *value = [data objectForKey:@"value"];		
	//NSLog(@"Expecting %@, type %ld, text %@ at index %ld.", class, type, value, index);
	
	// Increment the index (as we're relying on cached values we can do so before verifying).
	index++;
	
	// Verify common values.
	assertThat([item class], is(class));
	assertThat([item stringValue], is(value));
	
	// Verify decorator values and all children.
	if (type != GBDecorationTypeNone) {
		GBParagraphDecoratorItem *decorator = (GBParagraphDecoratorItem *)item;
		assertThatInteger(decorator.decorationType, equalToInteger(type));
		for (GBParagraphItem *child in [decorator decoratedItems]) {
			index = [self assertDecoratedItem:child describesHierarchy:arguments startingAtIndex:index];
		}
	}
	
	return index;
}

#pragma mark Other comment items testing

- (void)assertLinkItem:(GBParagraphLinkItem *)item hasLink:(NSString *)link context:(id)context member:(id)member local:(BOOL)local {
	assertThat([item stringValue], is(link));
	assertThat([item context], is(context));
	assertThat([item member], is(member));
	assertThatBool([item isLocal], equalToBool(local));
}

#pragma mark Arguments testing

- (void)assertArgument:(GBCommentArgument *)argument hasName:(NSString *)name descriptions:(NSString *)first,... {
	NSMutableArray *descriptions = [NSMutableArray array];
	va_list args;
	va_start(args,first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString*)) {
		[descriptions addObject:arg];
	}
	va_end(args);
	assertThat([argument class], is([GBCommentArgument class]));
	assertThatInteger([argument.argumentDescription.paragraphItems count], equalToInteger([descriptions count]));
	[argument.argumentDescription.paragraphItems enumerateObjectsUsingBlock:^(GBParagraphItem *item, NSUInteger idx, BOOL *stop) {
		assertThat([item stringValue], is([descriptions objectAtIndex:idx]));
	}];
}

@end
