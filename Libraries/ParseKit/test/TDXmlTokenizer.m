//
//  PKXmlTokenizer.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTokenizer.h"
#import "XMLReader.h"
#import "TDXmlToken.h"

@interface TDXmlTokenizer ()
@property (nonatomic, retain) XMLReader *reader;
@end

@implementation TDXmlTokenizer

+ (id)tokenizerWithContentsOfFile:(NSString *)path {
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}


- (id)init {
    return nil;
}


- (id)initWithContentsOfFile:(NSString *)path {
    if (self = [super init]) {
        self.reader = [[[XMLReader alloc] initWithContentsOfFile:path] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.reader = nil;
    [super dealloc];
}


- (TDXmlToken *)nextToken {
    TDXmlToken *tok = nil;
    NSInteger ret = -1;
    NSInteger nodeType = -1;
    
    do {
        ret = [reader read];    
        nodeType = reader.nodeType;
    } while (nodeType == TDTT_XML_SIGNIFICANT_WHITESPACE || nodeType == TDTT_XML_WHITESPACE);

    if (ret <= 0) {
        tok = [TDXmlToken EOFToken];
    } else {
        tok = [TDXmlToken tokenWithTokenType:reader.nodeType stringValue:reader.name];
    }
    
    return tok;
}

@synthesize reader;
@end
