//
//  TDGutterView.h
//  TextTest
//
//  Created by Todd Ditchendorf on 9/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDGutterView : NSView {
    IBOutlet NSScrollView *sourceScrollView;
    IBOutlet NSTextView *sourceTextView;

    NSArray *lineNumberRects;
    NSUInteger startLineNumber;
    
    NSDictionary *attrs;
}
@property (retain) NSArray *lineNumberRects;
@property NSUInteger startLineNumber;

@property (retain) NSScrollView *sourceScrollView;
@property (retain) NSTextView *sourceTextView;
@end
