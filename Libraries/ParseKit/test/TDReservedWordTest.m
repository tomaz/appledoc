//
//  PKReservedWordTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDReservedWordTest.h"
#import "ParseKit.h"

@implementation TDReservedWordTest

- (void)testFoobar {
    NSString *s = @"Foobar";
    [TDReservedWord setReservedWords:[NSArray arrayWithObject:@"Foobar"]];
    
    PKAssembly *a = [PKTokenAssembly assemblyWithString:s];
    
    PKParser *p = [TDReservedWord word];
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[Foobar]Foobar^", [result description]);
//    TDNil(result);
}


- (void)testfoobar {
    NSString *s = @"foobar";
    [TDReservedWord setReservedWords:[NSArray arrayWithObject:@"Foobar"]];
    
    PKAssembly *a = [PKTokenAssembly assemblyWithString:s];
    
    PKParser *p = [TDReservedWord word];
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNil(result);
}

@end
