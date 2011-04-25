//
//  TDNegationTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDNegationTest : SenTestCase {
    PKNegation *n;
    PKTokenizer *t;
    PKAssembly *a;
    PKAssembly *res;
    NSString *s;    
}

@end
