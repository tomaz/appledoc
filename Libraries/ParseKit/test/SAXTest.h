//
//  SAXTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface SAXTest : SenTestCase {
    NSString *s;
    NSString *g;
    PKParserFactory *factory;
    PKTokenAssembly *a;
    PKAssembly *res;
    PKParser *p;
    PKTokenizer *t;    
}

@end
