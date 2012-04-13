//
//  InterfaceInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "InterfaceInfoBase.h"

@implementation InterfaceInfoBase

@end

#pragma mark - 

@implementation InterfaceInfoBase (Registrations)

#pragma mark - Interface level registrations

- (void)appendAdoptedProtocolWithName:(NSString *)name {
	LogStoVerbose(@"Appending adopted protocol %@...", name);
}

#pragma mark - Method groups

- (void)beginMethodGroup {
	LogStoInfo(@"Starting method group...");
}

- (void)appendMethodGroupDescription:(NSString *)description {
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
	LogStoInfo(@"Starting property definition...");
}

- (void)beginPropertyAttributes {
	LogStoInfo(@"Starting property attributes...");
}

- (void)appendPropertyName:(NSString *)name {
}

#pragma mark - Methods

- (void)beginMethodDefinition {
	LogStoInfo(@"Starting method definition...");
}

- (void)appendMethodType:(NSString *)type {
}

- (void)beginMethodArgument {
	LogStoVerbose(@"Starting method argument...");
}

- (void)appendMethodArgumentSelector:(NSString *)name {
}

- (void)appendMethodArgumentVariable:(NSString *)name {
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
}

- (void)cancelCurrentObject {
}

@end
