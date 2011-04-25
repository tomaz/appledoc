//
//  PKPlistParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/9/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDPlistParser.h"
#import "NSString+ParseKitAdditions.h"

//{
//    0 = 0;
//    dictKey =     {
//        bar = foo;
//    };
//    47 = 0;
//    IntegerKey = 1;
//    47.7 = 0;
//    <null> = <null>;
//    ArrayKey =     (
//                    "one one",
//                    two,
//                    three
//                    );
//    "Null Key" = <null>;
//    emptyDictKey =     {
//    };
//    StringKey = String;
//    "1.0" = 1;
//    YESKey = 1;
//    "NO Key" = 0;
//}


// dict                 = '{' dictContent '}'
// dictContent          = keyValuePair*
// keyValuePair         = key '=' value ';'
// key                  = num | string | null
// value                = num | string | null | array | dict
// null                 = '<null>'
// string               = Word | QuotedString
// num                  = Number

// array                = '(' arrayContent ')'
// arrayContent         = Empty | actualArray
// actualArray          = value commaValue*
// commaValue           = ',' value

static NSString *kTDPlistNullString = @"<null>";

@interface PKParser (PKParserFactoryAdditionsFriend)
- (void)setTokenizer:(PKTokenizer *)t;
@end

@interface PKCollectionParser ()
@property (nonatomic, readwrite, retain) NSMutableArray *subparsers;
@end

@interface TDPlistParser ()
@property (nonatomic, retain) PKToken *curly;
@property (nonatomic, retain) PKToken *paren;
@end

@implementation TDPlistParser

- (id)init {
    self = [super init];
    if (self != nil) {

        self.tokenizer = [PKTokenizer tokenizer];
        // add '<null>' as a multichar symbol
        [self.tokenizer.symbolState add:kTDPlistNullString];
        
        self.curly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.];
        self.paren = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0.];
        [self add:[PKEmpty empty]];
        [self add:self.arrayParser];
        [self add:self.dictParser];
    }
    return self;
}


- (void)dealloc {
    // avoid retain cycle leaks by releasing the subparsers of all collection parsers
    dictParser.subparsers = nil;
    keyValuePairParser.subparsers = nil;
    arrayParser.subparsers = nil;
    commaValueParser.subparsers = nil;
    keyParser.subparsers = nil;
    valueParser.subparsers = nil;
    stringParser.subparsers = nil;
    
    self.tokenizer = nil;
    self.dictParser = nil;
    self.keyValuePairParser = nil;
    self.arrayParser = nil;
    self.commaValueParser = nil;
    self.keyParser = nil;
    self.valueParser = nil;
    self.stringParser = nil;
    self.numParser = nil;
    self.nullParser = nil;
    self.curly = nil;
    self.paren = nil;
    [super dealloc];
}


- (id)parse:(NSString *)s {
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithTokenizer:self.tokenizer];
    
    // parse
    PKAssembly *res = [self completeMatchFor:a];

    // pop the built result off the assembly's stack and return.
    // this will be an array or a dictionary or nil
    return [res pop];
}


// dict                 = '{' dictContent '}'
// dictContent          = keyValuePair*
- (PKCollectionParser *)dictParser {
    if (!dictParser) {
        self.dictParser = [PKTrack track];
        [dictParser add:[PKSymbol symbolWithString:@"{"]]; // dont discard. serves as fence
        [dictParser add:[PKRepetition repetitionWithSubparser:self.keyValuePairParser]];
        [dictParser add:[[PKSymbol symbolWithString:@"}"] discard]];
        [dictParser setAssembler:self selector:@selector(didMatchDict:)];
    }
    return dictParser;
}


// keyValuePair         = key '=' value ';'
- (PKCollectionParser *)keyValuePairParser {
    if (!keyValuePairParser) {
        self.keyValuePairParser = [PKTrack track];
        [keyValuePairParser add:self.keyParser];
        [keyValuePairParser add:[[PKSymbol symbolWithString:@"="] discard]];
        [keyValuePairParser add:self.valueParser];
        [keyValuePairParser add:[[PKSymbol symbolWithString:@";"] discard]];
    }
    return keyValuePairParser;
}


// array                = '(' arrayContent ')'
// arrayContent         = Empty | actualArray
// actualArray          = value commaValue*
- (PKCollectionParser *)arrayParser {
    if (!arrayParser) {
        self.arrayParser = [PKTrack track];
        [arrayParser add:[PKSymbol symbolWithString:@"("]]; // dont discard. serves as fence
        
        PKAlternation *arrayContent = [PKAlternation alternation];
        [arrayContent add:[PKEmpty empty]];
        
        PKSequence *actualArray = [PKSequence sequence];
        [actualArray add:self.valueParser];
        [actualArray add:[PKRepetition repetitionWithSubparser:self.commaValueParser]];
        
        [arrayContent add:actualArray];
        [arrayParser add:arrayContent];
        [arrayParser add:[[PKSymbol symbolWithString:@")"] discard]];
        [arrayParser setAssembler:self selector:@selector(didMatchArray:)];
    }
    return arrayParser;
}


// key                  = num | string | null
- (PKCollectionParser *)keyParser {
    if (!keyParser) {
        self.keyParser = [PKAlternation alternation];
        [keyParser add:self.numParser];
        [keyParser add:self.stringParser];
        [keyParser add:self.nullParser];
    }
    return keyParser;
}


// value                = num | string | null | array | dict
- (PKCollectionParser *)valueParser {
    if (!valueParser) {
        self.valueParser = [PKAlternation alternation];
        [valueParser add:self.arrayParser];
        [valueParser add:self.dictParser];
        [valueParser add:self.stringParser];
        [valueParser add:self.numParser];
        [valueParser add:self.nullParser];
    }
    return valueParser;
}


- (PKCollectionParser *)commaValueParser {
    if (!commaValueParser) {
        self.commaValueParser = [PKSequence sequence];
        [commaValueParser add:[[PKSymbol symbolWithString:@","] discard]];
        [commaValueParser add:self.valueParser];
    }
    return commaValueParser;
}


// string               = QuotedString | Word
- (PKCollectionParser *)stringParser {
    if (!stringParser) {
        self.stringParser = [PKAlternation alternation];
        
        // we have to remove the quotes from QuotedString string values. so set an assembler method to do that
        PKParser *quotedString = [PKQuotedString quotedString];
        [quotedString setAssembler:self selector:@selector(didMatchQuotedString:)];
        [stringParser add:quotedString];

        // handle non-quoted string values (Words) in a separate assembler method for simplicity.
        PKParser *word = [PKWord word];
        [word setAssembler:self selector:@selector(didMatchWord:)];
        [stringParser add:word];
    }
    return stringParser;
}


- (PKParser *)numParser {
    if (!numParser) {
        self.numParser = [PKNumber number];
        [numParser setAssembler:self selector:@selector(didMatchNum:)];
    }
    return numParser;
}


// null = '<null>'
- (PKParser *)nullParser {
    if (!nullParser) {
        // thus must be a PKSymbol (not a PKLiteral) to match the resulting '<null>' symbol tok
        self.nullParser = [PKSymbol symbolWithString:kTDPlistNullString];
        [nullParser setAssembler:self selector:@selector(didMatchNull:)];
    }
    return nullParser;
}


- (void)didMatchDict:(PKAssembly *)a {
    NSArray *objs = [a objectsAbove:self.curly];
    NSInteger count = [objs count];
    NSAssert1(0 == count % 2, @"in -%s, the assembly's stack's count should be a multiple of 2", _cmd);

    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithCapacity:count / 2.];
    if (count) {
        NSInteger i = 0;
        for ( ; i < [objs count] - 1; i++) {
            id value = [objs objectAtIndex:i++];
            id key = [objs objectAtIndex:i];
            [res setObject:value forKey:key];
        }
    }
    
    [a pop]; // discard '{' tok
    [a push:[[res copy] autorelease]];
}


- (void)didMatchArray:(PKAssembly *)a {
    NSArray *objs = [a objectsAbove:self.paren];
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[objs count]];
    
    for (id obj in [objs reverseObjectEnumerator]) {
        [res addObject:obj];
    }
    
    [a pop]; // discard '(' tok
    [a push:[[res copy] autorelease]];
}


- (void)didMatchQuotedString:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:[tok.stringValue stringByTrimmingQuotes]];
}


- (void)didMatchWord:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:tok.stringValue];
}


- (void)didMatchNum:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:[NSNumber numberWithFloat:tok.floatValue]];
}


- (void)didMatchNull:(PKAssembly *)a {
    [a pop]; // discard '<null>' tok
    [a push:[NSNull null]];
}

@synthesize dictParser;
@synthesize keyValuePairParser;
@synthesize arrayParser;
@synthesize commaValueParser;
@synthesize keyParser;
@synthesize valueParser;
@synthesize stringParser;
@synthesize numParser;
@synthesize nullParser;
@synthesize curly;
@synthesize paren;
@end
