//
//  PKParserFactoryTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import "TDTestScaffold.h"
#import "PKParserFactory.h"

@interface TDParserFactoryTest : SenTestCase {
    NSString *s;
    PKTokenAssembly *a;
    PKParserFactory *factory;
    PKAssembly *res;

    PKSequence *exprSeq;
    PKTokenizer *t;
    PKParser *lp; // language parser
}

@end
