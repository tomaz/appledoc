//
//  PKXmlTerminal.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTerminal.h"
#import "TDXmlToken.h"

@implementation TDXmlTerminal

- (void)dealloc {
    self.tok = nil;
    [super dealloc];
}

@synthesize tok;
@end
