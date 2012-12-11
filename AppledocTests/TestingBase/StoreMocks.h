//
//  StoreMocks.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"

@interface StoreMocks : NSObject

+ (InterfaceInfoBase *)createInterface:(void(^)(InterfaceInfoBase *object))handler;
+ (ClassInfo *)createClass:(void(^)(ClassInfo *object))handler;
+ (CategoryInfo *)createCategory:(void(^)(CategoryInfo *object))handler;
+ (ProtocolInfo *)createProtocol:(void(^)(ProtocolInfo *object))handler;

+ (MethodInfo *)createMethod:(NSString *)uniqueID;
+ (PropertyInfo *)createProperty:(NSString *)uniqueID;
+ (ObjectLinkInfo *)link:(id)nameOrObject;

+ (id)mockClass:(NSString *)name;
+ (id)mockCategory:(NSString *)name onClass:(NSString *)className;
+ (id)mockProtocol:(NSString *)name;

+ (id)mockMethod:(NSString *)uniqueID;
+ (id)mockCommentedMethod:(NSString *)uniqueID;
+ (id)mockProperty:(NSString *)uniqueID;
+ (id)mockCommentedProperty:(NSString *)uniqueID;

+ (void)addCommentToMock:(id)mock;

@end

#pragma mark - 

@interface InterfaceInfoBase (UnitTestsMocks)
- (void)adopt:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
@end

#pragma mark -

@interface CategoryInfo (UnitTestsMocks)
- (void)extend:(NSString *)name;
@end

#pragma mark - 

@interface ClassInfo (UnitTestsMocks)
- (void)derive:(NSString *)name;
@end
