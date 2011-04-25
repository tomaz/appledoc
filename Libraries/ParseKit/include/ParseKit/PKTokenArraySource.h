//
//  PKTokenArraySource.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/11/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKTokenizer;
@class PKToken;

/*!
    @class      PKTokenArraySource
    @brief      A <tt>TokenArraySource</tt> is a handy utility that enumerates over a specified reader, returning <tt>NSArray</tt>s of <tt>PKToken</tt>s delimited by a specified delimiter.
    @details    For example,
 
@code
    NSString *s = @"I came; I saw; I left in peace;";

    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    PKTokenArraySource *src = [[[PKTokenArraySource alloc] initWithTokenizer:t delimiter:@";"] autorelease];
 
    while ([src hasMore]) {
        NSLog(@"%@", [src nextTokenArray]);
    }
@endcode
 
 prints out:

@code
    I came
    I saw
    I left in peace
@endcode
*/
@interface PKTokenArraySource : NSObject {
    PKTokenizer *tokenizer;
    NSString *delimiter;
    PKToken *nextToken;
}

/*!
    @brief      Constructs a <tt>PKTokenArraySource</tt> that will read an <tt>NSArray</tt>s of <tt>PKToken</tt>s using the specified tokenizer, delimited by the specified delimiter.
    @param      tokenizer a tokenizer to read tokens from
    @param      delimiter the character(s) that fences off where one array of tokens ends and the next begins
*/
- (id)initWithTokenizer:(PKTokenizer *)t delimiter:(NSString *)s;

/*!
    @brief      true if the source has more arrays of tokens.
    @result     true, if the source has more arrays of tokens that have not yet been popped with <tt>-nextTokenArray</tt>
*/
- (BOOL)hasMore;

/*!
    @brief      Returns the next array of tokens from the source.
    @result     the next array of tokens from the source
*/
- (NSArray *)nextTokenArray;
@end
