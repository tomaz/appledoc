//
//  XPathParserGrammarTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/28/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface XPathParserGrammarTest : SenTestCase {
    NSString *s;
    PKParser *p;
    PKTokenizer *t;
    PKAssembly *a;
    PKAssembly *res;
    PKToken *tok;
}

@end
