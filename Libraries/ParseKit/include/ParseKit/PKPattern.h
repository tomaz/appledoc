//
//  PKPattern.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>
#import <ParseKit/PKToken.h>

typedef enum {
    PKPatternOptionsNone                    = 0,
    PKPatternOptionsIgnoreCase              = 2,
    PKPatternOptionsComments                = 4,
    PKPatternOptionsMultiline               = 8,
    PKPatternOptionsDotAll                  = 32,
    PKPatternOptionsUnicodeWordBoundaries   = 256
} PKPatternOptions;

@interface PKPattern : PKTerminal {
    PKPatternOptions options;
}
+ (id)patternWithString:(NSString *)s;

+ (id)patternWithString:(NSString *)s options:(PKPatternOptions)opts;

- (id)initWithString:(NSString *)s;

- (id)initWithString:(NSString *)s options:(PKPatternOptions)opts;
@end
