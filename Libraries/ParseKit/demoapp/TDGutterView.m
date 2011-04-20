//
//  TDGutterView.m
//  TextTest
//
//  Created by Todd Ditchendorf on 9/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TDGutterView.h"

@interface TDGutterView ()
@property (retain) NSDictionary *attrs;
@end

@implementation TDGutterView

- (void)awakeFromNib {
    self.attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSFont userFixedPitchFontOfSize:11.], NSFontAttributeName,
                  [NSColor grayColor], NSForegroundColorAttributeName,
                  nil];    
}


- (void)dealloc {
    self.sourceScrollView = nil;
    self.sourceTextView = nil;
    self.lineNumberRects = nil;
    self.attrs = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (NSUInteger)autoresizingMask {
    return NSViewHeightSizable;
}


- (void)drawRect:(NSRect)rect {
    NSDrawWindowBackground(rect);
    
    CGFloat rectWidth = rect.size.width;
    NSPoint p1 = NSMakePoint(rectWidth + 2., 0.);
    NSPoint p2 = NSMakePoint(rectWidth + 2., rect.size.height);
    [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
    
    if (![lineNumberRects count]) {
        return;
    }
    
    NSUInteger i = startLineNumber;
    NSUInteger count = i + [lineNumberRects count];
    
    for ( ; i < count; i++) {
        NSRect r = [[lineNumberRects objectAtIndex:i - startLineNumber] rectValue];

        // set the x origin of the number according to the number of digits it contains
        CGFloat x = 0.;
        if (i < 9) {
            x = rectWidth - 14.;
        } else if (i < 99) {
            x = rectWidth - 21.;
        } else if (i < 999) {
            x = rectWidth - 28.;
        } else if (i < 9999) {
            x = rectWidth - 35.;
        }
        r.origin.x = x;
        
        // center the number vertically for tall lines
        if (r.origin.y) {
            r.origin.y += r.size.height/2. - 7.;
        }
        
        NSString *s = [[NSNumber numberWithInteger:i + 1] stringValue];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:s attributes:attrs];
        [as drawAtPoint:r.origin];
        [as release];
    }
}

@synthesize sourceScrollView;
@synthesize sourceTextView;
@synthesize lineNumberRects;
@synthesize startLineNumber;
@synthesize attrs;
@end
