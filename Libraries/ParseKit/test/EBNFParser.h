//
//  EBNFParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface EBNFParser : PKRepetition {
    PKCollectionParser *statementParser;
    PKCollectionParser *exprOrAssignmentParser;
    PKCollectionParser *assignmentParser;
    PKCollectionParser *declarationParser;
    PKCollectionParser *variableParser;
    PKCollectionParser *expressionParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *atomicValueParser;
}
- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *statementParser;
@property (nonatomic, retain) PKCollectionParser *exprOrAssignmentParser;
@property (nonatomic, retain) PKCollectionParser *assignmentParser;
@property (nonatomic, retain) PKCollectionParser *declarationParser;
@property (nonatomic, retain) PKCollectionParser *variableParser;
@property (nonatomic, retain) PKCollectionParser *expressionParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *factorParser;
@property (nonatomic, retain) PKCollectionParser *nextFactorParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *phraseStarParser;
@property (nonatomic, retain) PKCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) PKCollectionParser *phrasePlusParser;
@property (nonatomic, retain) PKCollectionParser *atomicValueParser;
@end
