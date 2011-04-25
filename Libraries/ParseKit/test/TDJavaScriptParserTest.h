//
//  PKJavaScriptParserTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/22/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "TDJavaScriptParser.h"

@interface TDJavaScriptParserTest : SenTestCase {
    TDJavaScriptParser *jsp;
    NSString *s;
    PKTokenAssembly *a;
    id res;
}

@end
