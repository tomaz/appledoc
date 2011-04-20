//
//  PKSyntaxHighlighter.h
//  HTTPClient
//
//  Created by Todd Ditchendorf on 12/26/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKParser;
@class PKTokenizer;
@class PKParserFactory;
@class TDMiniCSSAssembler;
@class TDGenericAssembler;

@interface TDSyntaxHighlighter : NSObject {
    PKParserFactory *parserFactory;
    PKParser *miniCSSParser;
    TDMiniCSSAssembler *miniCSSAssembler;
    TDGenericAssembler *genericAssembler;
    BOOL cacheParsers;
    NSMutableDictionary *parserCache;
    NSMutableDictionary *tokenizerCache;
}
- (NSAttributedString *)highlightedStringForString:(NSString *)s ofGrammar:(NSString *)grammarName;

@property (nonatomic) BOOL cacheParsers; // default is NO
@end
