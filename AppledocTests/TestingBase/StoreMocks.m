//
//  StoreMocks.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "Objects.h"
#import "StoreMocks.h"

@implementation StoreMocks

#pragma mark - Real objects

+ (InterfaceInfoBase *)createInterface:(void(^)(InterfaceInfoBase *object))handler {
	InterfaceInfoBase *result = [[InterfaceInfoBase alloc] init];
	handler(result);
	return result;
}

+ (ClassInfo *)createClass:(void(^)(ClassInfo *object))handler {
	ClassInfo *result = [[ClassInfo alloc] init];
	handler(result);
	return result;
}

+ (CategoryInfo *)createCategory:(void(^)(CategoryInfo *object))handler {
	CategoryInfo *result = [[CategoryInfo alloc] init];
	handler(result);
	return result;
}

+ (ProtocolInfo *)createProtocol:(void(^)(ProtocolInfo *object))handler {
	ProtocolInfo *result = [[ProtocolInfo alloc] init];
	handler(result);
	return result;
}

+ (MethodInfo *)createMethod:(NSString *)uniqueID {
	MethodInfo *result = [[MethodInfo alloc] init];
	NSRange range = NSMakeRange(1, uniqueID.length - 1);
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^:]+)(:?)" options:0 error:nil];
	[regex enumerateMatchesInString:uniqueID options:0 range:range usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
		NSString *selector = [match gb_stringAtIndex:1 in:uniqueID];
		NSString *colon = [match gb_stringAtIndex:2 in:uniqueID];
		MethodArgumentInfo *argument = [[MethodArgumentInfo alloc] init];
		argument.argumentSelector = selector;
		argument.argumentVariable = (colon.length > 0) ? selector : nil;
		[result.methodArguments addObject:argument];
	}];
	result.methodType = ([uniqueID characterAtIndex:0] == '+') ? GBStoreTypes.classMethod : GBStoreTypes.instanceMethod;
	return result;
}

+ (PropertyInfo *)createProperty:(NSString *)uniqueID {
	PropertyInfo *result = [[PropertyInfo alloc] init];
	result.propertyName = uniqueID;
	return result;
}

+ (ObjectLinkInfo *)link:(id)nameOrObject {
	ObjectLinkInfo *result = [[ObjectLinkInfo alloc] init];
	if ([nameOrObject isKindOfClass:[NSString class]])
		result.nameOfObject = nameOrObject;
	else
		result.linkToObject = nameOrObject;
	return result;
}

#pragma mark - Mocks

+ (id)mockClass:(NSString *)name {
	id result = mock([ClassInfo class]);
	[given([result nameOfClass]) willReturn:name];
	return result;
}

+ (id)mockCategory:(NSString *)name onClass:(NSString *)className {
	id result = mock([CategoryInfo class]);
	[given([result nameOfCategory]) willReturn:name];
	[given([result nameOfClass]) willReturn:className];
	[given([result categoryClass]) willReturn:[self link:className]];
	return result;
}

+ (id)mockProtocol:(NSString *)name {
	id result = mock([ProtocolInfo class]);
	[given([result nameOfProtocol]) willReturn:name];
	return result;
}

+ (id)mockMethod:(NSString *)uniqueID {
	id result = mock([MethodInfo class]);
	[given([result uniqueObjectID]) willReturn:uniqueID];
	return result;
}

+ (id)mockProperty:(NSString *)uniqueID {
	id result = mock([PropertyInfo class]);
	[given([result uniqueObjectID]) willReturn:uniqueID];
	return result;
}

+ (void)addCommentToMock:(id)mock {
	id comment = mock([CommentInfo class]);
	[given([mock comment]) willReturn:comment];
}

+ (id)mockCommentedMethod:(NSString *)uniqueID {
	id result = [self mockMethod:uniqueID];
	[self addCommentToMock:result];
	return result;
}

+ (id)mockCommentedProperty:(NSString *)uniqueID {
	id result = [self mockProperty:uniqueID];
	[self addCommentToMock:result];
	return result;
}

@end

#pragma mark - 

@implementation InterfaceInfoBase (UnitTestsMocks)

- (void)adopt:(NSString *)first, ... {
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		ObjectLinkInfo *link = [[ObjectLinkInfo alloc] init];
		link.nameOfObject = arg;
		[self.interfaceAdoptedProtocols addObject:link];
	}
	va_end(args);
}

@end

#pragma mark -

@implementation CategoryInfo (UnitTestsMocks)

- (void)extend:(NSString *)name {
	self.categoryClass.nameOfObject = name;
}

@end

#pragma mark -

@implementation ClassInfo (UnitTestsMocks)

- (void)derive:(NSString *)name {
	self.classSuperClass.nameOfObject = name;
}

@end
