//
//  PKRegularParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface TDRegularParser : PKSequence {
    PKCollectionParser *expressionParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *letterOrDigitParser;
}
+ (id)parserFromGrammar:(NSString *)s;

@property (retain) PKCollectionParser *expressionParser;
@property (retain) PKCollectionParser *termParser;
@property (retain) PKCollectionParser *orTermParser;
@property (retain) PKCollectionParser *factorParser;
@property (retain) PKCollectionParser *nextFactorParser;
@property (retain) PKCollectionParser *phraseParser;
@property (retain) PKCollectionParser *phraseStarParser;
@property (retain) PKCollectionParser *phrasePlusParser;
@property (retain) PKCollectionParser *phraseQuestionParser;
@property (retain) PKCollectionParser *letterOrDigitParser;
@end
