//
//  PKParserFactoryTest3.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDParserFactoryTest3 : SenTestCase {
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
