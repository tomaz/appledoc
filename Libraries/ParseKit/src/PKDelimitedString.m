//
//  PKDelimitedString.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/21/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKDelimitedString.h>
#import <ParseKit/PKToken.h>

@interface PKDelimitedString ()
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end

@implementation PKDelimitedString

+ (id)delimitedString {
    return [self delimitedStringWithStartMarker:nil];
}


+ (id)delimitedStringWithStartMarker:(NSString *)start {
    return [self delimitedStringWithStartMarker:start endMarker:nil];
}


+ (id)delimitedStringWithStartMarker:(NSString *)start endMarker:(NSString *)end {
    PKDelimitedString *ds = [[[self alloc] initWithString:nil] autorelease];
    ds.startMarker = start;
    ds.endMarker = end;
    return ds;
}


- (void)dealloc {
    self.startMarker = nil;
    self.endMarker = nil;
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    BOOL result = tok.isDelimitedString;
    if (result && [startMarker length]) {
        result = [tok.stringValue hasPrefix:startMarker];
        if (result && [endMarker length]) {
            result = [tok.stringValue hasSuffix:endMarker];
        }
    }
    return result;
}

@synthesize startMarker;
@synthesize endMarker;
@end