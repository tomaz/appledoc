//
//  PKToken+Blob.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKToken.h>

extern const NSInteger PKTokenTypeBlob;

@interface PKToken (Blob)
- (BOOL)isBlob;
@end

