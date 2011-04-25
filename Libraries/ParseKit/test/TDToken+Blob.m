//
//  PKToken+Blob.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKToken+Blob.h"

const NSInteger PKTokenTypeBlob = 200;

@implementation PKToken (Blob)

- (BOOL)isBlob {
    return PKTokenTypeBlob == self.tokenType;
}

@end

