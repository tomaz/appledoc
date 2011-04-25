//
//  XPathAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "XPathAssembler.h"
#import <ParseKit/ParseKit.h>
#import "XPathContext.h"

@implementation XPathAssembler

- (id)init {
    if (self = [super init]) {
        self.context = [[[XPathContext alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.context = nil;
    [super dealloc];
}


- (void)resetWithReader:(PKReader *)r {
    [context resetWithCurrentNode:nil];
}


- (void)didMatchAxisSpecifier:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
    
    //PKToken *tok = [a pop];
    
}


- (void)didMatchNodeTest:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}


- (void)didMatchPredicate:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}

// [4] Step ::=       AxisSpecifier NodeTest Predicate* | AbbreviatedStep    
- (void)didMatchStep:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}



@synthesize context;
@end
