//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PKGrammarParser.h"
#import <ParseKit/ParseKit.h>

@interface NSObject (PKGrammarParserAdditions)
- (void)didMatchStatement:(PKAssembly *)a;
- (void)didMatchCallback:(PKAssembly *)a;
- (void)didMatchExpression:(PKAssembly *)a;
- (void)didMatchAnd:(PKAssembly *)a;
- (void)didMatchIntersection:(PKAssembly *)a;    
- (void)didMatchDifference:(PKAssembly *)a;
- (void)didMatchPatternOptions:(PKAssembly *)a;
- (void)didMatchPattern:(PKAssembly *)a;
- (void)didMatchDiscard:(PKAssembly *)a;
- (void)didMatchLiteral:(PKAssembly *)a;
- (void)didMatchVariable:(PKAssembly *)a;
- (void)didMatchConstant:(PKAssembly *)a;
- (void)didMatchDelimitedString:(PKAssembly *)a;
- (void)didMatchNum:(PKAssembly *)a;
- (void)didMatchStar:(PKAssembly *)a;
- (void)didMatchPlus:(PKAssembly *)a;
- (void)didMatchQuestion:(PKAssembly *)a;
- (void)didMatchPhraseCardinality:(PKAssembly *)a;
- (void)didMatchCardinality:(PKAssembly *)a;
- (void)didMatchOr:(PKAssembly *)a;
- (void)didMatchNegation:(PKAssembly *)a;
@end

@interface PKGrammarParser ()
- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;
@end

@implementation PKGrammarParser

- (id)initWithAssembler:(id)a {
    if (self = [super init]) {
        assembler = a;
    }
    return self;
}


- (void)dealloc {
    assembler = nil; // appease clang static analyzer

    PKReleaseSubparserTree(statementParser);
    PKReleaseSubparserTree(exprParser);

    self.statementParser = nil;
    self.declarationParser = nil;
    self.callbackParser = nil;
    self.selectorParser = nil;
    self.exprParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.phraseCardinalityParser = nil;
    self.cardinalityParser = nil;
    self.primaryExprParser = nil;
    self.negatedPrimaryExprParser = nil;
    self.barePrimaryExprParser = nil;
    self.predicateParser = nil;
    self.intersectionParser = nil;
    self.differenceParser = nil;
    self.atomicValueParser = nil;
    self.parserParser = nil;
    self.discardParser = nil;
    self.patternParser = nil;
    self.delimitedStringParser = nil;
    self.literalParser = nil;
    self.variableParser = nil;
    self.constantParser = nil;
    [super dealloc];
}


- (PKAlternation *)zeroOrOne:(PKParser *)p {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[PKEmpty empty]];
    [a add:p];
    return a;
}


- (PKSequence *)oneOrMore:(PKParser *)p {
    PKSequence *s = [PKSequence sequence];
    [s add:p];
    [s add:[PKRepetition repetitionWithSubparser:p]];
    return s;
}


// @start               = statement*;
// satement             = S* declaration S* '=' expr;
// callback             = S* '(' S* selector S* ')';
// selector             = Word ':';
// expr                 = S* term orTerm* S*;
// term                 = factor nextFactor*;
// orTerm               = S* '|' S* term;
// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
// nextFactor           = S factor;

// phrase               = primaryExpr predicate*;
// phraseStar           = phrase S* '*';
// phrasePlus           = phrase S* '+';
// phraseQuestion       = phrase S* '?';
// phraseCardinality    = phrase S* cardinality;
// cardinality          = '{' S* Number (S* ',' S* Number)? S* '}';

// predicate            = S* (intersection | difference);
// intersection         = '&' S* primaryExpr;
// difference           = '-' S* primaryExpr;

// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
// negatedPrimaryExpr   = '~' barePrimaryExpr;
// barePrimaryExpr      = atomicValue | '(' expr ')';
// atomicValue          = parser discard?;
// parser               = pattern | literal | variable | constant | delimitedString;
// discard              = S* '!';
// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
// literal              = QuotedString;
// variable             = LowercaseWord;
// constant             = UppercaseWord;


// satement             = S* declaration S* '=' expr;
- (PKCollectionParser *)statementParser {
    if (!statementParser) {
        self.statementParser = [PKSequence sequence];
        statementParser.name = @"statement";
        [statementParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:self.declarationParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKSymbol symbolWithString:@"="]];
        
        // accept any tokens in the parser expr the first time around. just gather tokens for later
        [tr add:[self oneOrMore:[PKAny any]]];
        
        [statementParser add:tr];
        [statementParser setAssembler:assembler selector:@selector(didMatchStatement:)];
    }
    return statementParser;
}


// declaration          = Word callback?;
- (PKCollectionParser *)declarationParser {
    if (!declarationParser) {
        self.declarationParser = [PKSequence sequence];
        declarationParser.name = @"declaration";
        [declarationParser add:[PKWord word]];
        [declarationParser add:[self zeroOrOne:self.callbackParser]];
    }
    return declarationParser;
}


// callback             = S* '(' S* selector S* ')';
- (PKCollectionParser *)callbackParser {
    if (!callbackParser) {
        self.callbackParser = [PKSequence sequence];
        callbackParser.name = @"callback";
        [callbackParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"("] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.selectorParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [callbackParser add:tr];
        [callbackParser setAssembler:assembler selector:@selector(didMatchCallback:)];
    }
    return callbackParser;
}


// selector             = Word ':';
- (PKCollectionParser *)selectorParser {
    if (!selectorParser) {
        self.selectorParser = [PKTrack track];
        selectorParser.name = @"selector";
        [selectorParser add:[PKLowercaseWord word]];
        [selectorParser add:[[PKSymbol symbolWithString:@":"] discard]];
    }
    return selectorParser;
}


// expr        = S* term orTerm* S*;
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        exprParser.name = @"expr";
        [exprParser add:self.optionalWhitespaceParser];
        [exprParser add:self.termParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
        [exprParser add:self.optionalWhitespaceParser];
        [exprParser setAssembler:assembler selector:@selector(didMatchExpression:)];
    }
    return exprParser;
}


// term                = factor nextFactor*;
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
        [termParser setAssembler:assembler selector:@selector(didMatchAnd:)];
    }
    return termParser;
}


// orTerm               = S* '|' S* term;
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        [orTermParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"|"]]; // preserve as fence
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.termParser];
        
        [orTermParser add:tr];
        [orTermParser setAssembler:assembler selector:@selector(didMatchOr:)];
    }
    return orTermParser;
}


// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKAlternation alternation];
        factorParser.name = @"factor";
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phrasePlusParser];
        [factorParser add:self.phraseQuestionParser];
        [factorParser add:self.phraseCardinalityParser];
    }
    return factorParser;
}


// nextFactor           = S factor;
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKSequence sequence];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.whitespaceParser];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.phraseParser];
        [a add:self.phraseStarParser];
        [a add:self.phrasePlusParser];
        [a add:self.phraseQuestionParser];
        [a add:self.phraseCardinalityParser];
        
        [nextFactorParser add:a];
    }
    return nextFactorParser;
}


// phrase               = primaryExpr predicate*;
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [PKSequence sequence];
        phraseParser.name = @"phrase";
        [phraseParser add:self.primaryExprParser];
        [phraseParser add:[PKRepetition repetitionWithSubparser:self.predicateParser]];
    }
    return phraseParser;
}


// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.negatedPrimaryExprParser];
        [primaryExprParser add:self.barePrimaryExprParser];
    }
    return primaryExprParser;
}


// negatedPrimaryExpr   = '~' barePrimaryExpr;
- (PKCollectionParser *)negatedPrimaryExprParser {
    if (!negatedPrimaryExprParser) {
        self.negatedPrimaryExprParser = [PKSequence sequence];
        negatedPrimaryExprParser.name = @"negatedPrimaryExpr";
        [negatedPrimaryExprParser add:[[PKLiteral literalWithString:@"~"] discard]];
        [negatedPrimaryExprParser add:self.barePrimaryExprParser];
        [negatedPrimaryExprParser setAssembler:assembler selector:@selector(didMatchNegation:)];
    }
    return negatedPrimaryExprParser;
}


// barePrimaryExpr          = atomicValue | '(' expr ')';
- (PKCollectionParser *)barePrimaryExprParser {
    if (!barePrimaryExprParser) {
        self.barePrimaryExprParser = [PKAlternation alternation];
        barePrimaryExprParser.name = @"barePrimaryExpr";
        [barePrimaryExprParser add:self.atomicValueParser];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:self.exprParser];
        [s add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [barePrimaryExprParser add:s];
    }
    return barePrimaryExprParser;
}


// predicate            = S* (intersection | difference);
- (PKCollectionParser *)predicateParser {
    if (!predicateParser) {
        self.predicateParser = [PKSequence sequence];
        predicateParser.name = @"predicate";
        [predicateParser add:self.optionalWhitespaceParser];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.intersectionParser];
        [a add:self.differenceParser];
        
        [predicateParser add:a];
    }
    return predicateParser;
}


// intersection         = '&' S* primaryExpr;
- (PKCollectionParser *)intersectionParser {
    if (!intersectionParser) {
        self.intersectionParser = [PKTrack track];
        intersectionParser.name = @"intersection";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"&"] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [intersectionParser add:tr];
        [intersectionParser setAssembler:assembler selector:@selector(didMatchIntersection:)];
    }
    return intersectionParser;
}


// difference            = '-' S* primaryExpr;
- (PKCollectionParser *)differenceParser {
    if (!differenceParser) {
        self.differenceParser = [PKTrack track];
        differenceParser.name = @"difference";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"-"] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [differenceParser add:tr];
        [differenceParser setAssembler:assembler selector:@selector(didMatchDifference:)];
    }
    return differenceParser;
}


// phraseStar           = phrase S* '*';
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:self.optionalWhitespaceParser];
        [phraseStarParser add:[[PKSymbol symbolWithString:@"*"] discard]];
        [phraseStarParser setAssembler:assembler selector:@selector(didMatchStar:)];
    }
    return phraseStarParser;
}


// phrasePlus           = phrase S* '+';
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:self.optionalWhitespaceParser];
        [phrasePlusParser add:[[PKSymbol symbolWithString:@"+"] discard]];
        [phrasePlusParser setAssembler:assembler selector:@selector(didMatchPlus:)];
    }
    return phrasePlusParser;
}


// phraseQuestion       = phrase S* '?';
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:self.optionalWhitespaceParser];
        [phraseQuestionParser add:[[PKSymbol symbolWithString:@"?"] discard]];
        [phraseQuestionParser setAssembler:assembler selector:@selector(didMatchQuestion:)];
    }
    return phraseQuestionParser;
}


// phraseCardinality    = phrase S* cardinality;
- (PKCollectionParser *)phraseCardinalityParser {
    if (!phraseCardinalityParser) {
        self.phraseCardinalityParser = [PKSequence sequence];
        phraseCardinalityParser.name = @"phraseCardinality";
        [phraseCardinalityParser add:self.phraseParser];
        [phraseCardinalityParser add:self.optionalWhitespaceParser];
        [phraseCardinalityParser add:self.cardinalityParser];
        [phraseCardinalityParser setAssembler:assembler selector:@selector(didMatchPhraseCardinality:)];
    }
    return phraseCardinalityParser;
}


// cardinality          = '{' S* Number (S* ',' S* Number)? S* '}';
- (PKCollectionParser *)cardinalityParser {
    if (!cardinalityParser) {
        self.cardinalityParser = [PKSequence sequence];
        cardinalityParser.name = @"cardinality";
        
        PKSequence *commaNum = [PKSequence sequence];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[[PKSymbol symbolWithString:@","] discard]];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[PKNumber number]];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"{"]]; // serves as fence. dont discard
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKNumber number]];
        [tr add:[self zeroOrOne:commaNum]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[PKSymbol symbolWithString:@"}"] discard]];
        
        [cardinalityParser add:tr];
        [cardinalityParser setAssembler:assembler selector:@selector(didMatchCardinality:)];
    }
    return cardinalityParser;
}


// atomicValue          = parser discard?;
- (PKCollectionParser *)atomicValueParser {
    if (!atomicValueParser) {
        self.atomicValueParser = [PKSequence sequence];
        atomicValueParser.name = @"atomicValue";
        [atomicValueParser add:self.parserParser];
        [atomicValueParser add:[self zeroOrOne:self.discardParser]];
    }
    return atomicValueParser;
}


// parser              = pattern | literal | variable | constant | delimitedString;
- (PKCollectionParser *)parserParser {
    if (!parserParser) {
        self.parserParser = [PKAlternation alternation];
        parserParser.name = @"parser";
        [parserParser add:self.patternParser];
        [parserParser add:self.literalParser];
        [parserParser add:self.variableParser];
        [parserParser add:self.constantParser];
        [parserParser add:self.delimitedStringParser];
    }
    return parserParser;
}


// discard              = S* '!';
- (PKCollectionParser *)discardParser {
    if (!discardParser) {
        self.discardParser = [PKSequence sequence];
        discardParser.name = @"discard";
        [discardParser add:self.optionalWhitespaceParser];
        [discardParser add:[[PKSymbol symbolWithString:@"!"] discard]];
        [discardParser setAssembler:assembler selector:@selector(didMatchDiscard:)];
    }
    return discardParser;
}


// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
- (PKCollectionParser *)patternParser {
    if (!patternParser) {
        patternParser.name = @"pattern";
        self.patternParser = [PKSequence sequence];
        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/"]];
        
        PKParser *opts = [PKPattern patternWithString:@"[imxsw]+" options:PKPatternOptionsNone];
        PKIntersection *inter = [PKIntersection intersection];
        [inter add:[PKWord word]];
        [inter add:opts];
        [inter setAssembler:assembler selector:@selector(didMatchPatternOptions:)];
        
        [patternParser add:[self zeroOrOne:inter]];
        [patternParser setAssembler:assembler selector:@selector(didMatchPattern:)];
    }
    return patternParser;
}


// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
- (PKCollectionParser *)delimitedStringParser {
    if (!delimitedStringParser) {
        self.delimitedStringParser = [PKTrack track];
        delimitedStringParser.name = @"delimitedString";
        
        PKSequence *secondArg = [PKSequence sequence];
        [secondArg add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@","] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKQuotedString quotedString]]; // endMarker
        [secondArg add:tr];
        
        [delimitedStringParser add:[[PKLiteral literalWithString:@"DelimitedString"] discard]];
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[PKSymbol symbolWithString:@"("]]; // preserve as fence
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[PKQuotedString quotedString]]; // startMarker
        [delimitedStringParser add:[self zeroOrOne:secondArg]];
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [delimitedStringParser setAssembler:assembler selector:@selector(didMatchDelimitedString:)];
    }
    return delimitedStringParser;
}


// literal              = QuotedString;
- (PKParser *)literalParser {
    if (!literalParser) {
        self.literalParser = [PKQuotedString quotedString];
        [literalParser setAssembler:assembler selector:@selector(didMatchLiteral:)];
    }
    return literalParser;
}


// variable             = LowercaseWord;
- (PKParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [PKLowercaseWord word];
        variableParser.name = @"variable";
        [variableParser setAssembler:assembler selector:@selector(didMatchVariable:)];
    }
    return variableParser;
}


// constant             = UppercaseWord;
- (PKParser *)constantParser {
    if (!constantParser) {
        self.constantParser = [PKUppercaseWord word];
        constantParser.name = @"constant";
        [constantParser setAssembler:assembler selector:@selector(didMatchConstant:)];
    }
    return constantParser;
}


- (PKParser *)whitespaceParser {
    return [[PKWhitespace whitespace] discard];
}


- (PKParser *)optionalWhitespaceParser {
    return [PKRepetition repetitionWithSubparser:self.whitespaceParser];
}

@synthesize statementParser;
@synthesize declarationParser;
@synthesize callbackParser;
@synthesize selectorParser;
@synthesize exprParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize phraseStarParser;
@synthesize phrasePlusParser;
@synthesize phraseQuestionParser;
@synthesize phraseCardinalityParser;
@synthesize cardinalityParser;
@synthesize primaryExprParser;
@synthesize negatedPrimaryExprParser;
@synthesize barePrimaryExprParser;
@synthesize predicateParser;
@synthesize intersectionParser;
@synthesize differenceParser;
@synthesize atomicValueParser;
@synthesize parserParser;
@synthesize discardParser;
@synthesize patternParser;
@synthesize delimitedStringParser;
@synthesize literalParser;
@synthesize variableParser;
@synthesize constantParser;
@end
