//
//  PKJsonParserTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@class TDJsonParser;

@interface TDJsonParserTest : SenTestCase {
    TDJsonParser *p;
    NSString *s;
    PKAssembly *a;
    PKAssembly *result;
}

@end
