//
//  PKPlistParserTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/9/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "TDPlistParser.h"

@interface TDPlistParserTest : SenTestCase {
    TDPlistParser *p;
    NSString *s;
    PKTokenAssembly *a;
    PKAssembly *res;
}

@end
