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

+ (ObjectLinkInfo *)link:(NSString *)name;

+ (id)mockClass:(NSString *)name;
+ (id)mockCategory:(NSString *)name onClass:(NSString *)className;
+ (id)mockProtocol:(NSString *)name;

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
