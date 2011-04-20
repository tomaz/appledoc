//
//  PKXmlName.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlName.h"
#import "PKToken.h"

@implementation TDXmlName

+ (id)name {
    return [[[self alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    if (!tok.isWord) {
        return NO;
    }
    
    //NSString *s = tok.stringValue;
    if (YES) {
        
    }
    
    return YES;
}

@end
