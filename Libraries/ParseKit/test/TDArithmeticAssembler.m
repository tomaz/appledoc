//
//  TDArithmeticAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 9/4/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDArithmeticAssembler.h"
#import <ParseKit/ParseKit.h>

@implementation TDArithmeticAssembler

- (void)didMatchPlus:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue + tok2.floatValue]];
}


- (void)didMatchMinus:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue - tok2.floatValue]];
}


- (void)didMatchTimes:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue * tok2.floatValue]];
}


- (void)didMatchDivide:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue / tok2.floatValue]];
}


- (void)didMatchExp:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    
    CGFloat n1 = tok1.floatValue;
    CGFloat n2 = tok2.floatValue;
    
    CGFloat res = n1;
    NSUInteger i = 1;
    for ( ; i < n2; i++) {
        res *= n1;
    }
    
    [a push:[NSNumber numberWithDouble:res]];
}

@end
