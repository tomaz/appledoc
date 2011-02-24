//
//  GBObjectsAssertor.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBIvarData;
@class GBMethodData;
@class GBCommentParagraph;

#define GBDecorationTypeNone	9999
#define GBNULL [NSNull null]
#define GBEND GBNULL

// Need to derive from GHTestCase otherwise GH macros used wouldn't work...
@interface GBObjectsAssertor : GHTestCase

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args;
- (void)assertMethod:(GBMethodData *)method matchesInstanceComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesClassComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesPropertyComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertFormattedComponents:(NSArray *)components match:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;

- (void)assertCommentComponents:(GBCommentComponentsList *)components matchesValues:(NSString *)first values:(va_list)args;
- (void)assertCommentComponents:(GBCommentComponentsList *)components matchesStringValues:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
- (void)assertComment:(GBComment *)comment matchesShortDesc:(NSString *)shortValue longDesc:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethodArguments:(NSArray *)arguments matches:(NSString *)name, ... NS_REQUIRES_NIL_TERMINATION;

@end
