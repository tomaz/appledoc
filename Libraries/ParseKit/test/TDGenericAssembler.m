//
//  PKGenericAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/22/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDGenericAssembler.h"
#import "NSArray+ParseKitAdditions.h"
#import <ParseKit/ParseKit.h>

@interface TDGenericAssembler ()
- (void)didMatchTerminalNamed:(NSString *)name withAssembly:(PKAssembly *)a;
- (void)appendAttributedStringForObjects:(NSArray *)objs withAttrs:(id)attrs;
- (void)appendAttributedStringForObject:(id)obj withAttrs:(id)attrs;
- (NSMutableArray *)popWhitespaceTokensFrom:(PKAssembly *)a;
- (void)consumeWhitespaceTokens:(NSArray *)whitespaceToks;
- (void)consumeWhitespaceToken:(PKToken *)whitespaceTok;
- (void)consumeWhitespaceFrom:(PKAssembly *)a;
    
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *suffix;
@end

@implementation TDGenericAssembler

- (id)init {
    if (self = [super init]) {
        self.productionNames = [NSMutableDictionary dictionary];
        self.defaultProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSColor blackColor], NSForegroundColorAttributeName,
                                  [NSColor whiteColor], NSBackgroundColorAttributeName,
                                  [NSFont fontWithName:@"Monaco" size:11.0], NSFontAttributeName,
                                  nil];
        self.prefix = @"didMatch";
        self.suffix = @":";
    }
    return self;
}


- (void)dealloc {
    self.attributes = nil;
    self.defaultProperties = nil;
    self.productionNames = nil;
    self.currentAssembly = nil;
    self.prefix = nil;
    self.suffix = nil;
    [super dealloc];
}


- (BOOL)respondsToSelector:(SEL)sel {
    return YES;
}


- (id)performSelector:(SEL)sel withObject:(id)obj {
    NSString *selName = NSStringFromSelector(sel);
    
    NSString *productionName = [productionNames objectForKey:selName];
    
    if (!productionName) {
        NSUInteger prefixLen = [prefix length];
        NSInteger c = ((NSInteger)[selName characterAtIndex:prefixLen]) + 32; // lowercase
        NSRange r = NSMakeRange(prefixLen + 1, [selName length] - (prefixLen + [suffix length] + 1 /*:*/));
        productionName = [NSString stringWithFormat:@"%C%@", c, [selName substringWithRange:r]];
        [productionNames setObject:productionName forKey:selName];
    }
    
    [self didMatchTerminalNamed:productionName withAssembly:obj];
    
    return nil;
}


- (void)didMatchTerminalNamed:(NSString *)name withAssembly:(PKAssembly *)a {
    //NSLog(@"%@ : %@", name, a);
    self.currentAssembly = a;
    NSMutableArray *whitespaceToks = [self popWhitespaceTokensFrom:a];

    id props = [attributes objectForKey:name];
    if (!props) props = defaultProperties;
    
    NSMutableArray *toks = nil;
    PKToken *tok = nil;
    while (tok = [a pop]) {
        if (PKTokenTypeWhitespace != tok.tokenType) {
            if (!toks) toks = [NSMutableArray array];
            [toks addObject:tok];
        } else {
            [self consumeWhitespaceToken:tok];
            break;
        }
    }
    
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:toks withAttrs:props];
    [self consumeWhitespaceTokens:whitespaceToks];
}


- (void)appendAttributedStringForObjects:(NSArray *)objs withAttrs:(id)attrs {
    for (id obj in objs) {
        [self appendAttributedStringForObject:obj withAttrs:attrs];
    }
}


- (void)appendAttributedStringForObject:(id)obj withAttrs:(id)attrs {
    NSMutableAttributedString *displayString = currentAssembly.target;
    if (!displayString) {
        displayString = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] autorelease];
        currentAssembly.target = displayString;
    }

    
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:[obj stringValue] attributes:attrs];
    [displayString appendAttributedString:as];
    [as release];
}


- (NSMutableArray *)popWhitespaceTokensFrom:(PKAssembly *)a {
    NSMutableArray *whitespaceToks = nil;
    PKToken *tok = nil;
    while (tok = [a pop]) {
        if (PKTokenTypeWhitespace == tok.tokenType) {
            if (!whitespaceToks) {
                whitespaceToks = [NSMutableArray array];
            }
            [whitespaceToks addObject:tok];
        } else {
            [a push:tok];
            break;
        }
    }
    if (whitespaceToks) {
        whitespaceToks = [whitespaceToks reversedMutableArray];
    }
    return whitespaceToks;
}


- (void)consumeWhitespaceTokens:(NSArray *)whitespaceToks {
    [self appendAttributedStringForObjects:whitespaceToks withAttrs:nil];
}


- (void)consumeWhitespaceToken:(PKToken *)whitespaceTok {
    [self appendAttributedStringForObject:whitespaceTok withAttrs:nil];
}


- (void)consumeWhitespaceFrom:(PKAssembly *)a {
    NSMutableArray *whitespaceToks = [self popWhitespaceTokensFrom:a];
    if (whitespaceToks) {
        [self consumeWhitespaceTokens:whitespaceToks];
    }
}

@synthesize attributes;
@synthesize defaultProperties;
@synthesize productionNames;
@synthesize currentAssembly;
@synthesize prefix;
@synthesize suffix;
@end
