//
//  PKMiniCSSAssemblerTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "PKParserFactory.h"
#import "TDMiniCSSAssembler.h"

@interface TDMiniCSSAssemblerTest : SenTestCase {
    NSString *path;
    NSString *grammarString;
    NSString *s;
    TDMiniCSSAssembler *ass;
    PKParserFactory *factory;
    PKParser *lp;
    PKAssembly *a;
}

@end
