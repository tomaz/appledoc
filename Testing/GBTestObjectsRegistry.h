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

+ (id)realSettingsProvider;
+ (OCMockObject *)mockSettingsProvider;
+ (void)settingsProvider:(OCMockObject *)provider keepObjects:(BOOL)objects keepMembers:(BOOL)members;

+ (GBIvarData *)ivarWithComponents:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

+ (GBMethodData *)instanceMethodWithName:(NSString *)name comment:(id)comment;
+ (GBMethodData *)instanceMethodWithArguments:(GBMethodArgument *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)classMethodWithArguments:(GBMethodArgument *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)instanceMethodWithNames:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)classMethodWithNames:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBMethodData *)propertyMethodWithArgument:(NSString *)name;
+ (GBMethodArgument *)typedArgumentWithName:(NSString *)name;

+ (GBStore *)store;
+ (GBStore *)storeWithClassWithComment:(id)comment;
+ (GBStore *)storeWithCategoryWithComment:(id)comment;
+ (GBStore *)storeWithProtocolWithComment:(id)comment;
+ (GBStore *)storeWithDocumentWithComment:(id)comment;
+ (GBStore *)storeWithObjects:(id)first, ... NS_REQUIRES_NIL_TERMINATION;
+ (GBStore *)storeByPerformingSelector:(SEL)selector withObject:(id)object;

+ (GBClassData *)classWithName:(NSString *)name methods:(GBMethodData *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBCategoryData *)categoryWithName:(NSString *)name className:(NSString *)className methods:(GBMethodData *)first,... NS_REQUIRES_NIL_TERMINATION;
+ (GBProtocolData *)protocolWithName:(NSString *)name methods:(GBMethodData *)first,... NS_REQUIRES_NIL_TERMINATION;

@end
