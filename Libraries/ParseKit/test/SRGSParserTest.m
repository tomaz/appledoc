//
//  SRGSParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "SRGSParserTest.h"

@implementation SRGSParserTest

- (void)setUp {
    p = [[[SRGSParser alloc] init] autorelease];
}


- (void)test {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example1" ofType:@"srgs"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    a = [p assemblyWithString:s];
    result = [p bestMatchFor:a];
    TDNotNil(result);
    NSLog(@"\n\n\n result: %@ \n\n\n", result);
//    TDEqualObjects(@"[#, ABNF, 1.0, ;]#/ABNF/1.0/;^", [result description]);
}

- (void)testSelfIdentHeader {
    s = @"#ABNF 1.0;";
    a = [p assemblyWithString:s];
    result = [p.selfIdentHeader bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[#, ABNF, 1.0, ;]#/ABNF/1.0/;^", [result description]);

    s = @"#ABNF 1.0 UTF;";
    a = [p assemblyWithString:s];
    result = [p.selfIdentHeader bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[#, ABNF, 1.0, UTF, ;]#/ABNF/1.0/UTF/;^", [result description]);
}


- (void)testRuleName {
    s = @"$foobar";
    a = [p assemblyWithString:s];
    result = [p.ruleName bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[$, foobar]$/foobar^", [result description]);
}


- (void)testWeight {
    s = @"/4.0/";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [p.weight bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[/, 4.0, /]//4.0//^", [result description]);
}


- (void)testProbability {
    s = @"/4.0/";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [p.probability bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[/, 4.0, /]//4.0//^", [result description]);
}


- (void)testRepeat {
    s = @"1 - 4";
    a = [p assemblyWithString:s];
    result = [p.repeat bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[1, -, 4]1/-/4^", [result description]);

    s = @"1-4";
    a = [p assemblyWithString:s];
    result = [p.repeat bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[1, -, 4]1/-/4^", [result description]);
}


- (void)testToken {
    s = @"foobar";
    a = [p assemblyWithString:s];
    result = [p.token bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foobar]foobar^", [result description]);
    
    s = @"'foobar'";
    a = [p assemblyWithString:s];
    result = [p.token bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"['foobar']'foobar'^", [result description]);
}


- (void)testTag {
    s = @"{foobar}";
    a = [p assemblyWithString:s];
    result = [p.tag bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[{, foobar, }]{/foobar/}^", [result description]);

    s = @"{bar baz}";
    a = [p assemblyWithString:s];
    result = [p.tag bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[{, bar, baz, }]{/bar/baz/}^", [result description]);
    
    s = @"{bar 1.2 baz}";
    a = [p assemblyWithString:s];
    result = [p.tag bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[{, bar, 1.2, baz, }]{/bar/1.2/baz/}^", [result description]);
    
    s = @"{!{'foobar'}!}";
    a = [p assemblyWithString:s];
    result = [p.tag bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[{, !, {, 'foobar', }, !, }]{/!/{/'foobar'/}/!/}^", [result description]);

    s = @"{!{'foobar' baz}!}";
    a = [p assemblyWithString:s];
    result = [p.tag bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[{, !, {, 'foobar', baz, }, !, }]{/!/{/'foobar'/baz/}/!/}^", [result description]);
}


- (void)testBaseDecl {
    s = @"base url-goes-here;";
    a = [p assemblyWithString:s];
    result = [p.baseDecl bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[base, url-goes-here, ;]base/url-goes-here/;^", [result description]);
}


- (void)testLanguageDecl {
    s = @"language en-us;";
    a = [p assemblyWithString:s];
    result = [p.languageDecl bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[language, en-us, ;]language/en-us/;^", [result description]);
}


- (void)testModeDecl {
    s = @"mode voice;";
    a = [p assemblyWithString:s];
    result = [p.modeDecl bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[mode, voice, ;]mode/voice/;^", [result description]);
    
    s = @"mode dtmf;";
    a = [p assemblyWithString:s];
    result = [p.modeDecl bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[mode, dtmf, ;]mode/dtmf/;^", [result description]);
}


- (void)testRootRuleDecl {
    s = @"root $foobar;";
    a = [p assemblyWithString:s];
    result = [p.rootRuleDecl bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[root, $, foobar, ;]root/$/foobar/;^", [result description]);
}


- (void)testLanguageAttachment {
    s = @"!en-us";
    a = [p assemblyWithString:s];
    result = [p.languageAttachment bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[!, en-us]!/en-us^", [result description]);
}


- (void)testRepeatOperator {
    s = @"<0-2 /0.6/>";
    a = [p assemblyWithString:s];
    result = [p.repeatOperator bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[<, 0, -, 2, /, 0.6, /, >]</0/-/2///0.6///>^", [result description]);
}




@end
