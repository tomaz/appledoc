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

#pragma mark - Real interfaces

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

#pragma mark - Real members

+ (MethodInfo *)createMethod:(NSString *)uniqueID block:(void(^)(MethodInfo *object))handler {
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
	handler(result);
	return result;
}

+ (MethodInfo *)createMethod:(NSString *)uniqueID {
	return [self createMethod:uniqueID block:^(MethodInfo *object) { }];
}

+ (PropertyInfo *)createProperty:(NSString *)uniqueID block:(void(^)(PropertyInfo *object))handler {
	PropertyInfo *result = [[PropertyInfo alloc] init];
	result.propertyName = uniqueID;
	handler(result);
	return result;
}

+ (PropertyInfo *)createProperty:(NSString *)uniqueID {
	return [self createProperty:uniqueID block:^(PropertyInfo *object) { }];
}

+ (ObjectLinkInfo *)link:(id)nameOrObject {
	ObjectLinkInfo *result = [[ObjectLinkInfo alloc] init];
	if ([nameOrObject isKindOfClass:[NSString class]])
		result.nameOfObject = nameOrObject;
	else
		result.linkToObject = nameOrObject;
	return result;
}

#pragma mark - Mock interfaces

+ (id)mockClass:(NSString *)name block:(GBCreateObjectBlock)handler {
	id result = mock([ClassInfo class]);
	[given([result nameOfClass]) willReturn:name];
	handler(result);
	return result;
}

+ (id)mockCategory:(NSString *)name onClass:(NSString *)className block:(GBCreateObjectBlock)handler {
	id result = mock([CategoryInfo class]);
	[given([result nameOfCategory]) willReturn:name];
	[given([result nameOfClass]) willReturn:className];
	[given([result categoryClass]) willReturn:[self link:className]];
	handler(result);
	return result;
}

+ (id)mockProtocol:(NSString *)name block:(GBCreateObjectBlock)handler {
	id result = mock([ProtocolInfo class]);
	[given([result nameOfProtocol]) willReturn:name];
	handler(result);
	return result;
}

#pragma mark - Mock members

+ (id)mockMethod:(NSString *)uniqueID {
	return [self mockMethod:uniqueID block:^(id object) { }];
}

+ (id)mockMethod:(NSString *)uniqueID block:(void(^)(id object))handler {
	id result = mock([MethodInfo class]);
	[given([result uniqueObjectID]) willReturn:uniqueID];
	handler(result);
	return result;
}

+ (id)mockProperty:(NSString *)uniqueID {
	return [self mockProperty:uniqueID block:^(id object) { }];
}

+ (id)mockProperty:(NSString *)uniqueID block:(void(^)(id object))handler {
	id result = mock([PropertyInfo class]);
	[given([result uniqueObjectID]) willReturn:uniqueID];
	handler(result);
	return result;
}

#pragma mark - Common stuff

+ (void)addMockCommentTo:(id)objectOrMock {
	id comment = mock([CommentInfo class]);
	if ([self isMock:objectOrMock])
		[given([objectOrMock comment]) willReturn:comment];
	else
		[objectOrMock setComment:comment];
}

+ (void)add:(id)classOrMock asDerivedClassFrom:(id)baseOrMock {
	ObjectLinkInfo *link = [self link:baseOrMock];
	if ([self isMock:classOrMock])
		[given([classOrMock classSuperClass]) willReturn:link];
	else
		[classOrMock setClassSuperClass:link];
}

+ (void)add:(id)objectOrMock asAdopting:(id)protocolOrMock {
	ObjectLinkInfo *link = [self link:protocolOrMock];
	if ([self isMock:objectOrMock])
		[given([objectOrMock interfaceAdoptedProtocols]) willReturn:@[ link ]];
	else
		[[objectOrMock interfaceAdoptedProtocols] addObject:link];
}

+ (void)add:(id)methodOrMock asClassMethodOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceClassMethods]) willReturn:@[ methodOrMock ]];
	else
		[[interfaceOrMock interfaceClassMethods] addObject:methodOrMock];
}

+ (void)add:(id)methodOrMock asInstanceMethodOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceInstanceMethods]) willReturn:@[ methodOrMock ]];
	else
		[[interfaceOrMock interfaceInstanceMethods] addObject:methodOrMock];
}

+ (void)add:(id)propertyOrMock asPropertyOf:(id)interfaceOrMock {
	if ([self isMock:interfaceOrMock])
		[given([interfaceOrMock interfaceProperties]) willReturn:@[ propertyOrMock ]];
	else
		[[interfaceOrMock interfaceProperties] addObject:propertyOrMock];
}

+ (BOOL)isMock:(id)objectOrMock {
	return ![objectOrMock isKindOfClass:[ObjectInfoBase class]];
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
