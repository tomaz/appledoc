//
//  PKParseTreeView.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PKParseTree;

@interface PKParseTreeView : NSView {
    PKParseTree *parseTree;
    NSDictionary *labelAttrs;
}
- (void)drawParseTree:(PKParseTree *)t;

@property (nonatomic, retain) PKParseTree *parseTree;
@property (nonatomic, retain) NSDictionary *labelAttrs;
@end
