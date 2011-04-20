//
//  PKXmlNmtoken.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlNmtoken.h"
#import "TDXmlToken.h"

@implementation TDXmlNmtoken

+ (id)nmtoken {
    return [[[self alloc] initWithString:nil] autorelease];
}


//- (BOOL)qualifies:(id)obj {
//    TDXmlToken *tok = (TDXmlToken *)obj;
//    return tok.isNmtoken;
//}

@end
