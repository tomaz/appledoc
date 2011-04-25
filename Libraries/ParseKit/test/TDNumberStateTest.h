//
//  PKNumberStateTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/29/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDNumberStateTest : SenTestCase {
    PKNumberState *numberState;
    PKTokenizer *t;
    PKReader *r;
    NSString *s;
}
@end
