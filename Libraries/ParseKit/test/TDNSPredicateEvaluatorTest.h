//
//  PKNSPredicateEvaluatorTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "TDNSPredicateEvaluator.h"

@interface TDNSPredicateEvaluatorTest : SenTestCase <TDKeyPathResolver> {
    TDNSPredicateEvaluator *eval;
    NSString *s;
    PKAssembly *a;
    PKAssembly *res;
    PKTokenizer *t;
    
    NSMutableDictionary *d;
}

@end
