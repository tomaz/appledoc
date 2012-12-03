//
//  NSRegularExpression+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

typedef void(^GBRegexMatchBlock)(NSTextCheckingResult *match);
typedef void(^GBRegexAllMatchBlock)(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop);

#pragma mark - 

@interface NSRegularExpression (Appledoc)

+ (NSRegularExpression *)gb_emptyLineMatchingExpression;
+ (NSRegularExpression *)gb_wordMatchingExpression;
+ (NSRegularExpression *)gb_remoteMemberMatchingExpression;
+ (NSRegularExpression *)gb_paramMatchingExpression;	// @param name
+ (NSRegularExpression *)gb_exceptionMatchingExpression; // @exception name
+ (NSRegularExpression *)gb_returnMatchingExpression; // @return
+ (NSRegularExpression *)gb_styledSectionDelimiterMatchingExpression; // @warning|@bug
+ (NSRegularExpression *)gb_methodSectionDelimiterMatchingExpression; // @param|@exception|@return

- (BOOL)gb_firstMatchIn:(NSString *)string match:(GBRegexMatchBlock)matchBlock;
- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options match:(GBRegexMatchBlock)matchBlock;
- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options range:(NSRange)range match:(GBRegexMatchBlock)matchBlock;
- (NSTextCheckingResult *)gb_firstMatchIn:(NSString *)string;

- (BOOL)gb_allMatchesIn:(NSString *)string match:(GBRegexAllMatchBlock)matchBlock;
- (NSArray *)gb_allMatchesIn:(NSString *)string;

@end

#pragma mark - 

@interface NSTextCheckingResult (Appledoc)

- (NSString *)gb_stringAtIndex:(NSUInteger)index in:(NSString *)string;
- (NSString *)gb_prefixFromIndex:(NSUInteger)index in:(NSString *)string;
- (NSString *)gb_remainingStringIn:(NSString *)string;
- (NSRange)gb_remainingRangeIn:(NSString *)string;
- (BOOL)gb_isMatchedAtStart;

@end