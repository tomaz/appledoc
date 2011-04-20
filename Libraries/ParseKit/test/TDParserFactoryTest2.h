//
//  PKParserFactoryTest2.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "PKParserFactory.h"

@interface TDParserFactoryTest2 : SenTestCase {
    NSString *g;
    NSString *s;
    PKTokenAssembly *a;
    PKParserFactory *factory;
    PKAssembly *res;
    PKParser *lp; // language parser
    PKTokenizer *t;
    PKToken *tok;
}

@end
