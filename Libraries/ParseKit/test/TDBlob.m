//
//  PKBlob.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDBlob.h"
#import <ParseKit/PKToken.h>
#import "PKToken+Blob.h"

@implementation TDBlob

+ (id)blob {
    return [self blobWithStartMarker:nil];
}


+ (id)blobWithStartMarker:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    BOOL result = tok.isBlob;
    if (self.string) {
        result = [tok.stringValue hasPrefix:self.string];
    }
    return result;
}

@end
