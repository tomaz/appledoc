//
//  PKGenericAssemblerTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "PKParserFactory.h"
#import "TDMiniCSSAssembler.h"
#import "TDGenericAssembler.h"

@interface TDGenericAssemblerTest : SenTestCase {
    NSString *path;
    NSString *grammarString;
    NSString *s;
    TDMiniCSSAssembler *cssAssember;
    PKParserFactory *factory;
    PKParser *cssParser;
    PKAssembly *a;
    TDGenericAssembler *genericAssember;
}

@end
