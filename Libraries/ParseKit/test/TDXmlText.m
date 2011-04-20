//
//  PKXmlText.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlText.h"
#import "TDXmlToken.h"

@implementation TDXmlText

+ (id)text {
    return [[[self alloc] initWithString:nil] autorelease];
}


+ (id)textWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)initWithString:(NSString *)s {
    NSLog(@"%s", _cmd);
    self = [super initWithString:s];
    if (self) {
        self.tok = [TDXmlToken tokenWithTokenType:TDTT_XML_TEXT stringValue:s];
        NSLog(@"tok : %@", tok);
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    TDXmlToken *other = (TDXmlToken *)obj;
    NSLog(@"%s obj: %@ isText: %d", _cmd, obj, other.isText);
    
    if ([string length]) {
        return [tok isEqual:other];
    } else {
        return other.isText;
    }
}

@end
