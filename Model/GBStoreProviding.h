//
//  GBStoreProviding.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBClassData;
@class GBCategoryData;
@class GBProtocolData;

/** Defines the requirements for store providers.
 
 Store providers are objects handling the storage of in-memory representations of parsed objects.
 */
@protocol GBStoreProviding

/** Registers the given class to the providers data.
 
 If provider doesn't yet have the given class instance registered, the object is added to `classes` list. If the same object is already
 registered, nothing happens.
 
 @warning *Note:* If another instance of the class with the same name is registered, an exception is thrown.
 
 @param class The class to register.
 @exception NSException Thrown if the given class is already registered.
 */
- (void)registerClass:(GBClassData *)class;

/** Registers the given category to the providers data.
 
 If provider doesn't yet have the given category instance registered, the object is added to `categories` list. If the same object is 
 already registered, nothing happens.
 
 @warning *Note:* If another instance of the category with the same name/class name is registered, an exception is thrown.
 
 @param category The category to register.
 @exception NSException Thrown if the given category is already registered.
 */
- (void)registerCategory:(GBCategoryData *)category;

/** Registers the given protocol to the providers data.
 
 If provider doesn't yet have the given protocol instance registered, the object is added to `protocols` list. If the same object is 
 already registered, nothing happens.
 
 @warning *Note:* If another instance of the protocol with the same name name is registered, an exception is thrown.
 
 @param category The category to register.
 @exception NSException Thrown if the given protocol is already registered.
 */
- (void)registerProtocol:(GBProtocolData *)protocol;

/** The list of all registered classes as instances of `GBClassData`. */
@property (readonly) NSSet *classes;

/** The list of all registered categories and extensions as instances of `GBCategoryData`. */
@property (readonly) NSSet *categories;

/** The list of all registered protocols as instances of `GBProtocolData`. */
@property (readonly) NSSet *protocols;

@end
