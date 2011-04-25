//
//  PKPredicateEvaluatorTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/28/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "TDPredicateEvaluator.h"

@interface TDPredicateEvaluatorTest : SenTestCase <TDPredicateEvaluatorDelegate> {
    TDPredicateEvaluator *p;
    NSString *s;
    PKAssembly *a;
    
    NSMutableDictionary *d;
}

@end
