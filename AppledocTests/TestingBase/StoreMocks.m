//
//  StoreMocks.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
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

+ (ObjectLinkInfo *)link:(NSString *)name {
	ObjectLinkInfo *result = [[ObjectLinkInfo alloc] init];
	result.nameOfObject = name;
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
