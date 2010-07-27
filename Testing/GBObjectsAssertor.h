//
//  GBObjectsAssertor.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBIvarData.h"
#import "GBMethodData.h"

// Need to derive from SenTestCase otherwise ST macros used wouldn't work...
@interface GBObjectsAssertor : SenTestCase

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesInstanceComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesClassComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesPropertyComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args;

@end
