//
//  PKParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDParserTest.h"

@implementation TDParserTest

- (void)setUp {
}


- (void)tearDown {
}


#pragma mark -

- (void)testMath {
    s = @"2 4 6 8";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKRepetition repetitionWithSubparser:[PKNumber number]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[2, 4, 6, 8]2/4/6/8^", [result description]);
}


- (void)testMiniMath {
    s = @"4.5 - 5.6 - 222.0";
    a = [PKTokenAssembly assemblyWithString:s];
    
    PKSequence *minusNum = [PKSequence sequence];
    [minusNum add:[[PKSymbol symbolWithString:@"-"] discard]];
    [minusNum add:[PKNumber number]];
    
    PKSequence *e = [PKSequence sequence];
    [e add:[PKNumber number]];
    [e add:[PKRepetition repetitionWithSubparser:minusNum]];
    
    PKAssembly *result = [e completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[4.5, 5.6, 222.0]4.5/-/5.6/-/222.0^", [result description]);
}


- (void)testMiniMathWithBrackets {
    s = @"[4.5 - 5.6 - 222.0]";
    a = [PKTokenAssembly assemblyWithString:s];
    
    PKSequence *minusNum = [PKSequence sequence];
    [minusNum add:[[PKSymbol symbolWithString:@"-"] discard]];
    [minusNum add:[PKNumber number]];
    
    PKSequence *e = [PKSequence sequence];
    [e add:[[PKSymbol symbolWithString:@"["] discard]];
    [e add:[PKNumber number]];
    [e add:[PKRepetition repetitionWithSubparser:minusNum]];
    [e add:[[PKSymbol symbolWithString:@"]"] discard]];
    
    PKAssembly *result = [e completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[4.5, 5.6, 222.0][/4.5/-/5.6/-/222.0/]^", [result description]);
}


- (void)testHotHotSteamingHotCoffee {
    PKAlternation *adjective = [PKAlternation alternation];
    [adjective add:[PKLiteral literalWithString:@"hot"]];
    [adjective add:[PKLiteral literalWithString:@"steaming"]];

    PKRepetition *adjectives = [PKRepetition repetitionWithSubparser:adjective];
    
    PKSequence *sentence = [PKSequence sequence];
    [sentence add:adjectives];
    [sentence add:[PKLiteral literalWithString:@"coffee"]];

    s = @"hot hot steaming hot coffee";
    a = [PKTokenAssembly assemblyWithString:s];
    
    PKAssembly *result = [sentence bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[hot, hot, steaming, hot, coffee]hot/hot/steaming/hot/coffee^", [result description]);
}
    

- (void)testList {
    PKAssembly *result = nil;

    PKSequence *commaTerm = [PKSequence sequence];
    [commaTerm add:[[PKSymbol symbolWithString:@","] discard]];
    [commaTerm add:[PKWord word]];

    PKSequence *actualList = [PKSequence sequence];
    [actualList add:[PKWord word]];
    [actualList add:[PKRepetition repetitionWithSubparser:commaTerm]];
    
    PKSequence *list = [PKSequence sequence];
    [list add:[[PKSymbol symbolWithString:@"["] discard]];
    [list add:actualList];
    [list add:[[PKSymbol symbolWithString:@"]"] discard]];

    s = @"[foo, bar, baz]";
    a = [PKTokenAssembly assemblyWithString:s];

    result = [list bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz][/foo/,/bar/,/baz/]^", [result description]);
}


- (void)testJavaScriptStatement {
    s = @"123 'boo'";
    a = [PKTokenAssembly assemblyWithString:s];
    
    PKAlternation *literals = [PKAlternation alternation];
    [literals add:[PKQuotedString quotedString]];
    [literals add:[PKNumber number]];
    
    PKAssembly *result = [literals bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[123]123^'boo'", [result description]);
}


- (void)testParserNamed {
    
    //  seq = (foo|bar|seq) foo* w sy;
    PKCollectionParser *seq = [PKSequence sequence];
    seq.name = @"seq";
    
    PKCollectionParser *alt = [PKAlternation alternation];
    alt.name = @"alt";
    
    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    foo.name = @"w";
    [alt add:foo];
    
    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    bar.name = @"w";
    [alt add:bar];
    
    [alt add:seq];
    
    PKRepetition *r = [PKRepetition repetitionWithSubparser:foo];
    
    PKWord *w = [PKWord word];
    w.name = @"w";
    
    PKSymbol *sy = [PKSymbol symbol];
    sy.name = @"sy";
    
    
    [seq add:alt];
    [seq add:r];
    [seq add:w];
    [seq add:sy];
    
    TDEquals(seq, [seq parserNamed:@"seq"]);
    TDEquals(seq, [alt parserNamed:@"seq"]);
    
    TDEquals(alt, [seq parserNamed:@"alt"]);
    TDEquals(w, [seq parserNamed:@"w"]);
    TDEquals(sy, [seq parserNamed:@"sy"]);

    TDEquals(foo, [alt parserNamed:@"w"]);
    TDEquals(foo, [r parserNamed:@"w"]);
}

@end
