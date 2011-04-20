//
//  XPathContext.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "XPathContext.h"

@implementation XPathContext

- (id)init {
    if (self = [super init]) {
    }
    return self;
}


- (void)resetWithCurrentNode:(NSXMLNode *)n {
    self.currentNode = n;
    self.contextNode = nil;
    self.contextNodeSet = nil;
}


- (void)dealloc {
    self.currentNode = nil;
    self.contextNode = nil;
    self.contextNodeSet = nil;
    [super dealloc];
}

@synthesize currentNode;
@synthesize contextNode;
@synthesize contextNodeSet;
@end
