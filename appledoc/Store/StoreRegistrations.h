//
//  StoreRegistrations.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class PKToken;

/** Defines the requirements for a Store registrar.
 
 Store registrar is an object that knows how to handle nested registrations - it works on the principle of a stack: as new objects are being registered, the registrar should decide whether they need to be pushed to registration stack and it should do so. Similary, when child objects are finished, they should be popped from the stack. And while there is at least one child object on the stack, all registration methods should be forwarded to it.
 */
@protocol StoreRegistrar <NSObject>

- (BOOL)expectCurrentRegistrationObjectRespondTo:(SEL)selector;
- (BOOL)doesCurrentRegistrationObjectRespondTo:(SEL)selector;
- (void)pushRegistrationObject:(id)object;
- (id)popRegistrationObject;
@property (nonatomic, readonly) id currentRegistrationObject;

@end

/** Store category declaring all API for registering data.
 
 @warning **Note:** We declare this category on NSObject to avoid compiler warnings. Note that various store objects, including helper objects and abstract base classes, only implement a subset of this API. Although Store accepts all these messages, it forwards them to the object that is being registered currently if it doesn't recognize them. And if current object uses further children to register specific parts, it should also forward all possible messages to its current registration object. Take a look at ObjectInfoBase which implements forwarding API - it's used as a base class for Store and all info classes that use children for registrations.
 */
@interface NSObject (StoreRegistrations)

#pragma mark - Classes, categories and protocols

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived;
- (void)beginExtensionForClassWithName:(NSString *)name;
- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name;
- (void)beginProtocolWithName:(NSString *)name;
- (void)appendAdoptedProtocolWithName:(NSString *)name;

#pragma mark - Method groups

- (void)appendMethodGroupWithDescription:(NSString *)description;

#pragma mark - Properties

- (void)beginPropertyDefinition;
- (void)beginPropertyAttributes;
- (void)beginPropertyTypes;
- (void)beginPropertyDescriptors;
- (void)appendPropertyName:(NSString *)name;

#pragma mark - Methods

- (void)beginMethodDefinitionWithType:(NSString *)type;
- (void)beginMethodResults;
- (void)beginMethodArgument;
- (void)beginMethodArgumentTypes;
- (void)beginMethodDescriptors;
- (void)appendMethodArgumentSelector:(NSString *)name;
- (void)appendMethodArgumentVariable:(NSString *)name;

#pragma mark - Enumerations

- (void)beginEnumeration;
- (void)appendEnumerationItem:(NSString *)name;
- (void)appendEnumerationValue:(NSString *)value;

#pragma mark - Structs

- (void)beginStruct;

#pragma mark - Constants

- (void)beginConstant;
- (void)beginConstantTypes;
- (void)beginConstantDescriptors;
- (void)appendConstantName:(NSString *)name;

#pragma mark - General objects

- (void)appendType:(NSString *)type;
- (void)appendAttribute:(NSString *)attribute;
- (void)appendDescriptor:(NSString *)descriptor;

#pragma mark - Finalizing registrations

- (void)endCurrentObject;
- (void)cancelCurrentObject;

#pragma mark - General information

@property (nonatomic, strong) PKToken *currentSourceInfo;

@end
