//
//  PKSymbol.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKSymbol.h>
#import <ParseKit/PKToken.h>

@interface PKSymbol ()
@property (nonatomic, retain) PKToken *symbol;
@end

@implementation PKSymbol

+ (id)symbol {
    return [[[self alloc] initWithString:nil] autorelease];
}


+ (id)symbolWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)initWithString:(NSString *)s {
    self = [super initWithString:s];
    if (self) {
        if ([s length]) {
            self.symbol = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:s floatValue:0.0];
        }
    }
    return self;
}


- (void)dealloc {
    self.symbol = nil;
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    if (symbol) {
        return [symbol isEqual:obj];
    } else {
        PKToken *tok = (PKToken *)obj;
        return tok.isSymbol;
    }
}


- (NSString *)description {
    NSString *className = [NSStringFromClass([self class]) substringFromIndex:2];
    if ([name length]) {
        if (symbol) {
            return [NSString stringWithFormat:@"%@ (%@) %@", className, name, symbol.stringValue];
        } else {
            return [NSString stringWithFormat:@"%@ (%@)", className, name];
        }
    } else {
        if (symbol) {
            return [NSString stringWithFormat:@"%@ %@", className, symbol.stringValue];
        } else {
            return [NSString stringWithFormat:@"%@", className];
        }
    }
}

@synthesize symbol;
@end
