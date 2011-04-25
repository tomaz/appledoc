//
//  PKSymbolTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDSymbolTest.h"


@implementation TDSymbolTest

- (void)tearDown {
}


- (void)testDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbolWithString:s];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[-]-^", [result description]);
}


- (void)testFalseDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbolWithString:@"+"];
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testTrueDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbol];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[-]-^", [result description]);
}


- (void)testDiscardDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [[PKSymbol symbolWithString:s] discard];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]-^", [result description]);
}
@end
