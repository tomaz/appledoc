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

// Need to derive from GHTestCase otherwise GH macros used wouldn't work...
@interface GBObjectsAssertor : GHTestCase

- (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesInstanceComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesClassComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesPropertyComponents:(NSString *)firstItem,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertMethod:(GBMethodData *)method matchesType:(GBMethodType)type start:(NSString *)first components:(va_list)args;

- (void)assertParagraph:(GBCommentParagraph *)paragraph containsItems:(Class)first,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertParagraph:(GBCommentParagraph *)paragraph containsLinks:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertParagraph:(GBCommentParagraph *)paragraph containsTexts:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertParagraph:(GBCommentParagraph *)paragraph containsDescriptions:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;

- (void)assertList:(GBParagraphListItem *)list isOrdered:(BOOL)ordered containsParagraphs:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;
- (void)assertList:(GBParagraphListItem *)list describesHierarchy:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;

- (void)assertDecoratedItem:(GBParagraphItem *)item describesHierarchy:(Class)first,... NS_REQUIRES_NIL_TERMINATION;

- (void)assertLinkItem:(GBParagraphLinkItem *)item hasLink:(NSString *)link context:(id)context member:(id)member local:(BOOL)local;

- (void)assertArgument:(GBCommentArgument *)argument hasName:(NSString *)name descriptions:(NSString *)first,... NS_REQUIRES_NIL_TERMINATION;

@end
