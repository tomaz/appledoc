//
//  PKXmlNmtokenState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlNmtokenState.h"
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
@end

// NameChar       ::=        Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
@implementation TDXmlNmtokenState

+ (BOOL)isValidStartSymbolChar:(PKUniChar)c {
    return ('_' == c || ':' == c || '-' == c || '.' == c);
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
    
    NSString *s = [self bufferedString];
    if ([s length] == 1 && [[self class] isValidStartSymbolChar:cin]) {
        return [t.symbolState nextTokenFromReader:r startingWith:cin tokenizer:t];
    } else if ([s length] == 1 && isdigit(cin)) {
        return [t.numberState nextTokenFromReader:r startingWith:cin tokenizer:t];
    } else {
        return nil;
//        return [[[TDXmlToken alloc] initWithTokenType:TDTT_NMTOKEN
//                                           stringValue:[[stringbuf copy] autorelease] 
//                                            floatValue:0.0] autorelease];
    }
}

@end
