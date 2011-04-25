//
//  PKNSPredicateBuilder.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDNSPredicateBuilder.h"
#import "NSString+ParseKitAdditions.h"

// expr                 = term orTerm*;
// orTerm               = 'or' term;
// term                 = primaryExpr andPrimaryExpr*;
// andPrimaryExpr       = 'and' primaryExpr;
// primaryExpr          = phrase | '(' expr ')';
// phrase               = predicate | negatedPredicate;
// negatedPredicate     = 'not' predicate;
// predicate            = completePredicate | attrValuePredicate | attrPredicate | valuePredicate;
// completePredicate    = attr relation value;
// attrValuePredicate   = attr value;
// attrPredicate        = attr;
// valuePredicate       = value;
// attr                 = tag | Word;
// tag                  = '@' Word;
// value                = string | Number | bool;
// string               = QuotedString | unquotedString;
// unquotedString       = nonReservedWord+;
// bool                 = 'true' | 'false';

@interface TDNSPredicateBuilder ()
@property (nonatomic, retain) PKToken *nonReservedWordFence;
@end

@implementation TDNSPredicateBuilder

- (id)init {
    if (self = [super init]) {
        self.defaultAttr = @"content";
        self.defaultRelation = @"=";
        self.defaultValue = @"";
        self.nonReservedWordFence = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0.0];
    }
    return self;
}


- (void)dealloc {
    self.defaultAttr = nil;
    self.defaultRelation = nil;
    self.defaultValue = nil;
    self.nonReservedWordFence = nil;
    self.exprParser = nil;
    self.orTermParser = nil;
    self.termParser = nil;
    self.andPrimaryExprParser = nil;
    self.primaryExprParser = nil;
    self.phraseParser = nil;
    self.negatedPredicateParser = nil;
    self.predicateParser = nil;
    self.completePredicateParser = nil;
    self.attrValuePredicateParser = nil;
    self.attrPredicateParser = nil;
    self.valuePredicateParser = nil;
    self.attrParser = nil;
    self.tagParser = nil;
    self.relationParser = nil;
    self.valueParser = nil;
    self.boolParser = nil;
    self.trueParser = nil;
    self.falseParser = nil;
    self.stringParser = nil;
    self.quotedStringParser = nil;
    self.unquotedStringParser = nil;
    self.reservedWordParser = nil;
    self.nonReservedWordParser = nil;
    self.reservedWordPattern = nil;
    self.numberParser = nil;
    [super dealloc];
}


- (NSPredicate *)buildFrom:(NSString *)s; {
    PKAssembly *a = [PKTokenAssembly assemblyWithString:s];
    return [[self.exprParser completeMatchFor:a] pop];
}


// expression       = term orTerm*
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        [exprParser add:self.termParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
    }
    return exprParser;
}


// orTerm           = 'or' term
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        [orTermParser add:[[PKCaseInsensitiveLiteral literalWithString:@"or"] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(didMatchOr:)];
    }
    return orTermParser;
}


// term             = primaryExpr andPrimaryExpr*
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:self.primaryExprParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.andPrimaryExprParser]];
    }
    return termParser;
}


// andPrimaryExpr        = 'and' primaryExpr
- (PKCollectionParser *)andPrimaryExprParser {
    if (!andPrimaryExprParser) {
        self.andPrimaryExprParser = [PKSequence sequence];
        andPrimaryExprParser.name = @"andPrimaryExpr";
        [andPrimaryExprParser add:[[PKCaseInsensitiveLiteral literalWithString:@"and"] discard]];
        [andPrimaryExprParser add:self.primaryExprParser];
        [andPrimaryExprParser setAssembler:self selector:@selector(didMatchAnd:)];
    }
    return andPrimaryExprParser;
}


// primaryExpr           = phrase | '(' expression ')'
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.phraseParser];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[[PKSymbol symbolWithString:@"("] discard]];
        [s add:self.exprParser];
        [s add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [primaryExprParser add:s];
    }
    return primaryExprParser;
}


// phrase      = predicate | negatedPredicate
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [PKAlternation alternation];
        phraseParser.name = @"phrase";
        [phraseParser add:self.predicateParser];
        [phraseParser add:self.negatedPredicateParser];
    }
    return phraseParser;
}


// negatedPredicate      = 'not' predicate
- (PKCollectionParser *)negatedPredicateParser {
    if (!negatedPredicateParser) {
        self.negatedPredicateParser = [PKSequence sequence];
        negatedPredicateParser.name = @"negatedPredicate";
        [negatedPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"not"] discard]];
        [negatedPredicateParser add:self.predicateParser];
        [negatedPredicateParser setAssembler:self selector:@selector(didMatchNegatedValue:)];
    }
    return negatedPredicateParser;
}


// predicate         = bool | eqPredicate | nePredicate | gtPredicate | gteqPredicate | ltPredicate | lteqPredicate | beginswithPredicate | containsPredicate | endswithPredicate | matchesPredicate
- (PKCollectionParser *)predicateParser {
    if (!predicateParser) {
        self.predicateParser = [PKAlternation alternation];
        predicateParser.name = @"predicate";
        [predicateParser add:self.completePredicateParser];
        [predicateParser add:self.attrValuePredicateParser];
        [predicateParser add:self.attrPredicateParser];
        [predicateParser add:self.valuePredicateParser];
        [predicateParser setAssembler:self selector:@selector(didMatchPredicate:)];
    }
    return predicateParser;
}


// completePredicate    = attribute relation value
- (PKCollectionParser *)completePredicateParser {
    if (!completePredicateParser) {
        self.completePredicateParser = [PKSequence sequence];
        completePredicateParser.name = @"completePredicate";
        [completePredicateParser add:self.attrParser];
        [completePredicateParser add:self.relationParser];
        [completePredicateParser add:self.valueParser];
    }
    return completePredicateParser;
}


// attrValuePredicate    = attribute value
- (PKCollectionParser *)attrValuePredicateParser {
    if (!attrValuePredicateParser) {
        self.attrValuePredicateParser = [PKSequence sequence];
        attrValuePredicateParser.name = @"attrValuePredicate";
        [attrValuePredicateParser add:self.attrParser];
        [attrValuePredicateParser add:self.valueParser];
        [attrValuePredicateParser setAssembler:self selector:@selector(didMatchAttrValuePredicate:)];
    }
    return attrValuePredicateParser;
}


// attrPredicate        = attribute
- (PKCollectionParser *)attrPredicateParser {
    if (!attrPredicateParser) {
        self.attrPredicateParser = [PKSequence sequence];
        attrPredicateParser.name = @"attrPredicate";
        [attrPredicateParser add:self.attrParser];
        [attrPredicateParser setAssembler:self selector:@selector(didMatchAttrPredicate:)];
    }
    return attrPredicateParser;
}


// valuePredicate        = value
- (PKCollectionParser *)valuePredicateParser {
    if (!valuePredicateParser) {
        self.valuePredicateParser = [PKSequence sequence];
        valuePredicateParser.name = @"valuePredicate";
        [valuePredicateParser add:self.valueParser];
        [valuePredicateParser setAssembler:self selector:@selector(didMatchValuePredicate:)];
    }
    return valuePredicateParser;
}

    
// attr                 = tag | 'uniqueid' | 'line' | 'type' | 'isgroupheader' | 'level' | 'index' | 'content' | 'parent' | 'project' | 'countofchildren'
- (PKCollectionParser *)attrParser {
    if (!attrParser) {
        self.attrParser = [PKAlternation alternation];
        attrParser.name = @"attr";
        [attrParser add:self.tagParser];
        [attrParser add:self.nonReservedWordParser];
        [attrParser setAssembler:self selector:@selector(didMatchAttr:)];
    }
    return attrParser;
}


// relation                = '=' | '!=' | '>' | '>=' | '<' | '<=' | 'beginswith' | 'contains' | 'endswith' | 'matches'
- (PKCollectionParser *)relationParser {
    if (!relationParser) {
        self.relationParser = [PKAlternation alternation];
        relationParser.name = @"relation";
        [relationParser add:[PKSymbol symbolWithString:@"="]];
        [relationParser add:[PKSymbol symbolWithString:@"!="]];
        [relationParser add:[PKSymbol symbolWithString:@">"]];
        [relationParser add:[PKSymbol symbolWithString:@">="]];
        [relationParser add:[PKSymbol symbolWithString:@"<"]];
        [relationParser add:[PKSymbol symbolWithString:@"<="]];
        [relationParser add:[PKCaseInsensitiveLiteral literalWithString:@"beginswith"]];
        [relationParser add:[PKCaseInsensitiveLiteral literalWithString:@"contains"]];
        [relationParser add:[PKCaseInsensitiveLiteral literalWithString:@"endswith"]];
        [relationParser add:[PKCaseInsensitiveLiteral literalWithString:@"matches"]];
        [relationParser setAssembler:self selector:@selector(didMatchRelation:)];
    }
    return relationParser;
}


// tag                  = '@' Word
- (PKCollectionParser *)tagParser {
    if (!tagParser) {
        self.tagParser = [PKSequence sequence];
        tagParser.name = @"tag";
        [tagParser add:[[PKSymbol symbolWithString:@"@"] discard]];
        [tagParser add:[PKWord word]];
    }
    return tagParser;
}


// value                = QuotedString | Number | bool
- (PKCollectionParser *)valueParser {
    if (!valueParser) {
        self.valueParser = [PKAlternation alternation];
        valueParser.name = @"value";
        [valueParser add:self.stringParser];
        [valueParser add:self.numberParser];
        [valueParser add:self.boolParser];
    }
    return valueParser;
}


- (PKCollectionParser *)boolParser {
    if (!boolParser) {
        self.boolParser = [PKAlternation alternation];
        boolParser.name = @"bool";
        [boolParser add:self.trueParser];
        [boolParser add:self.falseParser];
        [boolParser setAssembler:self selector:@selector(didMatchBool:)];
    }
    return boolParser;
}


- (PKParser *)trueParser {
    if (!trueParser) {
        self.trueParser = [[PKCaseInsensitiveLiteral literalWithString:@"true"] discard];
        trueParser.name = @"true";
        [trueParser setAssembler:self selector:@selector(didMatchTrue:)];
    }
    return trueParser;
}


- (PKParser *)falseParser {
    if (!falseParser) {
        self.falseParser = [[PKCaseInsensitiveLiteral literalWithString:@"false"] discard];
        falseParser.name = @"false";
        [falseParser setAssembler:self selector:@selector(didMatchFalse:)];
    }
    return falseParser;
}


// string               = quotedString | unquotedString
- (PKCollectionParser *)stringParser {
    if (!stringParser) {
        self.stringParser = [PKAlternation alternation];
        stringParser.name = @"string";
        [stringParser add:self.quotedStringParser];
        [stringParser add:self.unquotedStringParser];
    }
    return stringParser;
}


// quotedString         = QuotedString
- (PKParser *)quotedStringParser {
    if (!quotedStringParser) {
        self.quotedStringParser = [PKQuotedString quotedString];
        quotedStringParser.name = @"quotedString";
        [quotedStringParser setAssembler:self selector:@selector(didMatchQuotedString:)];
    }
    return quotedStringParser;
}


// unquotedString       = nonReservedWord+
- (PKCollectionParser *)unquotedStringParser {
    if (!unquotedStringParser) {
        self.unquotedStringParser = [PKSequence sequence];
        unquotedStringParser.name = @"unquotedString";
        [unquotedStringParser add:self.nonReservedWordParser];
        [unquotedStringParser add:[PKRepetition repetitionWithSubparser:self.nonReservedWordParser]];
        [unquotedStringParser setAssembler:self selector:@selector(didMatchUnquotedString:)];
    }
    return unquotedStringParser;
}


- (PKCollectionParser *)reservedWordParser {
    if (!reservedWordParser) {
        self.reservedWordParser = [PKIntersection intersection];
        [reservedWordParser add:[PKWord word]];
        [reservedWordParser add:self.reservedWordPattern];
        reservedWordParser.name = @"reservedWord";
        [reservedWordParser setAssembler:self selector:@selector(didMatchReservedWord:)];
    }
    return reservedWordParser;
}


// nonReservedWord      = Word
- (PKCollectionParser *)nonReservedWordParser {
    if (!nonReservedWordParser) {
        self.nonReservedWordParser = [PKDifference differenceWithSubparser:[PKWord word] minus:self.reservedWordParser];
        nonReservedWordParser.name = @"nonReservedWord";
        [nonReservedWordParser setAssembler:self selector:@selector(didMatchNonReservedWord:)];
    }
    return nonReservedWordParser;
}


- (PKPattern *)reservedWordPattern {
    if (!reservedWordPattern) {
        NSString *s = @"true|false|and|or|not|contains|beginswith|endswith|matches";
        self.reservedWordPattern = [PKPattern patternWithString:s options:PKPatternOptionsIgnoreCase];
        reservedWordPattern.name = @"reservedWordPattern";
    }
    return reservedWordPattern;
}


- (PKParser *)numberParser {
    if (!numberParser) {
        self.numberParser = [PKNumber number];
        numberParser.name = @"number";
        [numberParser setAssembler:self selector:@selector(didMatchNumber:)];
    }
    return numberParser;
}


- (void)didMatchAnd:(PKAssembly *)a {
    NSPredicate *p2 = [a pop];
    NSPredicate *p1 = [a pop];
    NSArray *subs = [NSArray arrayWithObjects:p1, p2, nil];
    [a push:[NSCompoundPredicate andPredicateWithSubpredicates:subs]];
}


- (void)didMatchOr:(PKAssembly *)a {
    NSPredicate *p2 = [a pop];
    NSPredicate *p1 = [a pop];
    NSArray *subs = [NSArray arrayWithObjects:p1, p2, nil];
    [a push:[NSCompoundPredicate orPredicateWithSubpredicates:subs]];
}


- (void)didMatchPredicate:(PKAssembly *)a {
    id value = [a pop];
    id relation = [a pop];
    id attr = [a pop];
    NSString *predicateFormat = [NSString stringWithFormat:@"%@ %@ %%@", attr, relation, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, value, nil];
    [a push:predicate];
}


- (void)didMatchAttrValuePredicate:(PKAssembly *)a {
    id value = [a pop];
    id attr = [a pop];
    [a push:attr];
    [a push:defaultRelation];
    [a push:value];
}


- (void)didMatchAttrPredicate:(PKAssembly *)a {
    id attr = [a pop];
    [a push:attr];
    [a push:defaultRelation];
    [a push:defaultValue];
}


- (void)didMatchValuePredicate:(PKAssembly *)a {
    id value = [a pop];
    [a push:defaultAttr];
    [a push:defaultRelation];
    [a push:value];
}


- (void)didMatchAttr:(PKAssembly *)a {
    [a push:[[a pop] stringValue]];
}


- (void)didMatchRelation:(PKAssembly *)a {
    [a push:[[a pop] stringValue]];
}


- (void)didMatchNegatedValue:(PKAssembly *)a {
    id p = [a pop];
    [a push:[NSCompoundPredicate notPredicateWithSubpredicate:p]];
}


- (void)didMatchBool:(PKAssembly *)a {
    NSNumber *b = [a pop];
    [a push:[NSPredicate predicateWithValue:[b boolValue]]];
}


- (void)didMatchTrue:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:YES]];
}


- (void)didMatchFalse:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:NO]];
}


- (void)didMatchQuotedString:(PKAssembly *)a {
    [a push:[[[a pop] stringValue] stringByTrimmingQuotes]];
}


- (void)didMatchReservedWord:(PKAssembly *)a {
//    PKToken *tok = [a pop];
//    [a push:tok.stringValue];
}


- (void)didMatchNonReservedWord:(PKAssembly *)a {
//    id obj = [a pop];
//    [a push:nonReservedWordFence];
//    [a push:obj];
}


- (void)didMatchUnquotedString:(PKAssembly *)a {
    NSMutableArray *wordStrings = [NSMutableArray array];

    while (1) {
        NSArray *objs = [a objectsAbove:nonReservedWordFence];
        id next = [a pop]; // is the next obj a fence?
        if (![nonReservedWordFence isEqual:next]) {
            // if not, put the next token back
            if (next) {
                [a push:next];
            }
            // also put back any toks we didnt mean to pop
            for (id obj in [objs reverseObjectEnumerator]) {
                [a push:obj];
            }
            break;
        }
        NSAssert(1 == [objs count], @"");
        [wordStrings addObject:[objs objectAtIndex:0]];
    }
    
    NSInteger last = [wordStrings count] - 1;
    NSInteger i = 0;
    NSMutableString *ms = [NSMutableString string];
    for (NSString *wordString in [wordStrings reverseObjectEnumerator]) {
        if (i++ == last) {
            [ms appendString:wordString];
        } else {
            [ms appendFormat:@"%@ ", wordString];
        }
    }
    [a push:[[ms copy] autorelease]];
}


- (void)didMatchNumber:(PKAssembly *)a {
    NSNumber *n = [NSNumber numberWithFloat:[(PKToken *)[a pop] floatValue]];
    [a push:n];
}

@synthesize defaultAttr;
@synthesize defaultRelation;
@synthesize defaultValue;
@synthesize nonReservedWordFence;
@synthesize exprParser;
@synthesize orTermParser;
@synthesize termParser;
@synthesize andPrimaryExprParser;
@synthesize primaryExprParser;
@synthesize phraseParser;
@synthesize negatedPredicateParser;
@synthesize predicateParser;
@synthesize completePredicateParser;
@synthesize attrValuePredicateParser;
@synthesize attrPredicateParser;
@synthesize valuePredicateParser;
@synthesize attrParser;
@synthesize tagParser;
@synthesize relationParser;
@synthesize valueParser;
@synthesize boolParser;
@synthesize trueParser;
@synthesize falseParser;
@synthesize stringParser;
@synthesize quotedStringParser;
@synthesize unquotedStringParser;
@synthesize reservedWordParser;
@synthesize nonReservedWordParser;
@synthesize reservedWordPattern;
@synthesize numberParser;
@end
