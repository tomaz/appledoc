//
//  PKXmlNameTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlNameTest.h"
#import "TDXmlNameState.h"
#import "TDXmlNmtokenState.h"
#import "TDXmlToken.h"

@implementation TDXmlNameTest
//
//- (void)test {
//    NSString *s = @"_foob?ar _foobar 2baz";
//    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
//    
//    //Name       ::=       (Letter | '_' | ':') (NameChar)*
//    TDXmlNameState *nameState = [[[TDXmlNameState alloc] init] autorelease];
//    
//    [t setTokenizerState:nameState from: '_' to: '_'];
//    [t setTokenizerState:nameState from: ':' to: ':'];
//    [t setTokenizerState:nameState from: 'a' to: 'z'];
//    [t setTokenizerState:nameState from: 'A' to: 'Z'];
//    [t setTokenizerState:nameState from:0xc0 to:0xff];
//    
//    TDXmlNmtokenState *nmtokenState = [[[TDXmlNmtokenState alloc] init] autorelease];
//    [t setTokenizerState:nmtokenState from: '0' to: '9'];
//    
//    TDXmlToken *tok = nil;
//    
//    // _foob
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//
//    // '?'
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isSymbol);
//    
//    // ar
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//    
//    // _foobar
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//    
//    // 2baz
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isNmtoken);
//    NSLog(@"tok: %@", tok);
//    
//}

@end
