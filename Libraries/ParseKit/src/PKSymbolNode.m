//
//  PKSymbolNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKSymbolNode.h>
#import <ParseKit/PKSymbolRootNode.h>

@interface PKSymbolNode ()
@property (nonatomic, readwrite, retain) NSString *ancestry;
@property (nonatomic, assign) PKSymbolNode *parent;  // this must be 'assign' to avoid retain loop leak
@property (nonatomic, retain) NSMutableDictionary *children;
@property (nonatomic) PKUniChar character;
@property (nonatomic, retain) NSString *string;

- (void)determineAncestry;
@end

@implementation PKSymbolNode

- (id)initWithParent:(PKSymbolNode *)p character:(PKUniChar)c {
    if (self = [super init]) {
        self.parent = p;
        self.character = c;
        self.children = [NSMutableDictionary dictionary];

        // this private property is an optimization. 
        // cache the NSString for the char to prevent it being constantly recreated in -determinAncestry
        self.string = [NSString stringWithFormat:@"%C", character];

        [self determineAncestry];
    }
    return self;
}


- (void)dealloc {
    parent = nil; // makes clang static analyzer happy
    self.ancestry = nil;
    self.string = nil;
    self.children = nil;
    [super dealloc];
}


- (void)determineAncestry {
    if (PKEOF == parent.character) { // optimization for sinlge-char symbol (parent is symbol root node)
        self.ancestry = string;
    } else {
        NSMutableString *result = [NSMutableString string];
        
        PKSymbolNode *n = self;
        while (PKEOF != n.character) {
            [result insertString:n.string atIndex:0];
            n = n.parent;
        }
        
        //self.ancestry = [[result copy] autorelease]; // assign an immutable copy
        self.ancestry = result; // optimization
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKSymbolNode %@>", self.ancestry];
}

@synthesize ancestry;
@synthesize parent;
@synthesize character;
@synthesize string;
@synthesize children;
@end
