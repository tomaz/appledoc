//
//  PKParserFactoryTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import "TDParserFactoryTest.h"
#import <OCMock/OCMock.h>

@interface PKParserFactory ()
- (PKTokenizer *)tokenizerForParsingGrammar;
- (PKSequence *)parserFromExpression:(NSString *)s;
@property (retain) PKCollectionParser *exprParser;
@end

@protocol TDMockAssember
- (void)didMatchFoo:(PKAssembly *)a;
- (void)didMatchBaz:(PKAssembly *)a;
- (void)didMatchStart:(PKAssembly *)a;
- (void)didMatchStart:(PKAssembly *)a;
- (void)didMatch_Start:(PKAssembly *)a;
@end

@implementation TDParserFactoryTest

- (void)setUp {
    factory = [PKParserFactory factory];
    PKSequence *seq = [PKSequence sequence];
    [seq add:factory.exprParser];
    exprSeq = seq;
    t = [factory tokenizerForParsingGrammar];
}


- (void)testJavaScript {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"javascript" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
    s = @"var foo = 'bar';";
    lp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:lp.tokenizer];
//    res = [lp bestMatchFor:a];
//    TDEqualObjects(@"[var, foo, =, 'bar', ;]var/foo/=/bar/;^", [res description]);
}


- (void)testCSS2_1 {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"css2_1" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
//    s = @"foo {font-size:12px}";
//    a = [PKTokenAssembly assemblyWithString:s];
//    res = [lp bestMatchFor:a];
//    TDEqualObjects(@"[foo, {, font-family, :, 'helvetica', ;, }]foo/{/font-family/:/'helvetica'/;/}^", [res description]);
}    


- (void)testCSS {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mini_css" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
    PKParser *selectorParser = [lp parserNamed:@"selector"];
    TDNotNil(selectorParser);
    TDEqualObjects(selectorParser.name, @"selector");
    TDEqualObjects([selectorParser class], [PKLowercaseWord class]);

    PKParser *declParser = [lp parserNamed:@"decl"];
    TDNotNil(declParser);
    TDEqualObjects(declParser.name, @"decl");
    TDEqualObjects([declParser class], [PKSequence class]);

    PKParser *rulesetParser = [lp parserNamed:@"ruleset"];
    TDNotNil(rulesetParser);
    TDEqualObjects(rulesetParser, [(PKRepetition *)lp subparser]);
    TDEqualObjects(rulesetParser.name, @"ruleset");
    TDEqualObjects([rulesetParser class], [PKSequence class]);
    
    PKParser *startParser = [lp parserNamed:@"@start"];
    TDNotNil(startParser);
    TDEqualObjects(startParser, lp);
    TDEqualObjects(startParser.name, @"@start");
    TDEqualObjects([startParser class], [PKRepetition class]);
    
    s = @"foo {font-family:'helvetica';}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, {, font-family, 'helvetica']foo/{/font-family/:/'helvetica'/;/}^", [res description]);
    
    s = @"foo {font-family:'helvetica'}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, {, font-family, 'helvetica']foo/{/font-family/:/'helvetica'/}^", [res description]);
    
    s = @"bar {color:rgb(1, 255, 255); font-size:13px;}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar, {, color, (, 1, 255, 255, font-size, 13]bar/{/color/:/rgb/(/1/,/255/,/255/)/;/font-size/:/13/px/;/}^", [res description]);
    
    s = @"bar {color:rgb(1, 255, 47.0); font-family:'Helvetica'}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar, {, color, (, 1, 255, 47.0, font-family, 'Helvetica']bar/{/color/:/rgb/(/1/,/255/,/47.0/)/;/font-family/:/'Helvetica'/}^", [res description]);
    
    s = @"foo {font-family:'Lucida Grande'} bar {color:rgb(1, 255, 255); font-size:9px;}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, {, font-family, 'Lucida Grande', bar, {, color, (, 1, 255, 255, font-size, 9]foo/{/font-family/:/'Lucida Grande'/}/bar/{/color/:/rgb/(/1/,/255/,/255/)/;/font-size/:/9/px/;/}^", [res description]);
}


- (void)testJSON {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
    s = @"{'foo':'bar'}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', :, 'bar', }]{/'foo'/:/'bar'/}^", [res description]);
    
    s = @"{'foo':{}}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', :, {, }, }]{/'foo'/:/{/}/}^", [res description]);
    
    s = @"{'foo':{'bar':[]}}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', :, {, 'bar', :, [, ], }, }]{/'foo'/:/{/'bar'/:/[/]/}/}^", [res description]);
    
    s = @"['foo', true, null]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, 'foo', ,, true, ,, null, ]][/'foo'/,/true/,/null/]^", [res description]);
    
    s = @"[[]]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, [, ], ]][/[/]/]^", [res description]);
    
    s = @"[[[1]]]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, [, [, 1, ], ], ]][/[/[/1/]/]/]^", [res description]);
}


- (void)testJSONWithDiscards {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json_with_discards" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
    s = @"{'foo':'bar'}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', 'bar']{/'foo'/:/'bar'/}^", [res description]);
    
    s = @"{'foo':{}}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', {]{/'foo'/:/{/}/}^", [res description]);
    
    s = @"{'foo':{'bar':[]}}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', {, 'bar', []{/'foo'/:/{/'bar'/:/[/]/}/}^", [res description]);
    
    s = @"['foo', true, null]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, 'foo'][/'foo'/,/true/,/null/]^", [res description]);
    
    s = @"[[]]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, [][/[/]/]^", [res description]);
    
    s = @"[[[1]]]";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[[, [, [, 1][/[/[/1/]/]/]^", [res description]);
}


- (void)testStartLiteral {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = 'bar';";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testStartLiteralNonReserved {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo*; foo = 'bar';";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    s = @"bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar, bar]bar/bar^", [res description]);
    [mock verify];
}


- (void)testStartLiteralNonReserved2 {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = (foo|baz)*; foo = 'bar'; baz = 'bat'";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    [[mock expect] didMatchBaz:OCMOCK_ANY];
    s = @"bar bat";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar, bat]bar/bat^", [res description]);
    [mock verify];
}


- (void)testStartLiteralNonReserved3 {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = (foo|baz)+; foo = 'bar'; baz = 'bat'";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    [[mock expect] didMatchBaz:OCMOCK_ANY];
    s = @"bar bat";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar, bat]bar/bat^", [res description]);
    [mock verify];
}


- (void)testStartLiteralNonReserved4 {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = (foo|baz)+; foo = 'bar'; baz = 'bat'";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    [[mock expect] didMatchBaz:OCMOCK_ANY];
    [[mock expect] didMatchBaz:OCMOCK_ANY];
    s = @"bar bat bat";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar, bat, bat]bar/bat/bat^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorDefault {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo|baz; foo = 'bar'; baz = 'bat'";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorOnAll {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo|baz; foo = 'bar'; baz = 'bat'";
    factory.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorOnAll;
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
//    TDTrue(lp.assembler == mock);
//    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatch_Start:");
    
//    [[mock expect] didMatch_Start:OCMOCK_ANY];
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorOnTerminals {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo|baz; foo = 'bar'; baz = 'bat'";
    factory.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorOnTerminals;
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
    TDNil(lp.assembler);
    TDNil(NSStringFromSelector(lp.assemblerSelector));
    
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorOnExplicit {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo|baz; foo (didMatchFoo:) = 'bar'; baz (didMatchBaz:) = 'bat'";
    factory.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorOnExplicit;
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
    TDNil(lp.assembler);
    TDNil(NSStringFromSelector(lp.assemblerSelector));
    
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorOnExplicitNone {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = foo|baz; foo = 'bar'; baz = 'bat'";
    factory.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorOnExplicit;
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
    TDNil(lp.assembler);
    TDNil(NSStringFromSelector(lp.assemblerSelector));
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testAssemblerSettingBehaviorOnExplicitOrTerminal {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start = (foo|baz)+; foo (didMatchFoo:) = 'bar'; baz = 'bat'";
    factory.assemblerSettingBehavior = (PKParserFactoryAssemblerSettingBehaviorOnExplicit | PKParserFactoryAssemblerSettingBehaviorOnTerminals);
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
    TDNil(lp.assembler);
    TDNil(NSStringFromSelector(lp.assemblerSelector));
    
    [[mock expect] didMatchFoo:OCMOCK_ANY];
    [[mock expect] didMatchBaz:OCMOCK_ANY];
    s = @"bar bat";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp completeMatchFor:a];
    TDEqualObjects(@"[bar, bat]bar/bat^", [res description]);
    [mock verify];
}


- (void)testStartLiteralWithCallback {
    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
    s = @"@start (didMatchStart:) = 'bar';";
    lp = [factory parserFromGrammar:s assembler:mock];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    TDEqualObjects(lp.name, @"@start");
    TDTrue(lp.assembler == mock);
    TDEqualObjects(NSStringFromSelector(lp.assemblerSelector), @"didMatchStart:");

    [[mock expect] didMatchStart:OCMOCK_ANY];
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    [mock verify];
}


- (void)testStartRefToLiteral {
    s = @" @start = foo; foo = 'bar';";
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testStartRefToLiteral3 {
    s = @" @start = foo|baz; baz = 'bat'; foo = 'bar';";
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);

    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testStartRefToLiteral2 {
    s = @"foo = 'bar'; baz = 'bat'; @start = (foo | baz)*;";
    lp = [factory parserFromGrammar:s assembler:nil];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);

    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);

    s = @"bat bat";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bat, bat]bat/bat^", [res description]);

    s = @"bat bat bat bat bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bat, bat, bat, bat, bar]bat/bat/bat/bat/bar^", [res description]);
}


#ifndef TARGET_CPU_X86_64
- (void)testStmtTrackException {
    s = @"@start =";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
    
    s = @"@start";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testCallbackTrackException {
    s = @"@start ( = 'foo';";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
    
    s = @"@start (foo: = 'foo'";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testSelectorTrackException {
    s = @"@start (foo) = 'foo';";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testOrTrackException {
    s = @"@start = 'foo'|;";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


//- (void)testExprTrackException {
//    s = @"@start=(foo;";
//    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
//}


- (void)testIntersectionTrackException {
    s = @"@start='foo' &;";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testExclusionTrackException {
    s = @"@start='foo' -;";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testDelimitedStringTrackException {
    s = @"@start=DelimitedString('/';";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");

    s = @"@start=DelimitedString('/', ;";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}


- (void)testCardinalityTrackException {
    s = @"@start='foo'{;";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");

    s = @"@start='foo'{};";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
    
    s = @"@start='foo'{,};";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
    
    s = @"@start='foo'{m};";
    STAssertThrowsSpecificNamed([factory parserFromGrammar:s assembler:nil], PKTrackException, PKTrackExceptionName, @"");
}
#endif


- (void)testExprHelloPlus {
    s = @"'hello'+";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[hello, hello]hello/hello^", [res description]);
}


- (void)testExprHelloStar {
    s = @"'hello'*";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKRepetition class]);

    s = @"hello hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[hello, hello, hello]hello/hello/hello^", [res description]);
}


- (void)testExprHelloQuestion {
    s = @"'hello'?";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKAlternation class]);

    s = @"hello hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[hello]hello^hello/hello", [res description]);
}


- (void)testExprOhHaiThereQuestion {
    s = @"'oh'? 'hai'? 'there'?";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    s = @"there";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[there]there^", [res description]);
}


- (void)testExprFooBar {
    s = @"'foo' 'bar'";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];

    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Sequence]'foo'/ /'bar'^", [res description]);
    PKSequence *seq = [res pop];
    TDTrue([seq isMemberOfClass:[PKSequence class]]);
    TDEquals((NSUInteger)2, [seq.subparsers count]);
    
    PKLiteral *c = [seq.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    c = [seq.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    s = @"foo bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, bar]foo/bar^", [res description]);
}


- (void)testExprFooBarBaz {
    s = @"'foo' 'bar' 'baz'";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Sequence]'foo'/ /'bar'/ /'baz'^", [res description]);
    PKSequence *seq = [res pop];
    TDTrue([seq isMemberOfClass:[PKSequence class]]);
    TDEquals((NSUInteger)3, [seq.subparsers count]);
    
    PKLiteral *c = [seq.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    c = [seq.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    c = [seq.subparsers objectAtIndex:2];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"baz", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [res description]);
}


- (void)testExprFooOrBar {
    s = @"'foo'|'bar'";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Alternation]'foo'/|/'bar'^", [res description]);

    PKAlternation *alt = [res pop];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    c = [alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKAlternation class]);

    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)testExprFooOrBarStar {
    s = @"'foo'|'bar'*";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Alternation]'foo'/|/'bar'/*^", [res description]);

    PKAlternation *alt = [res pop];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    PKRepetition *rep = [alt.subparsers objectAtIndex:1];
    TDEqualObjects([PKRepetition class], [rep class]);
    c = (PKLiteral *)rep.subparser;
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKAlternation class]]);

    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^", [res description]);

    s = @"foo foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^foo", [res description]);
    
    s = @"bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar, bar]bar/bar^", [res description]);
}


- (void)testExprFooOrBarPlus {
    s = @"'foo'|'bar'+";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Alternation]'foo'/|/'bar'/+^", [res description]);

    PKAlternation *alt = [res pop];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    PKSequence *seq = [alt.subparsers objectAtIndex:1];
    TDEqualObjects([PKSequence class], [seq class]);
    
    c = [seq.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    PKRepetition *rep = [seq.subparsers objectAtIndex:1];
    TDEqualObjects([PKRepetition class], [rep class]);
    c = (PKLiteral *)rep.subparser;
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKAlternation class]]);
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^", [res description]);

    s = @"foo foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^foo", [res description]);
    
    s = @"foo bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^bar", [res description]);

    s = @"bar bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar, bar, bar]bar/bar/bar^", [res description]);
}


- (void)testExprFooOrBarQuestion {
    s = @"'foo'|'bar'?";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Alternation]'foo'/|/'bar'/?^", [res description]);
    PKAlternation *alt = [res pop];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    alt = [alt.subparsers objectAtIndex:1];
    TDEqualObjects([PKAlternation class], [alt class]);
    
    PKEmpty *e = [alt.subparsers objectAtIndex:0];
    TDTrue([e isMemberOfClass:[PKEmpty class]]);
    
    c = (PKLiteral *)[alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKAlternation class]]);
    s = @"bar bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^bar/bar", [res description]);
    
    s = @"foo bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^bar/bar", [res description]);
}


- (void)testExprParenFooOrBarParenStar {
    s = @"('foo'|'bar')*";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Repetition](/'foo'/|/'bar'/)/*^", [res description]);
    PKRepetition *rep = [res pop];
    TDTrue([rep isMemberOfClass:[PKRepetition class]]);
    
    PKAlternation *alt = (PKAlternation *)rep.subparser;
    TDTrue([alt class] == [PKAlternation class]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    c = [alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKRepetition class]);
    s = @"foo bar bar foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, bar, bar, foo]foo/bar/bar/foo^", [res description]);
}


- (void)testExprParenFooOrBooParenPlus {
    s = @"('foo'|'bar')+";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Sequence](/'foo'/|/'bar'/)/+^", [res description]);
    PKSequence *seq = [res pop];
    TDTrue([seq isMemberOfClass:[PKSequence class]]);
    
    TDEquals((NSUInteger)2, [seq.subparsers count]);
    
    PKAlternation *alt = [seq.subparsers objectAtIndex:0];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    c = [alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    PKRepetition *rep = [seq.subparsers objectAtIndex:1];
    TDTrue([rep isMemberOfClass:[PKRepetition class]]);
    
    alt = (PKAlternation *)rep.subparser;
    TDEqualObjects([PKAlternation class], [alt class]);
    
    c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    c = [alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    s = @"foo foo bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo, foo, bar, bar]foo/foo/bar/bar^", [res description]);
}


- (void)testExprParenFooOrBarParenQuestion {
    s = @"('foo'|'bar')?";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Alternation](/'foo'/|/'bar'/)/?^", [res description]);
    PKAlternation *alt = [res pop];
    TDTrue([alt isMemberOfClass:[PKAlternation class]]);
    
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    PKEmpty *e = [alt.subparsers objectAtIndex:0];
    TDTrue([PKEmpty class] == [e class]);
    
    alt = [alt.subparsers objectAtIndex:1];
    TDEqualObjects([alt class], [PKAlternation class]);
    TDEquals((NSUInteger)2, [alt.subparsers count]);
    
    PKLiteral *c = [alt.subparsers objectAtIndex:0];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"foo", c.string);
    
    c = [alt.subparsers objectAtIndex:1];
    TDTrue([c isKindOfClass:[PKLiteral class]]);
    TDEqualObjects(@"bar", c.string);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKAlternation class]);
    s = @"foo bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^bar", [res description]);

    s = @"bar bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^bar", [res description]);
}


- (void)testExprWord {
    s = @"Word";
    t.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Word]Word^", [res description]);
    PKWord *w = [res pop];
    TDTrue([w isMemberOfClass:[PKWord class]]);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKWord class]);
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[hello]hello^hello", [res description]);
}


- (void)testExprWordPlus {
    s = @"Word+";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[hello, hello]hello/hello^", [res description]);
}


- (void)testExprNum {
    s = @"Number";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Number]Number^", [res description]);
    PKNumber *w = [res pop];
    TDTrue([w isMemberOfClass:[PKNumber class]]);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKNumber class]]);
    
    s = @"333 444";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[333]333^444", [res description]);
    
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDNil(res);
}


- (void)testExprNumCardinality {
    s = @"Number{2}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Sequence]Number/{/2/}^", [res description]);
    PKSequence *seq = [res pop];
    TDEqualObjects([seq class], [PKSequence class]);
    
    TDEquals((NSUInteger)2, [seq.subparsers count]);
    PKNumber *n = [seq.subparsers objectAtIndex:0];
    TDEqualObjects([n class], [PKNumber class]);

    n = [seq.subparsers objectAtIndex:1];
    TDEqualObjects([n class], [PKNumber class]);

    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    
    s = @"333 444";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[333, 444]333/444^", [res description]);
    
    s = @"1.1 2.2 3.3";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[1.1, 2.2]1.1/2.2^3.3", [res description]);
    
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDNil(res);
}


- (void)testExprNumCardinality2 {
    s = @"Number{2,3}";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Sequence]Number/{/2/,/3/}^", [res description]);
    PKSequence *seq = [res pop];
    TDEqualObjects([seq class], [PKSequence class]);
    
    TDEquals((NSUInteger)3, [seq.subparsers count]);

    PKNumber *n = [seq.subparsers objectAtIndex:0];
    TDEqualObjects([n class], [PKNumber class]);
    
    n = [seq.subparsers objectAtIndex:1];
    TDEqualObjects([n class], [PKNumber class]);
    
    n = [seq.subparsers objectAtIndex:2];
    TDEqualObjects([n class], [PKAlternation class]);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSequence class]]);
    
    s = @"333 444";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[333, 444]333/444^", [res description]);
    
    s = @"1.1 2.2 3.3";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[1.1, 2.2, 3.3]1.1/2.2/3.3^", [res description]);
    
    s = @"1.1 2.2 3.3 4";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[1.1, 2.2, 3.3]1.1/2.2/3.3^4", [res description]);
    
    s = @"hello hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDNil(res);
}


- (void)testExprNumPlus {
    s = @"Number+";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    s = @"333 444";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[333, 444]333/444^", [res description]);
}


- (void)testExprSymbol {
    s = @"Symbol";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[Symbol]Symbol^", [res description]);
    PKSymbol *w = [res pop];
    TDTrue([w isMemberOfClass:[PKSymbol class]]);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKSymbol class]]);
    
    s = @"? #";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[?]?^#", [res description]);
    
    s = @"hello";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDNil(res);
}


- (void)testExprSymbolPlus {
    s = @"Symbol+";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    s = @"% *";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[%, *]%/*^", [res description]);
}


- (void)testExprQuotedString {
    s = @"QuotedString";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [exprSeq bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[QuotedString]QuotedString^", [res description]);
    PKQuotedString *w = [res pop];
    TDTrue([w isMemberOfClass:[PKQuotedString class]]);
    
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    TDEqualObjects([lp class], [PKQuotedString class]);
    s = @"'hello' 'hello'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"['hello']'hello'^'hello'", [res description]);
}


- (void)testExprQuotedStringPlus {
    s = @"QuotedString+";
    // use the result parser
    lp = [factory parserFromExpression:s];
    TDNotNil(lp);
    s = @"'hello' 'hello'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"['hello', 'hello']'hello'/'hello'^", [res description]);
}


- (void)testRubyHash {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"rubyhash" ofType:@"grammar"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lp = [factory parserFromGrammar:s assembler:nil];
    
    TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);
  
//    s = @"{\"brand\"=>{\"name\"=>\"something\","
//    @"\"logo\"=>#<File:/var/folders/RK/RK1vsZigGhijmL6ObznDJk+++TI/-Tmp-/CGI66145-4>,"
//    @"\"summary\"=>\"wee\", \"content\"=>\"woopy doo\"}, \"commit\"=>\"Save\","
//    @"\"authenticity_token\"=>\"43a94d60304a7fb13a4ff61a5960461ce714e92b\","
//    @"\"action\"=>\"create\", \"controller\"=>\"admin/brands\"}";

    lp.tokenizer.string = @"{'foo'=> {'logo' => #<File:/var/folders/RK/RK1vsZigGhijmL6ObznDJk+++TI/-Tmp-/CGI66145-4> } }";
    
    a = [PKTokenAssembly assemblyWithTokenizer:lp.tokenizer];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[{, 'foo', =>, {, 'logo', =>, #<File:/var/folders/RK/RK1vsZigGhijmL6ObznDJk+++TI/-Tmp-/CGI66145-4>, }, }]{/'foo'/=>/{/'logo'/=>/#<File:/var/folders/RK/RK1vsZigGhijmL6ObznDJk+++TI/-Tmp-/CGI66145-4>/}/}^", [res description]);
}


- (void)testSymbolState {
	s = @"@symbolState = 'b'; @start = ('b'|'ar')*;";
	lp = [factory parserFromGrammar:s assembler:nil];
	
	TDNotNil(lp);
    TDTrue([lp isKindOfClass:[PKParser class]]);

	lp.tokenizer.string = @"bar";
    a = [PKTokenAssembly assemblyWithTokenizer:lp.tokenizer];
    res = [lp bestMatchFor:a];
    TDEqualObjects(@"[b, ar]b/ar^", [res description]);
	[res pop]; // discar 'ar'
	PKToken *tok = [res pop];
	TDEqualObjects([tok class], [PKToken class]);
	TDEqualObjects(tok.stringValue, @"b");
	TDTrue(tok.isSymbol);
}

@end