//
//  PKParseTreeView.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKParseTreeView.h"
#import <ParseKit/ParseKit.h>
#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"
#import "PKParseTreeAssembler.h"

#define ROW_HEIGHT 50.0
#define CELL_WIDTH 55.0

@interface PKParseTreeView ()
- (void)drawTree:(PKParseTree *)n atPoint:(NSPoint)p;
- (void)drawParentNode:(PKParseTree *)n atPoint:(NSPoint)p;
- (void)drawLeafNode:(PKTokenNode *)n atPoint:(NSPoint)p;

- (CGFloat)widthForNode:(PKParseTree *)n;
- (CGFloat)depthForNode:(PKParseTree *)n;
- (NSString *)labelFromNode:(PKParseTree *)n;
- (void)drawLabel:(NSString *)label atPoint:(NSPoint)p;
@end

@implementation PKParseTreeView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.labelAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont boldSystemFontOfSize:10], NSFontAttributeName,
                           [NSColor blackColor], NSForegroundColorAttributeName,
                           nil];
    }
    return self;
}


- (void)dealloc {
    self.parseTree = nil;
    self.labelAttrs = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (void)drawParseTree:(PKParseTree *)t {
    self.parseTree = t;
    
    CGFloat w = [self widthForNode:parseTree] * CELL_WIDTH;
    CGFloat h = [self depthForNode:parseTree] * ROW_HEIGHT + 120;
    
    NSSize minSize = [[self superview] bounds].size;
    w = w < minSize.width ? minSize.width : w;
    h = h < minSize.height ? minSize.height : h;
    [self setFrame:NSMakeRect(0, 0, w, h)];
    
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)r {
    [[NSColor whiteColor] set];
    NSRectFill(r);
    
    [self drawTree:parseTree atPoint:NSMakePoint(r.size.width / 2, 20)];
}


- (void)drawTree:(PKParseTree *)n atPoint:(NSPoint)p {
    if ([n isKindOfClass:[PKTokenNode class]]) {
        [self drawLeafNode:(id)n atPoint:p];
    } else {
        [self drawParentNode:n atPoint:p];
    }
}


- (void)drawParentNode:(PKParseTree *)n atPoint:(NSPoint)p {
    // draw own label
    [self drawLabel:[self labelFromNode:n] atPoint:NSMakePoint(p.x, p.y)];

    NSUInteger i = 0;
    NSUInteger c = [[n children] count];

    // get total width
    CGFloat widths[c];
    CGFloat totalWidth = 0;
    for (PKParseTree *child in [n children]) {
        widths[i] = [self widthForNode:child] * CELL_WIDTH;
        totalWidth += widths[i++];
    }
    
    
    // draw children
    NSPoint points[c];
    if (1 == c) {
        points[0] = NSMakePoint(p.x, p.y + ROW_HEIGHT);
        [self drawTree:[[n children] objectAtIndex:0] atPoint:points[0]];
    } else {
        CGFloat x = 0;
        CGFloat buff = 0;
        for (i = 0; i < c; i++) {
            x = p.x - (totalWidth/2) + buff + widths[i]/2;
            buff += widths[i];

            points[i] = NSMakePoint(x, p.y + ROW_HEIGHT);
            [self drawTree:[[n children] objectAtIndex:i] atPoint:points[i]];
        }
    }
    
    // draw lines
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    for (i = 0; i < c; i++) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, p.x, p.y + 15);
        CGContextAddLineToPoint(ctx, points[i].x, points[i].y - 4);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
    }
}


- (void)drawLeafNode:(PKTokenNode *)n atPoint:(NSPoint)p {
    [self drawLabel:[self labelFromNode:n] atPoint:NSMakePoint(p.x, p.y)];
}


- (CGFloat)widthForNode:(PKParseTree *)n {
    CGFloat res = 0;
    for (PKParseTree *child in [n children]) {
        res += [self widthForNode:child];
    }
    return res ? res : 1;
}
    
    
- (CGFloat)depthForNode:(PKParseTree *)n {
    CGFloat res = 0;
    for (PKParseTree *child in [n children]) {
        CGFloat n = [self depthForNode:child];
        res = n > res ? n : res;
    }
    return res + 1;
}


- (NSString *)labelFromNode:(PKParseTree *)n {
    if ([n isKindOfClass:[PKTokenNode class]]) {
        return [[(PKTokenNode *)n token] stringValue];
    } else if ([n isKindOfClass:[PKRuleNode class]]) {
        return [(PKRuleNode *)n name];
    } else {
        return @"root";
    }
}


- (void)drawLabel:(NSString *)label atPoint:(NSPoint)p {
    NSSize labelSize = [label sizeWithAttributes:labelAttrs];
    NSRect maxRect = NSMakeRect(p.x - CELL_WIDTH / 2, p.y, CELL_WIDTH, labelSize.height);
    
    if (!NSContainsRect(maxRect, NSMakeRect(maxRect.origin.x, maxRect.origin.y, labelSize.width, labelSize.height))) {
        labelSize = maxRect.size;
    }
    
    p.x -= labelSize.width / 2;
    NSRect r = NSMakeRect(p.x, p.y, labelSize.width, labelSize.height);
    NSUInteger opts = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin;
    [label drawWithRect:r options:opts attributes:labelAttrs];
}

@synthesize parseTree;
@synthesize labelAttrs;
@end
