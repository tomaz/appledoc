//
//  GBStoreProviding.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import "GBClassData.h"

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

/** The list of all registered classes. */
@property (readonly) NSSet *classes;

@end
