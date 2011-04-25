//
//  TDSourceCodeTextView.h
//  TextTest
//
//  Created by Todd Ditchendorf on 9/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDGutterView;

@interface TDSourceCodeTextView : NSTextView {
    IBOutlet TDGutterView *gutterView;
    IBOutlet NSScrollView *scrollView;
    CGFloat sourceTextViewOffset;
}
- (void)renderGutter;

@property (assign) TDGutterView *gutterView;
@end
