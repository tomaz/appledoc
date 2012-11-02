//
//  NSRegularExpression+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

typedef void(^GBRegexMatchBlock)(NSTextCheckingResult *match);

#pragma mark - 

@interface NSRegularExpression (Appledoc)

+ (NSRegularExpression *)gb_paramMatchingRegularExpression;	// @param name
+ (NSRegularExpression *)gb_argumentMatchingRegularExpression; // @param|@exception|@return

- (BOOL)gb_firstMatchIn:(NSString *)string match:(GBRegexMatchBlock)matchBlock;
- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options match:(GBRegexMatchBlock)matchBlock;
- (BOOL)gb_firstMatchIn:(NSString *)string options:(NSRegularExpressionOptions)options range:(NSRange)range match:(GBRegexMatchBlock)matchBlock;
- (NSArray *)gb_allMatchesIn:(NSString *)string;

@end

#pragma mark - 

@interface NSTextCheckingResult (Appledoc)

- (NSString *)gb_stringAtIndex:(NSUInteger)index in:(NSString *)string;
- (NSString *)gb_remainingStringIn:(NSString *)string;

@end