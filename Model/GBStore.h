//
//  GBStore.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBClassData;
@class GBCategoryData;
@class GBProtocolData;
@class GBDocumentData;
@class GBTypedefEnumData;
@class GBTypedefBlockData;

/** Implements the application's in-memory objects data store.
 
 Store handles the storage of in-memory representations of parsed objects and enables a single entry point for later processing.
 */
@interface GBStore : NSObject{
	@private
	NSMutableSet *_classes;
	NSMutableDictionary *_classesByName;
	NSMutableSet *_categories;
	NSMutableDictionary *_categoriesByName;
	NSMutableSet *_protocols;
	NSMutableDictionary *_protocolsByName;
	NSMutableSet *_documents;
	NSMutableDictionary *_documentsByName;
	NSMutableSet *_typedefEnums;
	NSMutableDictionary *_typedefEnumsByName;
    NSMutableSet *_typedefBlocks;
    NSMutableDictionary *_typedefBlocksByName;
    NSMutableSet *_customDocuments;
	NSMutableDictionary *_customDocumentsByKey;
}

+ (instancetype) sharedStore;

///---------------------------------------------------------------------------------------
/// @name Registrations handling
///---------------------------------------------------------------------------------------

/** Registers the given class to the store data.
 
 If store doesn't yet have the given class instance registered, the object is added to `classes` list. If the same instance is already registered, nothing happens.
 
 @warning *Note:* If another instance of the class with the same name is registered, an exception is thrown.
 
 @param class The class to register.
 @exception NSException Thrown if the given class is already registered.
 @see registerCategory:
 @see registerProtocol:
 @see unregisterTopLevelObject:
 @see classWithName:
 @see classes
 */
- (void)registerClass:(GBClassData *)class;

/** Registers the given category to the store data.
 
 If store doesn't yet have the given category instance registered, the object is added to `categories` list. If the same instance is already registered, nothing happens.
 
 @warning *Note:* If another instance of the category with the same name/class name is registered, an exception is thrown.
 
 @param category The category to register.
 @exception NSException Thrown if the given category is already registered.
 @see registerClass:
 @see registerProtocol:
 @see unregisterTopLevelObject:
 @see categoryWithName:
 @see categories
 */
- (void)registerCategory:(GBCategoryData *)category;

/** Registers the given protocol to the store data.
 
 If store doesn't yet have the given protocol instance registered, the object is added to `protocols` list. If the same instance is already registered, nothing happens.
 
 @warning *Note:* If another instance of the protocol with the same name is registered, an exception is thrown.
 
 @param protocol The protocol to register.
 @exception NSException Thrown if the given protocol is already registered.
 @see registerClass:
 @see registerCategory:
 @see unregisterTopLevelObject:
 @see protocolWithName:
 @see protocols
 */
- (void)registerProtocol:(GBProtocolData *)protocol;

/** Registers the given static document to the store data.
 
 If store doesn't yet have the given document instance registered, the object is added to `documents` list. If the same instance is already regsitered, nothing happens. The document is also made available through `documentWithName` after being registered; to simplify the rest of the code, `-template` prefix can be ommited when seaching!
 
 @warning *Note:* If another instance of the document with the same path is registered, an exception is thrown.
 
 @param document The document to register.
 @exception NSException Thrown if the given document is already registered.
 @see documentWithName:
 @see documents
 */
- (void)registerDocument:(GBDocumentData *)document;

/** Registers the given custom document to the store data.
 
 If store doesn't yet have the given document registered, the object is added to custom documents list by it's key. If the list already contains the object, exception is raised.
 
 @param document The document to register.
 @param key The key to register document with.
 @exception NSException Thrown if the given document is already registered.
 @see customDocumentWithKey:
 */
- (void)registerCustomDocument:(GBDocumentData *)document withKey:(id)key;

/** Unregisters the given class, category or protocol.
 
 If the object is not part of the store, nothing happens.
 
 @param object The object to remove.
 @see registerClass:
 @see registerCategory:
 @see registerProtocol:
 */
- (void)unregisterTopLevelObject:(id)object;

-(void)registerTypedefEnum:(GBTypedefEnumData *)typedefEnum;

-(void)registerTypedefBlock:(GBTypedefBlockData *)typedefBlock;

///---------------------------------------------------------------------------------------
/// @name Data handling
///---------------------------------------------------------------------------------------

/** Returns the class instance that matches the given name.
 
 If no registered class matches the given name, `nil` is returned.
 
 @param name The name of the class to return.
 @return Returns class instance or `nil` if no match is found.
 @see categoryWithName:
 @see protocolWithName:
 @see classes
 */
- (GBClassData *)classWithName:(NSString *)name;

/** Returns the category instance that matches the given name.
 
 If no registered category matches the given name, `nil` is returned.
 
 @param name The name of the category to return.
 @return Returns category instance or `nil` if no match is found.
 @see classWithName:
 @see protocolWithName:
 @see categories
 */
- (GBCategoryData *)categoryWithName:(NSString *)name;

/** Returns the protocol instance that matches the given name.
 
 If no registered protocol matches the given name, `nil` is returned.
 
 @param name The name of the protocol to return.
 @return Returns protocol instance or `nil` if no match is found.
 @see classWithName:
 @see categoryWithName:
 @see protocols
 */
- (GBProtocolData *)protocolWithName:(NSString *)name;

- (GBTypedefEnumData *)typedefEnumWithName:(NSString *)name;

- (GBTypedefBlockData *)typedefBlockWithName:(NSString *)name;

/** Returns the document instance that matches the given path.
 
 If no registered document matches the given path, `nil` is returned.
 
 @param path Full path of the document to return.
 @return Returns document instance or `nil` if no match is found.
 @see documents
 */
- (GBDocumentData *)documentWithName:(NSString *)path;

/** Returns the custom document that matches the given key.
 
 If no registered custom document matches the given key, `nil` is returned.
 
 @param key The key of the document.
 @return Returns document instance or `nil` if no match is found.
 @see customDocuments
 */
- (GBDocumentData *)customDocumentWithKey:(id)key;

/** The list of all registered classes as instances of `GBClassData`.
 
 @see classWithName:
 @see registerClass:
 */
@property (readonly) NSSet *classes;

/** The list of all registered categories and extensions as instances of `GBCategoryData`.
 
 @see categoryWithName:
 @see registerCategory:
 */
@property (readonly) NSSet *categories;

/** The list of all registered protocols as instances of `GBProtocolData`.
 
 @see protocolWithName:
 @see registerProtocol:
 */
@property (readonly) NSSet *protocols;

/** The list of all registered constants 
 
 @see typedefEnumWithName
 @see registerTypedefEnum
 */
@property (readonly) NSSet *constants;

/** The list of all registered blocks
 
 @see typedefBlockWithName
 @see registerTypedefBlock
 */
@property (readonly) NSSet *blocks;

/** The list of all registered documents as instances of `GBDocumentData`.
 
 @see documentWithName:
 @see registerDocument:
 */
@property (readonly) NSSet *documents;

/** The list of all registered custom documents as instances of `GBDocumentData`.
 
 @see customDocumentWithKey:
 @see registerCustomDocument:withKey:
 */
@property (readonly) NSSet *customDocuments;

///---------------------------------------------------------------------------------------
/// @name Helper methods
///---------------------------------------------------------------------------------------

/** Returns all registered classes sorted by their name. */
- (NSArray *)documentsSortedByName;

/** Returns all registered classes sorted by their name. */
- (NSArray *)classesSortedByName;

/** Returns all registered categories sorted by their name. */
- (NSArray *)categoriesSortedByName;

/** Returns all registered constants sorted by their name. */
- (NSArray *)constantsSortedByName;

/** Returns all registered blocks sorted by their name. */
- (NSArray *)blocksSortedByName;

/** Returns all registered protocols sorted by their name. */
- (NSArray *)protocolsSortedByName;

@end
