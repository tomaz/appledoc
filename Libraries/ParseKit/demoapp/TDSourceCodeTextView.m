//
//  TDSourceCodeTextView.m
//  TextTest
//
//  Created by Todd Ditchendorf on 9/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TDSourceCodeTextView.h"
#import "TDGutterView.h"

@interface TDSourceCodeTextView ()
- (void)registerForNotifications;
- (void)getRectsOfVisibleLines:(NSArray **)outRects startingLineNumber:(NSUInteger *)outRect;
- (NSUInteger)lineNumberForIndex:(NSUInteger)inIndex;
@end

@implementation TDSourceCodeTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.gutterView = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [self registerForNotifications];
    [self renderGutter];
}


- (void)textDidChange:(NSNotification *)n {
    [self renderGutter];
}


- (void)viewBoundsChanged:(NSNotification *)n {
    [self renderGutter];
}


- (void)renderGutter {
    if (![[self window] isVisible]) return;
    NSArray *rects = nil;
    NSUInteger start = 0;
    [self getRectsOfVisibleLines:&rects startingLineNumber:&start];
    gutterView.lineNumberRects = rects;
    gutterView.startLineNumber = start;
    [gutterView setNeedsDisplay:YES];        
}


- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:self];
    
    [scrollView.contentView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:scrollView.contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewBoundsChanged:)
                                                 name:NSWindowDidResizeNotification
                                               object:self.window];
}


//- (void)showFindIndicatorForRange:(NSRange)charRange;

- (void)getRectsOfVisibleLines:(NSArray **)outRects startingLineNumber:(NSUInteger *)outStart {
    NSMutableArray *result = [NSMutableArray array];
    NSString *s = self.string;
    
    NSLayoutManager *layoutMgr = self.textContainer.layoutManager;
    NSRect boundingRect = [scrollView.contentView documentVisibleRect];
    CGFloat scrollY = boundingRect.origin.y;
    NSRange visibleGlyphRange = [layoutMgr glyphRangeForBoundingRect:boundingRect inTextContainer:self.textContainer];
        
    NSUInteger index = visibleGlyphRange.location;
    NSUInteger length = index + [visibleGlyphRange length];

    (*outStart) = [self lineNumberForIndex:index + 1];
    
    while (index < length) {
        NSRange r = [s lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange(r);
        NSRect rect = [layoutMgr lineFragmentRectForGlyphAtIndex:r.location effectiveRange:NULL withoutAdditionalLayout:YES];
        rect.origin.y -= scrollY;
        [result addObject:[NSValue valueWithRect:rect]];
    }
    
    (*outRects) = result;
}


- (NSUInteger)lineNumberForIndex:(NSUInteger)inIndex {
    NSString *s = self.string;
    NSUInteger numberOfLines, index, stringLength = [s length];
    
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
        NSRange r = [s lineRangeForRange:NSMakeRange(index, 0)];
        index = NSMaxRange(r);
        if (inIndex <= index) {
            break;
        }
    }
    
    return numberOfLines;
}

@synthesize gutterView;
@end
