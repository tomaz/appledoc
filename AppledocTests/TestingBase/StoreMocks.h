//
//  StoreMocks.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"

typedef void(^GBCreateObjectBlock)(id object);

@interface StoreMocks : NSObject

+ (InterfaceInfoBase *)createInterface:(void(^)(InterfaceInfoBase *object))handler;
+ (ClassInfo *)createClass:(void(^)(ClassInfo *object))handler;
+ (CategoryInfo *)createCategory:(void(^)(CategoryInfo *object))handler;
+ (ProtocolInfo *)createProtocol:(void(^)(ProtocolInfo *object))handler;

+ (MethodInfo *)createMethod:(NSString *)uniqueID;
+ (MethodInfo *)createMethod:(NSString *)uniqueID block:(void(^)(MethodInfo *object))handler;
+ (PropertyInfo *)createProperty:(NSString *)uniqueID;
+ (PropertyInfo *)createProperty:(NSString *)uniqueID block:(void(^)(PropertyInfo *object))handler;
+ (ObjectLinkInfo *)link:(id)nameOrObject;

+ (id)mockClass:(NSString *)name block:(GBCreateObjectBlock)handler;
+ (id)mockCategory:(NSString *)name onClass:(NSString *)className block:(GBCreateObjectBlock)handler;
+ (id)mockProtocol:(NSString *)name block:(GBCreateObjectBlock)handler;

+ (id)mockMethod:(NSString *)uniqueID;
+ (id)mockMethod:(NSString *)uniqueID block:(GBCreateObjectBlock)handler;
+ (id)mockProperty:(NSString *)uniqueID;
+ (id)mockProperty:(NSString *)uniqueID block:(GBCreateObjectBlock)handler;

+ (void)addMockCommentTo:(id)objectOrMock;
+ (void)add:(id)classOrMock asBaseClassOf:(id)baseOrMock;
+ (void)add:(id)methodOrMock asClassMethodOf:(id)interfaceOrMock;
+ (void)add:(id)methodOrMock asInstanceMethodOf:(id)interfaceOrMock;
+ (void)add:(id)propertyOrMock asPropertyOf:(id)interfaceOrMock;

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
