//
//  XPathAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPathContext;
@class PKReader;

@interface XPathAssembler : NSObject {
    XPathContext *context;
}
- (void)resetWithReader:(PKReader *)r;
@property (retain) XPathContext *context;
@end
