//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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

+ (PKPattern *)patternWithString:(NSString *)s;

+ (PKPattern *)patternWithString:(NSString *)s options:(PKPatternOptions)opts;

- (id)initWithString:(NSString *)s;

- (id)initWithString:(NSString *)s options:(PKPatternOptions)opts;
@end
