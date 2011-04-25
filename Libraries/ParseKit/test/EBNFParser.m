//
//  EBNFParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "EBNFParser.h"
#import "NSString+ParseKitAdditions.h"

/*
 statement			= exprOrAssignment ';'
 exprOrAssignment	= expression | assigment
 assigment			= declaration '=' expression
 declaration		= '$' Word
 variable			= '$' Word
 expression			= term orTerm*
 term				= factor nextFactor*
 orTerm				= '|' term
 factor				= phrase | phraseStar | phraseQuestion | phrasePlus
 nextFactor			= factor
 phrase				= atomicValue | '(' expression ')'
 phraseStar			= phrase '*'
 phraseQuestion		= phrase '?'
 phrasePlus			= phrase '+'
 atomicValue        = Word | Number | QuotedString | variable
*/
 
static NSString * const kEBNFEqualsString = @"=";
static NSString * const kEBNFVariablePrefix = @"$";
static NSString * const kEBNFVariableSuffix = @"";

@interface PKParser (PKParserFactoryAdditionsFriend)
- (void)setTokenizer:(PKTokenizer *)t;
@end

@interface EBNFParser ()
- (void)addSymbolString:(NSString *)s toTokenizer:(PKTokenizer *)t;

- (void)didMatchWord:(PKAssembly *)a;
- (void)didMatchNum:(PKAssembly *)a;
- (void)didMatchQuotedString:(PKAssembly *)a;
- (void)didMatchStar:(PKAssembly *)a;
- (void)didMatchQuestion:(PKAssembly *)a;
- (void)didMatchPlus:(PKAssembly *)a;
- (void)didMatchAnd:(PKAssembly *)a;
- (void)didMatchOr:(PKAssembly *)a;
- (void)didMatchAssignment:(PKAssembly *)a;
- (void)didMatchVariable:(PKAssembly *)a;
@end

@implementation EBNFParser

- (id)init {
    if ([super initWithSubparser:self.statementParser]) {
        self.tokenizer = [PKTokenizer tokenizer];
        [self addSymbolString:kEBNFEqualsString toTokenizer:self.tokenizer];
        [self addSymbolString:kEBNFVariablePrefix toTokenizer:self.tokenizer];
        [self addSymbolString:kEBNFVariableSuffix toTokenizer:self.tokenizer];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.statementParser = nil;
    self.exprOrAssignmentParser = nil;
    self.assignmentParser = nil;
    self.declarationParser = nil;
    self.variableParser = nil;
    self.expressionParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phraseQuestionParser = nil;
    self.phrasePlusParser = nil;
    self.atomicValueParser = nil;
    [super dealloc];
}


- (id)parse:(NSString *)s {
    self.tokenizer.string = s;
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithTokenizer:self.tokenizer];
    PKAssembly *result = [self completeMatchFor:a];
    return [result pop];
}


- (void)addSymbolString:(NSString *)s toTokenizer:(PKTokenizer *)t {
    if ([s length]) {
        NSInteger c = [s characterAtIndex:0];
        [t setTokenizerState:t.symbolState from:c to:c];
        [t.symbolState add:s];
    }
}


// statement        = exprOrAssignment ';'
- (PKCollectionParser *)statementParser {
    if (!statementParser) {
        self.statementParser = [PKTrack track];
        [statementParser add:self.exprOrAssignmentParser];
        [statementParser add:[[PKSymbol symbolWithString:@";"] discard]];
    }
    return statementParser;
}


// exprOrAssignmentParser        = expression | assignment
- (PKCollectionParser *)exprOrAssignmentParser {
    if (!exprOrAssignmentParser) {
        self.exprOrAssignmentParser = [PKAlternation alternation];
        [exprOrAssignmentParser add:self.expressionParser];
        [exprOrAssignmentParser add:self.assignmentParser];
    }
    return exprOrAssignmentParser;
}


// declaration        = variable '=' expression
- (PKCollectionParser *)assignmentParser {
    if (!assignmentParser) {
        self.assignmentParser = [PKTrack track];
        [assignmentParser add:self.declarationParser];
        [assignmentParser add:[[PKSymbol symbolWithString:kEBNFEqualsString] discard]];
        [assignmentParser add:self.expressionParser];
        [assignmentParser setAssembler:self selector:@selector(didMatchAssignment:)];
    }
    return assignmentParser;
}


// declaration            = '$' Word
- (PKCollectionParser *)declarationParser {
    if (!declarationParser) {
        self.declarationParser = [PKTrack track];
        [declarationParser add:[[PKSymbol symbolWithString:kEBNFVariablePrefix] discard]];
        [declarationParser add:[PKWord word]];
        if ([kEBNFVariableSuffix length]) {
            [declarationParser add:[[PKSymbol symbolWithString:kEBNFVariableSuffix] discard]];
        }
    }
    return declarationParser;
}


// variable            = '$' Word
- (PKCollectionParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [PKTrack track];
        [variableParser add:[[PKSymbol symbolWithString:kEBNFVariablePrefix] discard]];
        [variableParser add:[PKWord word]];
        if ([kEBNFVariableSuffix length]) {
            [variableParser add:[[PKSymbol symbolWithString:kEBNFVariableSuffix] discard]];
        }
    }
    return variableParser;
}


// expression        = term orTerm*
- (PKCollectionParser *)expressionParser {
    if (!expressionParser) {
        self.expressionParser = [PKSequence sequence];
        [expressionParser add:self.termParser];
        [expressionParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
    }
    return expressionParser;
}


// term                = factor nextFactor*
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
    }
    return termParser;
}


// orTerm            = '|' term
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKTrack track];
        [orTermParser add:[[PKSymbol symbolWithString:@"|"] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(didMatchOr:)];
    }
    return orTermParser;
}


// factor            = phrase | phraseStar | phraseQuestion | phrasePlus
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKAlternation alternation];
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phraseQuestionParser];
        [factorParser add:self.phrasePlusParser];
    }
    return factorParser;
}


// nextFactor        = factor
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKAlternation alternation];
        [nextFactorParser add:self.phraseParser];
        [nextFactorParser add:self.phraseStarParser];
        [nextFactorParser add:self.phraseQuestionParser];
        [nextFactorParser add:self.phrasePlusParser];
        [nextFactorParser setAssembler:self selector:@selector(didMatchAnd:)];
    }
    return nextFactorParser;
}


// phrase            = atomicValue | '(' expression ')'
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        PKSequence *s = [PKTrack track];
        [s add:[[PKSymbol symbolWithString:@"("] discard]];
        [s add:self.expressionParser];
        [s add:[[PKSymbol symbolWithString:@")"] discard]];
        
        self.phraseParser = [PKAlternation alternation];
        [phraseParser add:self.atomicValueParser];
        [phraseParser add:s];
    }
    return phraseParser;
}


// phraseStar        = phrase '*'
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:[[PKSymbol symbolWithString:@"*"] discard]];
        [phraseStarParser setAssembler:self selector:@selector(didMatchStar:)];
    }
    return phraseStarParser;
}


// phraseQuestion        = phrase '?'
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:[[PKSymbol symbolWithString:@"?"] discard]];
        [phraseQuestionParser setAssembler:self selector:@selector(didMatchQuestion:)];
    }
    return phraseQuestionParser;
}


// phrasePlus            = phrase '+'
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:[[PKSymbol symbolWithString:@"+"] discard]];
        [phrasePlusParser setAssembler:self selector:@selector(didMatchPlus:)];
    }
    return phrasePlusParser;
}


// atomicValue        = Word | Number | QuotedString | Variable
- (PKCollectionParser *)atomicValueParser {
    if (!atomicValueParser) {
        self.atomicValueParser = [PKAlternation alternation];
        
        PKParser *p = [PKWord word];
        [p setAssembler:self selector:@selector(didMatchWord:)];
        [atomicValueParser add:p];
        
        p = [PKNumber number];
        [p setAssembler:self selector:@selector(didMatchNum:)];
        [atomicValueParser add:p];
        
        p = [PKQuotedString quotedString];
        [p setAssembler:self selector:@selector(didMatchQuotedString:)];
        [atomicValueParser add:p];
        
        p = self.variableParser;
        [p setAssembler:self selector:@selector(didMatchVariable:)];
        [atomicValueParser add:p];
    }
    return atomicValueParser;
}


- (void)didMatchWord:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    [a push:[PKLiteral literalWithString:tok.stringValue]];
}


- (void)didMatchNum:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    [a push:[PKLiteral literalWithString:tok.stringValue]];
}


- (void)didMatchQuotedString:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    NSString *s = [tok.stringValue stringByTrimmingQuotes];
    
    PKSequence *p = [PKSequence sequence];
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    PKToken *eof = [PKToken EOFToken];
    while (eof != (tok = [t nextToken])) {
        [p add:[PKLiteral literalWithString:tok.stringValue]];
    }
    
    [a push:p];
}


- (void)didMatchStar:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    PKRepetition *p = [PKRepetition repetitionWithSubparser:[a pop]];
    [a push:p];
}


- (void)didMatchQuestion:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    PKAlternation *p = [PKAlternation alternation];
    [p add:[a pop]];
    [p add:[PKEmpty empty]];
    [a push:p];
}


- (void)didMatchPlus:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    PKSequence *p = [PKSequence sequence];
    [p add:top];
    [p add:[PKRepetition repetitionWithSubparser:top]];
    [a push:p];
}


- (void)didMatchAnd:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    PKSequence *p = [PKSequence sequence];
    [p add:[a pop]];
    [p add:top];
    [a push:p];
}


- (void)didMatchOr:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    //    NSLog(@"top: %@", top);
    //    NSLog(@"top class: %@", [top class]);
    PKAlternation *p = [PKAlternation alternation];
    [p add:[a pop]];
    [p add:top];
    [a push:p];
}


- (void)didMatchAssignment:(PKAssembly *)a {
    NSLog(@"%s", _cmd);
    NSLog(@"a: %@", a);
    id val = [a pop];
    PKToken *keyTok = [a pop];
    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithDictionary:a.target];
    [table setObject:val forKey:keyTok.stringValue];
    a.target = table;
}


- (void)didMatchVariable:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKToken *keyTok = [a pop];
    id val = [a.target objectForKey:keyTok.stringValue];
    if (val) {
        [a push:val];
    }
}

@synthesize statementParser;
@synthesize exprOrAssignmentParser;
@synthesize assignmentParser;
@synthesize declarationParser;
@synthesize variableParser;
@synthesize expressionParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize phraseStarParser;
@synthesize phraseQuestionParser;
@synthesize phrasePlusParser;
@synthesize atomicValueParser;
@end