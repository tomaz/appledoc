//
//  PKMinusTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/26/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDDifferenceTest : SenTestCase {
    PKTokenizer *t;
    PKDifference *d;
    PKParser *minus;
    PKAssembly *a;
    PKAssembly *res;
    NSString *s;    
}

@end
