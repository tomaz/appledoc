//
//  PKRegularParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDRegularParser.h"

@interface TDRegularParser ()
- (void)didMatchChar:(PKAssembly *)a;
- (void)didMatchStar:(PKAssembly *)a;
- (void)didMatchPlus:(PKAssembly *)a;
- (void)didMatchQuestion:(PKAssembly *)a;
//- (void)didMatchAnd:(PKAssembly *)a;
- (void)didMatchOr:(PKAssembly *)a;
- (void)didMatchExpression:(PKAssembly *)a;
@end

@implementation TDRegularParser

- (id)init {
    if (self = [super init]) {
        [self add:self.expressionParser];
    }
    return self;
}


- (void)dealloc {
    self.expressionParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.letterOrDigitParser = nil;
    [super dealloc];
}


+ (id)parserFromGrammar:(NSString *)s {
    TDRegularParser *p = [TDRegularParser parser];
    PKAssembly *a = [PKCharacterAssembly assemblyWithString:s];
    a = [p completeMatchFor:a];
    return [a pop];
}


// expression        = term orTerm*
// term              = factor nextFactor*
// orTerm            = '|' term
// factor            = phrase | phraseStar | phrasePlus | phraseQuestion
// nextFactor        = factor
// phrase            = letterOrDigit | '(' expression ')'
// phraseStar        = phrase '*'
// phraseStar        = phrase '+'
// phraseStar        = phrase '?'
// letterOrDigit     = Letter | Digit


// expression        = term orTerm*
- (PKCollectionParser *)expressionParser {
    if (!expressionParser) {
        self.expressionParser = [PKSequence sequence];
        expressionParser.name = @"expression";
        [expressionParser add:self.termParser];
        [expressionParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
        [expressionParser setAssembler:self selector:@selector(didMatchExpression:)];
    }
    return expressionParser;
}


// term                = factor nextFactor*
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
    }
    return termParser;
}


// orTerm            = '|' term
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        [orTermParser add:[[PKSpecificChar specificCharWithChar:'|'] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(didMatchOr:)];
    }
    return orTermParser;
}


// factor            = phrase | phraseStar | phrasePlus | phraseQuestion
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKAlternation alternation];
        factorParser.name = @"factor";
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phrasePlusParser];
        [factorParser add:self.phraseQuestionParser];
    }
    return factorParser;
}


// nextFactor        = factor
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKAlternation alternation];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.phraseParser];
        [nextFactorParser add:self.phraseStarParser];
        [nextFactorParser add:self.phrasePlusParser];
        [nextFactorParser add:self.phraseQuestionParser];
//        [nextFactorParser setAssembler:self selector:@selector(didMatchAnd:)];
    }
    return nextFactorParser;
}


// phrase            = letterOrDigit | '(' expression ')'
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        PKSequence *s = [PKSequence sequence];
        [s add:[[PKSpecificChar specificCharWithChar:'('] discard]];
        [s add:self.expressionParser];
        [s add:[[PKSpecificChar specificCharWithChar:')'] discard]];

        self.phraseParser = [PKAlternation alternation];
        phraseParser.name = @"phrase";
        [phraseParser add:self.letterOrDigitParser];
        [phraseParser add:s];
    }
    return phraseParser;
}


// phraseStar        = phrase '*'
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:[[PKSpecificChar specificCharWithChar:'*'] discard]];
        [phraseStarParser setAssembler:self selector:@selector(didMatchStar:)];
    }
    return phraseStarParser;
}


// phrasePlus        = phrase '+'
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:[[PKSpecificChar specificCharWithChar:'+'] discard]];
        [phrasePlusParser setAssembler:self selector:@selector(didMatchPlus:)];
    }
    return phrasePlusParser;
}


// phrasePlus        = phrase '?'
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:[[PKSpecificChar specificCharWithChar:'?'] discard]];
        [phraseQuestionParser setAssembler:self selector:@selector(didMatchQuestion:)];
    }
    return phraseQuestionParser;
}


// letterOrDigit    = Letter | Digit
- (PKCollectionParser *)letterOrDigitParser {
    if (!letterOrDigitParser) {
        self.letterOrDigitParser = [PKAlternation alternation];
        letterOrDigitParser.name = @"letterOrDigit";
        [letterOrDigitParser add:[PKLetter letter]];
        [letterOrDigitParser add:[PKDigit digit]];
        [letterOrDigitParser setAssembler:self selector:@selector(didMatchChar:)];
    }
    return letterOrDigitParser;
}


- (void)didMatchChar:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id obj = [a pop];
    NSAssert([obj isKindOfClass:[NSNumber class]], @"");
    NSInteger c = [obj integerValue];
    [a push:[PKSpecificChar specificCharWithChar:c]];
}


- (void)didMatchStar:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKRepetition *rep = [PKRepetition repetitionWithSubparser:top];
    [a push:rep];
}


- (void)didMatchPlus:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKSequence *seq = [PKSequence sequence];
    [seq add:top];
    [seq add:[PKRepetition repetitionWithSubparser:top]];
    [a push:seq];
}


- (void)didMatchQuestion:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKAlternation *alt = [PKAlternation alternation];
    [alt add:[PKEmpty empty]];
    [alt add:top];
    [a push:alt];
}


//- (void)didMatchAnd:(PKAssembly *)a {
////    NSLog(@"%s", _cmd);
////    NSLog(@"a: %@", a);
//    id second = [a pop];
//    id first = [a pop];
//    NSAssert([first isKindOfClass:[PKParser class]], @"");
//    NSAssert([second isKindOfClass:[PKParser class]], @"");
//    PKSequence *p = [PKSequence sequence];
//    [p add:first];
//    [p add:second];
//    [a push:p];
//}


- (void)didMatchExpression:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    
    NSAssert(![a isStackEmpty], @"");
    
    id obj = nil;
    NSMutableArray *objs = [NSMutableArray array];
    while (![a isStackEmpty]) {
        obj = [a pop];
        [objs addObject:obj];
        NSAssert([obj isKindOfClass:[PKParser class]], @"");
    }
    
    if ([objs count] > 1) {
        PKSequence *seq = [PKSequence sequence];
        for (id obj in [objs reverseObjectEnumerator]) {
            [seq add:obj];
        }
        [a push:seq];
    } else {
        NSAssert((NSUInteger)1 == [objs count], @"");
        PKParser *p = [objs objectAtIndex:0];
        [a push:p];
    }
}


- (void)didMatchOr:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id second = [a pop];
    id first = [a pop];
//    NSLog(@"first: %@", first);
//    NSLog(@"second: %@", second);
    NSAssert(first, @"");
    NSAssert(second, @"");
    NSAssert([first isKindOfClass:[PKParser class]], @"");
    NSAssert([second isKindOfClass:[PKParser class]], @"");
    PKAlternation *p = [PKAlternation alternation];
    [p add:first];
    [p add:second];
    [a push:p];
}

@synthesize expressionParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize phraseStarParser;
@synthesize phrasePlusParser;
@synthesize phraseQuestionParser;
@synthesize letterOrDigitParser;
@end
