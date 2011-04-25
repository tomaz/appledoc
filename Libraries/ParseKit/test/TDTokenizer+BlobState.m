//
//  PKTokenizer+BlobState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKTokenizer+BlobState.h"
#import "TDBlobState.h"

static NSMutableDictionary *sBlobCache = nil;

@implementation PKTokenizer (BlobState)

- (TDBlobState *)blobState {
    TDBlobState *bs = nil;
    
    @synchronized (self) {
        if (!sBlobCache) {
            sBlobCache = [[NSMutableDictionary alloc] init];
        }

        NSString *key = [NSString stringWithFormat:@"%p", self];
        bs = [sBlobCache objectForKey:key];
        
        if (!bs) {
            bs = [[[TDBlobState alloc] init] autorelease];
            [sBlobCache setObject:bs forKey:key];
        }
    }

    return bs;
}

@end
