//
//  ObjectsCacher.h
//  appledoc
//
//  Created by Tomaz Kragelj on 3.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class Store;
@class InterfaceInfoBase;
@class ObjectInfoBase;

typedef id(^GBCacheBlock)(ObjectInfoBase *obj);
typedef id(^GBMemberCacheBlock)(InterfaceInfoBase *interface, ObjectInfoBase *obj);

/** Helps preparing a cache of objects from a Store.
 
 The class enumerates the given object and asks the client for ID to be used for each encountered object. If the client wants to cache the given object, it should return non-nil from the block, if it wants to ignore the object, it should return nil.
 */
@interface ObjectsCacher : NSObject

+ (NSDictionary *)cacheTopLevelObjectsFromStore:(Store *)store interface:(GBCacheBlock)block;
+ (NSDictionary *)cacheMembersFromStore:(Store *)store classMethod:(GBMemberCacheBlock)classBlock instanceMethod:(GBMemberCacheBlock)instanceBlock property:(GBMemberCacheBlock)propertyBlock;
+ (NSDictionary *)cacheMembersFromInterface:(InterfaceInfoBase *)store classMethod:(GBMemberCacheBlock)classBlock instanceMethod:(GBMemberCacheBlock)instanceBlock property:(GBMemberCacheBlock)propertyBlock;

@end
