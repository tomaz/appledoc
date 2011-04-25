//
//  PKToken.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>

@interface PKTokenEOF : PKToken {}
+ (PKTokenEOF *)instance;
@end

@implementation PKTokenEOF

static PKTokenEOF *EOFToken = nil;

+ (PKTokenEOF *)instance {
    @synchronized(self) {
        if (!EOFToken) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return EOFToken;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (!EOFToken) {
            EOFToken = [super allocWithZone:zone];
            return EOFToken;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)retain {
    return self;
}


- (void)release {
    // do nothing
}


- (id)autorelease {
    return self;
}


- (NSUInteger)retainCount {
    return UINT_MAX; // denotes an object that cannot be released
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKTokenEOF %p>", self];
}


- (NSString *)debugDescription {
    return [self description];
}


- (NSUInteger)offset {
    return -1;
}

@end

@interface PKToken ()
- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase;

@property (nonatomic, readwrite, getter=isNumber) BOOL number;
@property (nonatomic, readwrite, getter=isQuotedString) BOOL quotedString;
@property (nonatomic, readwrite, getter=isSymbol) BOOL symbol;
@property (nonatomic, readwrite, getter=isWord) BOOL word;
@property (nonatomic, readwrite, getter=isWhitespace) BOOL whitespace;
@property (nonatomic, readwrite, getter=isComment) BOOL comment;
@property (nonatomic, readwrite, getter=isDelimitedString) BOOL delimitedString;

@property (nonatomic, readwrite) CGFloat floatValue;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) PKTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;

@property (nonatomic, readwrite) NSUInteger offset;
@end

@implementation PKToken

+ (PKToken *)EOFToken {
    return [PKTokenEOF instance];
}


+ (id)tokenWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n {
    return [[[self alloc] initWithTokenType:t stringValue:s floatValue:n] autorelease];
}


// designated initializer
- (id)initWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n {
    //NSParameterAssert(s);
    if (self = [super init]) {
        self.tokenType = t;
        self.stringValue = s;
        self.floatValue = n;
        
        self.number = (PKTokenTypeNumber == t);
        self.quotedString = (PKTokenTypeQuotedString == t);
        self.symbol = (PKTokenTypeSymbol == t);
        self.word = (PKTokenTypeWord == t);
        self.whitespace = (PKTokenTypeWhitespace == t);
        self.comment = (PKTokenTypeComment == t);
        self.delimitedString = (PKTokenTypeDelimitedString == t);
    }
    return self;
}


- (void)dealloc {
    self.stringValue = nil;
    self.value = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    return [self retain]; // tokens are immutable
}


- (NSUInteger)hash {
    return [stringValue hash];
}


- (BOOL)isEqual:(id)obj {
    return [self isEqual:obj ignoringCase:NO];
}


- (BOOL)isEqualIgnoringCase:(id)obj {
    return [self isEqual:obj ignoringCase:YES];
}


- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase {
    if (![obj isMemberOfClass:[PKToken class]]) {
        return NO;
    }
    
    PKToken *tok = (PKToken *)obj;
    if (tokenType != tok.tokenType) {
        return NO;
    }
    
    if (self.isNumber) {
        return floatValue == tok.floatValue;
    } else {
        if (ignoringCase) {
            return (NSOrderedSame == [stringValue caseInsensitiveCompare:tok.stringValue]);
        } else {
            return [stringValue isEqualToString:tok.stringValue];
        }
    }
}


- (id)value {
    if (!value) {
        id v = nil;
        if (self.isNumber) {
            v = [NSNumber numberWithFloat:floatValue];
        } else {
            v = stringValue;
        }
        self.value = v;
    }
    return value;
}


- (NSString *)debugDescription {
    NSString *typeString = nil;
    if (self.isNumber) {
        typeString = @"Number";
    } else if (self.isQuotedString) {
        typeString = @"Quoted String";
    } else if (self.isSymbol) {
        typeString = @"Symbol";
    } else if (self.isWord) {
        typeString = @"Word";
    } else if (self.isWhitespace) {
        typeString = @"Whitespace";
    } else if (self.isComment) {
        typeString = @"Comment";
    } else if (self.isDelimitedString) {
        typeString = @"Delimited String";
    }
    return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, 0x00AB, self.value, 0x00BB];
}


- (NSString *)description {
    return stringValue;
}

@synthesize number;
@synthesize quotedString;
@synthesize symbol;
@synthesize word;
@synthesize whitespace;
@synthesize comment;
@synthesize delimitedString;
@synthesize floatValue;
@synthesize stringValue;
@synthesize tokenType;
@synthesize value;
@synthesize offset;
@end
