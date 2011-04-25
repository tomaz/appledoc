//
//  PKXmlNameState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlNameState.h"
#import "PKTokenizer.h"
#import "PKReader.h"
#import "TDXmlToken.h"

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface TDXmlNameState ()
+ (BOOL)isNameChar:(PKUniChar)c;
+ (BOOL)isValidStartSymbolChar:(PKUniChar)c;
+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c;
@end

//Name       ::=       (Letter | '_' | ':') (NameChar)*
@implementation TDXmlNameState

//- (BOOL)isWhitespace:(PKUniChar)c {
//    return (' ' == c || '\n' == c || '\r' == c || '\t' == c);
//}


//    NameChar       ::=        Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
+ (BOOL)isNameChar:(PKUniChar)c {
    if (isalpha(c)) {
        return YES;
    } else if (isdigit(c)) {
        return YES;
    } else if ([[self class] isValidNonStartSymbolChar:c]) {
        return YES;
    }
    // TODO CombiningChar & Extender
    return NO;
}


+ (BOOL)isValidStartSymbolChar:(PKUniChar)c {
    return ('_' == c || ':' == c);
}


+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c {
    return ('_' == c || '.' == c || '-' == c || ':' == c);
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    [self resetWithReader:r];
    
    NSInteger c = cin;
    do {
        [self append:c];
        c = [r read];
    } while ([[self class] isNameChar:c]);
    
    if (PKEOF != c) {
        [r unread];
    }

    if ([[self bufferedString] length] == 1 && [[self class] isValidStartSymbolChar:cin]) {
        return [t.symbolState nextTokenFromReader:r startingWith:cin tokenizer:t];
    } else {
//        return [[[TDXmlToken alloc] initWithTokenType:TDTT_NAME 
//                                           stringValue:[[stringbuf copy] autorelease] 
//                                            floatValue:0.0] autorelease];
        return nil;
    }
}

@end
