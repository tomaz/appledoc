//
//  PKGrammarParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKCollectionParser.h>

@interface PKGrammarParser : NSObject {
    id assembler;
    PKCollectionParser *statementParser;
    PKCollectionParser *declarationParser;
    PKCollectionParser *callbackParser;
    PKCollectionParser *selectorParser;
    PKCollectionParser *exprParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *phraseCardinalityParser;
    PKCollectionParser *cardinalityParser;
    PKCollectionParser *primaryExprParser;
    PKCollectionParser *negatedPrimaryExprParser;
    PKCollectionParser *barePrimaryExprParser;
    PKCollectionParser *predicateParser;
    PKCollectionParser *intersectionParser;
    PKCollectionParser *differenceParser;
    PKCollectionParser *atomicValueParser;
    PKCollectionParser *parserParser;
    PKCollectionParser *discardParser;
    PKCollectionParser *patternParser;
    PKCollectionParser *delimitedStringParser;
    PKParser *literalParser;
    PKParser *variableParser;
    PKParser *constantParser;
}

- (id)initWithAssembler:(id)a;

@property (nonatomic, retain) PKCollectionParser *statementParser;
@property (nonatomic, retain) PKCollectionParser *declarationParser;
@property (nonatomic, retain) PKCollectionParser *callbackParser;
@property (nonatomic, retain) PKCollectionParser *selectorParser;
@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *factorParser;
@property (nonatomic, retain) PKCollectionParser *nextFactorParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *phraseStarParser;
@property (nonatomic, retain) PKCollectionParser *phrasePlusParser;
@property (nonatomic, retain) PKCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) PKCollectionParser *phraseCardinalityParser;
@property (nonatomic, retain) PKCollectionParser *cardinalityParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *negatedPrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *barePrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *intersectionParser;
@property (nonatomic, retain) PKCollectionParser *differenceParser;
@property (nonatomic, retain) PKCollectionParser *atomicValueParser;
@property (nonatomic, retain) PKCollectionParser *parserParser;
@property (nonatomic, retain) PKCollectionParser *discardParser;
@property (nonatomic, retain) PKCollectionParser *patternParser;
@property (nonatomic, retain) PKCollectionParser *delimitedStringParser;
@property (nonatomic, retain) PKParser *literalParser;
@property (nonatomic, retain) PKParser *variableParser;
@property (nonatomic, retain) PKParser *constantParser;
@property (nonatomic, retain, readonly) PKParser *whitespaceParser;
@property (nonatomic, retain, readonly) PKCollectionParser *optionalWhitespaceParser;
@end
