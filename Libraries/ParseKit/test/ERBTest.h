//
//  ERBTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/26/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "PKParserFactory.h"

@interface ERBTest : SenTestCase {
    NSString *g;
    NSString *s;
    PKAssembly *res;
    PKParser *lp; // language parser
    PKTokenizer *t;
    PKToken *tok;
    PKToken *startPrintMarker;
}

@end
