//
//  GBTestObjectsRegistry.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBStore.h"

@interface GBTestObjectsRegistry : NSObject

+ (OCMockObject *)mockSettingsProvider;

+ (GBIvarData *)ivarWithComponents:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

+ (GBMethodData *)instanceMethodWithArguments:(GBMethodArgument *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)classMethodWithArguments:(GBMethodArgument *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)instanceMethodWithNames:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)classMethodWithNames:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)propertyMethodWithArgument:(NSString *)name;
+ (GBMethodArgument *)typedArgumentWithName:(NSString *)name;

+ (GBStore *)storeWithClassWithComment:(id)comment;
+ (GBStore *)storeWithCategoryWithComment:(id)comment;
+ (GBStore *)storeWithProtocolWithComment:(id)comment;
+ (GBStore *)storeByPerformingSelector:(SEL)selector withObject:(id)object;
+ (GBMethodData *)instanceMethodWithName:(NSString *)name comment:(id)comment;

@end
