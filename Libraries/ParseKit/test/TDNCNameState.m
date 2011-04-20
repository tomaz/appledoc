//
//  PKNCNameState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDNCNameState.h"
#import "PKTokenizer.h"
#import "PKReader.h"
#import "TDXmlToken.h"

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface TDNCNameState ()
+ (BOOL)isNameChar:(PKUniChar)c;
+ (BOOL)isValidStartSymbolChar:(PKUniChar)c;
+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c;
@end

// NCName       ::=       (Letter | '_') (NameChar)*
@implementation TDNCNameState

//- (BOOL)isWhitespace:(PKUniChar)c {
//    return (' ' == c || '\n' == c || '\r' == c || '\t' == c);
//}


//    NameChar       ::=        Letter | Digit | '.' | '-' | '_' | CombiningChar | Extender
+ (BOOL)isNameChar:(PKUniChar)c {
    if (isalnum(c)) {
        return YES;
    } else if ([self isValidNonStartSymbolChar:c]) {
        return YES;
    }
    // TODO CombiningChar & Extender
    return NO;
}


+ (BOOL)isValidStartSymbolChar:(PKUniChar)c {
    return ('_' == c);
}


+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c {
    return ('_' == c || '.' == c || '-' == c);
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    [self resetWithReader:r];
    
    NSInteger c = cin;
    do {
        [self append:c];
        c = [r read];
    } while ([TDNCNameState isNameChar:c]);
    
    if (PKEOF != c) {
        [r unread];
    }
    
    if ([[self bufferedString] length] == 1 && [TDNCNameState isValidStartSymbolChar:cin]) {
        return [t.symbolState nextTokenFromReader:r startingWith:cin tokenizer:t];
    } else {
//        return [[[TDXmlToken alloc] initWithTokenType:TDTT_NAME 
//                                           stringValue:[[stringbuf copy] autorelease] 
//                                            floatValue:0.0] autorelease];
        return nil;
    }
}

@end
