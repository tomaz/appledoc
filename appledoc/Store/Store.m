//
//  Store.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"

#pragma mark - 

@implementation Store {
	PKToken *_currentSourceInfo;
}

@end

#pragma mark - 

@implementation Store (Registrations)

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived {
	NSUInteger i=0;
	LogParDebug(@"%@ is %d", name, i);
}

- (void)beginExtensionForClassWithName:(NSString *)name {
}

- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name {
}

- (void)beginProtocolWithName:(NSString *)name {
}

- (void)appendAdoptedProtocolWithName:(NSString *)name {
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
}

- (void)beginPropertyAttributes {
}

- (void)appendPropertyName:(NSString *)name {
}

#pragma mark - Methods

- (void)beginMethodDefinition {
}

- (void)appendMethodType:(NSString *)type {
}

- (void)beginMethodArgument {
}

- (void)appendMethodArgumentSelector:(NSString *)name {
}

- (void)appendMethodArgumentVariable:(NSString *)name {
}

#pragma mark - General objects

- (void)beginTypeDefinition {
}

- (void)appendType:(NSString *)type {
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
}

- (void)cancelCurrentObject {
}

#pragma mark - General information

- (void)setCurrentSourceInfo:(PKToken *)value { _currentSourceInfo = value; }
- (PKToken *)currentSourceInfo { return _currentSourceInfo; }

@end
