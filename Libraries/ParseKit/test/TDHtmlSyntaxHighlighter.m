//
//  PKHtmlSyntaxHighlighter.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDHtmlSyntaxHighlighter.h"
#import "NSArray+ParseKitAdditions.h"
#import <ParseKit/ParseKit.h>

@interface TDHtmlSyntaxHighlighter ()
- (void)didMatchTag;
- (void)didMatchText;
- (void)didMatchComment;
- (void)didMatchCDATA;
- (void)didMatchPI;
- (void)didMatchDoctype;
- (void)didMatchScript;
- (id)peek;
- (id)pop;
- (NSArray *)objectsAbove:(id)fence;
- (PKToken *)nextNonWhitespaceTokenFrom:(NSEnumerator *)e;
- (void)consumeWhitespaceOnStack;

@property (retain) PKTokenizer *tokenizer;
@property (retain) NSMutableArray *stack;
@property (retain) PKToken *ltToken;
@property (retain) PKToken *gtToken;
@property (retain) PKToken *startCommentToken;
@property (retain) PKToken *endCommentToken;
@property (retain) PKToken *startCDATAToken;
@property (retain) PKToken *endCDATAToken;
@property (retain) PKToken *startPIToken;
@property (retain) PKToken *endPIToken;
@property (retain) PKToken *startDoctypeToken;
@property (retain) PKToken *fwdSlashToken;
@property (retain) PKToken *eqToken;
@property (retain) PKToken *scriptToken;
@property (retain) PKToken *endScriptToken;
@end

@implementation TDHtmlSyntaxHighlighter

- (id)init {
    return [self initWithAttributesForDarkBackground:NO];
}


- (id)initWithAttributesForDarkBackground:(BOOL)isDark {
    if (self = [super init]) {
        isDarkBG = isDark;
        self.tokenizer = [PKTokenizer tokenizer];
        
        [tokenizer setTokenizerState:tokenizer.symbolState from:'/' to:'/']; // XML doesn't have slash slash or slash star comments
        tokenizer.whitespaceState.reportsWhitespaceTokens = YES;
        [tokenizer.wordState setWordChars:YES from:':' to:':'];
        
        self.ltToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<" floatValue:0.0];
        self.gtToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@">" floatValue:0.0];
        
        self.startCommentToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<!--" floatValue:0.0];
        self.endCommentToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"-->" floatValue:0.0];
        [tokenizer.symbolState add:startCommentToken.stringValue];
        [tokenizer.symbolState add:endCommentToken.stringValue];

        self.startCDATAToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<![CDATA[" floatValue:0.0];
        self.endCDATAToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"]]>" floatValue:0.0];
        [tokenizer.symbolState add:startCDATAToken.stringValue];
        [tokenizer.symbolState add:endCDATAToken.stringValue];

        self.startPIToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<?" floatValue:0.0];
        self.endPIToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"?>" floatValue:0.0];
        [tokenizer.symbolState add:startPIToken.stringValue];
        [tokenizer.symbolState add:endPIToken.stringValue];

        self.startDoctypeToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<!DOCTYPE" floatValue:0.0];
        [tokenizer.symbolState add:startDoctypeToken.stringValue];
        
        self.fwdSlashToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0.0];
        self.eqToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"=" floatValue:0.0];

        self.scriptToken = [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"script" floatValue:0.0];

        self.endScriptToken = gtToken;
//        self.endScriptToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"</script>" floatValue:0.0];
//        [tokenizer.symbolState add:endScriptToken.stringValue];

        NSFont *monacoFont = [NSFont fontWithName:@"Monaco" size:11.];
        
        NSColor *textColor = nil;
        NSColor *tagColor = nil;
        NSColor *attrNameColor = nil;
        NSColor *attrValueColor = nil;
        NSColor *eqColor = nil;
        NSColor *commentColor = nil;
        NSColor *piColor = nil;
        
        if (isDarkBG) {
            textColor = [NSColor whiteColor];
            tagColor = [NSColor colorWithDeviceRed:.70 green:.14 blue:.53 alpha:1.];
            attrNameColor = [NSColor colorWithDeviceRed:.33 green:.45 blue:.48 alpha:1.];
            attrValueColor = [NSColor colorWithDeviceRed:.77 green:.18 blue:.20 alpha:1.];
            eqColor = tagColor;
            commentColor = [NSColor colorWithDeviceRed:.24 green:.70 blue:.27 alpha:1.];
            piColor = [NSColor colorWithDeviceRed:.09 green:.62 blue:.74 alpha:1.];
        } else {
            textColor = [NSColor blackColor];
            tagColor = [NSColor purpleColor];
            attrNameColor = [NSColor colorWithDeviceRed:0. green:0. blue:.75 alpha:1.];
            attrValueColor = [NSColor colorWithDeviceRed:.75 green:0. blue:0. alpha:1.];
            eqColor = [NSColor darkGrayColor];
            commentColor = [NSColor grayColor];
            piColor = [NSColor colorWithDeviceRed:.09 green:.62 blue:.74 alpha:1.];
        }
        
        self.textAttributes            = [NSDictionary dictionaryWithObjectsAndKeys:
                                       textColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.tagAttributes            = [NSDictionary dictionaryWithObjectsAndKeys:
                                       tagColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.attrNameAttributes        = [NSDictionary dictionaryWithObjectsAndKeys:
                                       attrNameColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.attrValueAttributes    = [NSDictionary dictionaryWithObjectsAndKeys:
                                       attrValueColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.eqAttributes            = [NSDictionary dictionaryWithObjectsAndKeys:
                                       eqColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.commentAttributes        = [NSDictionary dictionaryWithObjectsAndKeys:
                                       commentColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
        self.piAttributes            = [NSDictionary dictionaryWithObjectsAndKeys:
                                       piColor, NSForegroundColorAttributeName,
                                       monacoFont, NSFontAttributeName,
                                       nil];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.stack = nil;
    self.ltToken = nil;
    self.gtToken = nil;
    self.startCommentToken = nil;
    self.endCommentToken = nil;
    self.startCDATAToken = nil;
    self.endCDATAToken = nil;
    self.startPIToken = nil;
    self.endPIToken = nil;
    self.startDoctypeToken = nil;
    self.fwdSlashToken = nil;
    self.eqToken = nil;
    self.scriptToken = nil;
    self.endScriptToken = nil;
    self.highlightedString = nil;
    self.textAttributes = nil;
    self.tagAttributes = nil;
    self.attrNameAttributes = nil;
    self.attrValueAttributes = nil;
    self.eqAttributes = nil;
    self.commentAttributes = nil;
    self.piAttributes = nil;
    [super dealloc];
}


- (NSAttributedString *)attributedStringForString:(NSString *)s {
    self.stack = [NSMutableArray array];
    self.highlightedString = [[[NSMutableAttributedString alloc] init] autorelease];
    
    tokenizer.string = s;
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    BOOL inComment = NO;
    BOOL inCDATA = NO;
    BOOL inPI = NO;
    BOOL inDoctype = NO;
    
    while ((tok = [tokenizer nextToken]) != eof) {    
        
        if (!inComment && !inCDATA && !inPI && !inDoctype && !inScript && tok.isSymbol) {
            if ([startCommentToken isEqual:tok]) {
                [stack addObject:tok];
                inComment = YES;
            } else if ([startCDATAToken isEqual:tok]) {
                [stack addObject:tok];
                inCDATA = YES;
            } else if ([startPIToken isEqual:tok]) {
                [stack addObject:tok];
                inPI = YES;
            } else if ([startDoctypeToken isEqual:tok]) {
                [stack addObject:tok];
                inDoctype = YES;
            } else if ([ltToken isEqual:tok]) {
                [self didMatchText];
                [stack addObject:tok];
            } else if ([gtToken isEqual:tok]) {
                [stack addObject:tok];
                [self didMatchTag];
            } else {
                [stack addObject:tok];
            }
        } else if (inComment && [endCommentToken isEqual:tok]) {
            inComment = NO;
            [stack addObject:tok];
            [self didMatchComment];
        } else if (inCDATA && [endCDATAToken isEqual:tok]) {
            inCDATA = NO;
            [stack addObject:tok];
            [self didMatchCDATA];
        } else if (inPI && [endPIToken isEqual:tok]) {
            inPI = NO;
            [stack addObject:tok];
            [self didMatchPI];
        } else if (inDoctype && [gtToken isEqual:tok]) {
            inDoctype = NO;
            [stack addObject:tok];
            [self didMatchDoctype];
        } else if (inScript && [endScriptToken isEqual:tok]) {
            inScript = NO;
            [stack addObject:tok];
            [self didMatchScript];
        } else {
            [stack addObject:tok];
        }
    }
    
    // handle case where no elements were encountered (plain text basically)
    if (![highlightedString length]) {
        PKToken *tok = nil;
        while (tok = [self pop]) {
            NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:textAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    NSAttributedString *result = [[highlightedString copy] autorelease];
    self.stack = nil;
    self.highlightedString = nil;
    tokenizer.string = nil;
    return result;
}


- (PKToken *)nextNonWhitespaceTokenFrom:(NSEnumerator *)e {
    PKToken *tok = [e nextObject];
    while (tok.isWhitespace) {
        NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
        [highlightedString appendAttributedString:as];
        tok = [e nextObject];
    }
    return tok;
}


- (void)consumeWhitespaceOnStack {
    PKToken *tok = [self peek];
    while (tok.isWhitespace) {
        tok = [self pop];
        NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
        [highlightedString appendAttributedString:as];
        tok = [self peek];
    }
}


- (void)didMatchComment {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:startCommentToken] reversedMutableArray];
    
    [self consumeWhitespaceOnStack];
    
    NSAttributedString *as = [[[NSAttributedString alloc] initWithString:startCommentToken.stringValue attributes:commentAttributes] autorelease];
    [highlightedString appendAttributedString:as];
    
    NSEnumerator *e = [toks objectEnumerator];
    
    PKToken *tok = nil;
    while (tok = [self nextNonWhitespaceTokenFrom:e]) {
        if ([tok isEqual:endCommentToken]) {
            break;
        } else {
            as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:commentAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:commentAttributes] autorelease];
    [highlightedString appendAttributedString:as];
}


- (void)didMatchCDATA {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:startCDATAToken] reversedMutableArray];
    
    [self consumeWhitespaceOnStack];
    
    NSAttributedString *as = [[[NSAttributedString alloc] initWithString:startCDATAToken.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
    
    NSEnumerator *e = [toks objectEnumerator];
    
    PKToken *tok = nil;
    while (tok = [self nextNonWhitespaceTokenFrom:e]) {
        if ([tok isEqual:endCDATAToken]) {
            break;
        } else {
            as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:textAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
}


- (void)didMatchPI {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:startPIToken] reversedMutableArray];
    
    [self consumeWhitespaceOnStack];
    
    NSAttributedString *as = [[[NSAttributedString alloc] initWithString:startPIToken.stringValue attributes:piAttributes] autorelease];
    [highlightedString appendAttributedString:as];
    
    NSEnumerator *e = [toks objectEnumerator];
    
    PKToken *tok = nil;
    while (tok = [self nextNonWhitespaceTokenFrom:e]) {
        if ([tok isEqual:endPIToken]) {
            break;
        } else {
            as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:piAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:piAttributes] autorelease];
    [highlightedString appendAttributedString:as];
}


- (void)didMatchDoctype {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:startDoctypeToken] reversedMutableArray];
    
    [self consumeWhitespaceOnStack];
    
    NSAttributedString *as = [[[NSAttributedString alloc] initWithString:startDoctypeToken.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
    
    NSEnumerator *e = [toks objectEnumerator];
    
    PKToken *tok = nil;
    while (tok = [self nextNonWhitespaceTokenFrom:e]) {
        if ([tok isEqual:gtToken]) {
            break;
        } else {
            as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
}


- (void)didMatchScript {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:startDoctypeToken] reversedMutableArray];
    
    NSEnumerator *e = [toks objectEnumerator];
    NSAttributedString *as = nil;
    
    PKToken *tok = nil;
    while (tok = [self nextNonWhitespaceTokenFrom:e]) {
        if ([tok isEqual:endScriptToken]) {
            break;
        } else {
            NSDictionary *attrs = nil;
            if ([tok isEqual:scriptToken] || [tok isEqual:ltToken] || [tok isEqual:fwdSlashToken]) {
                attrs = tagAttributes;
            } else {
                attrs = textAttributes;
            }
            as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrs] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
    
    as = [[[NSAttributedString alloc] initWithString:endScriptToken.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
}


- (void)didMatchStartTag:(NSEnumerator *)e {
    while (1) {
        // attr name or ns prefix decl "xmlns:foo" or "/" for empty element
        PKToken *tok = [self nextNonWhitespaceTokenFrom:e];
        if (!tok) return;
        
        NSDictionary *attrs = nil;
        if ([tok isEqual:eqToken]) {
            attrs = eqAttributes;
        } else if ([tok isEqual:fwdSlashToken] || [tok isEqual:gtToken]) {
            attrs = tagAttributes;
        } else if (tok.isQuotedString) {
            attrs = attrValueAttributes;
        } else {
            attrs = attrNameAttributes;
        }
        
        NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrs] autorelease];
        [highlightedString appendAttributedString:as];
        
        // "="
        tok = [self nextNonWhitespaceTokenFrom:e];
        if (!tok) return;
        
        if ([tok isEqual:eqToken]) {
            attrs = eqAttributes;
        } else if ([tok isEqual:fwdSlashToken] || [tok isEqual:gtToken]) {
            attrs = tagAttributes;
        } else if (tok.isQuotedString) {
            attrs = attrValueAttributes;
        } else {
            attrs = tagAttributes;
        }
        
        as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrs] autorelease];
        [highlightedString appendAttributedString:as];
        
        // quoted string attr value or ns url value
        tok = [self nextNonWhitespaceTokenFrom:e];
        if (!tok) return;
        
        if ([tok isEqual:fwdSlashToken] || [tok isEqual:gtToken]) {
            attrs = tagAttributes;
        } else {
            attrs = attrValueAttributes;
        }

        as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrs] autorelease];
        [highlightedString appendAttributedString:as];
    }
}


- (void)didMatchEndTag:(NSEnumerator *)e {
    // consume tagName to ">"
    PKToken *tok = nil; 
    while (tok = [e nextObject]) {
        NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
        [highlightedString appendAttributedString:as];
    }
}


- (void)didMatchTag {
    // reverse toks to be in document order
    NSMutableArray *toks = [[self objectsAbove:nil] reversedMutableArray];
    NSAttributedString *as =  nil;
    
    NSEnumerator *e = [toks objectEnumerator];

    // append "<"
    [self nextNonWhitespaceTokenFrom:e]; // discard
    as = [[[NSAttributedString alloc] initWithString:ltToken.stringValue attributes:tagAttributes] autorelease];
    [highlightedString appendAttributedString:as];
    
    // consume whitespace to tagName or "/" for end tags or "!" for comments
    PKToken *tok = [self nextNonWhitespaceTokenFrom:e];

    if (tok) {
        if ([tok isEqual:scriptToken]) {
            inScript = YES;
        } else {
            inScript = NO;
        }
        
        // consume tagName or "/" or "!"
        as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes] autorelease];
        [highlightedString appendAttributedString:as];
        
        if ([tok isEqual:fwdSlashToken]) {
            [self didMatchEndTag:e];
        } else {
            [self didMatchStartTag:e];
        }
    }
}


- (void)didMatchText {
    NSArray *a = [self objectsAbove:gtToken];
    for (PKToken *tok in [a reverseObjectEnumerator]) {
        NSString *s = tok.stringValue;
        if (s) {
            NSAttributedString *as = [[[NSAttributedString alloc] initWithString:tok.stringValue attributes:textAttributes] autorelease];
            [highlightedString appendAttributedString:as];
        }
    }
}


- (NSArray *)objectsAbove:(id)fence {
    NSMutableArray *res = [NSMutableArray array];
    while (1) {
        if (![stack count]) {
            break;
        }
        id obj = [self pop];
        if ([obj isEqual:fence]) {
            break;
        }
        [res addObject:obj];
    }
    return res;
}


- (id)peek {
    id obj = nil;
    if ([stack count]) {
        obj = [stack lastObject];
    }
    return obj;
}


- (id)pop {
    id obj = [self peek];
    if (obj) {
        [stack removeLastObject];
    }
    return obj;
}

@synthesize stack;
@synthesize tokenizer;
@synthesize ltToken;
@synthesize gtToken;
@synthesize startCommentToken;
@synthesize endCommentToken;
@synthesize startCDATAToken;
@synthesize endCDATAToken;
@synthesize startPIToken;
@synthesize endPIToken;
@synthesize startDoctypeToken;
@synthesize fwdSlashToken;
@synthesize eqToken;
@synthesize scriptToken;
@synthesize endScriptToken;
@synthesize highlightedString;
@synthesize tagAttributes;
@synthesize textAttributes;
@synthesize attrNameAttributes;
@synthesize attrValueAttributes;
@synthesize eqAttributes;
@synthesize commentAttributes;
@synthesize piAttributes;
@end
