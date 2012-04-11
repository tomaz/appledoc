//
//  StoreRegistrations.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Store category declaring all API for registering data.
 
 @warning **Note:** We declare this category on NSObject to avoid compiler warnings. Note that not various store objects, including Store itself, only implement a subset of this API. Although Store accepts all these messages, it forwards them to the object that is being registered currently if it doesn't recognize them.
 */
@interface NSObject (StoreRegistrations)

#pragma mark - Classes, categories and protocols

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived;
- (void)beginExtensionForClassWithName:(NSString *)name;
- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name;
- (void)beginProtocolWithName:(NSString *)name;
- (void)appendAdoptedProtocolWithName:(NSString *)name;

#pragma mark - Method groups

- (void)beginMethodGroup;
- (void)appendMethodGroupDescription:(NSString *)description;

#pragma mark - Properties

- (void)beginPropertyDefinition;
- (void)beginPropertyAttributes;
- (void)appendPropertyName:(NSString *)name;

#pragma mark - Methods

- (void)beginMethodDefinition;
- (void)appendMethodType:(NSString *)type;
- (void)beginMethodArgument;
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
- (void)appendConstantType:(NSString *)type;
- (void)appendConstantName:(NSString *)name;

#pragma mark - General objects

- (void)beginTypeDefinition;
- (void)appendType:(NSString *)type;

#pragma mark - Finalizing registrations

- (void)endCurrentObject;
- (void)cancelCurrentObject;

#pragma mark - General information

@property (nonatomic, strong) PKToken *currentSourceInfo;

@end
