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

#import <ParseKit/PKLiteral.h>
#import <ParseKit/PKToken.h>

@interface PKLiteral ()
@property (nonatomic, retain) PKToken *literal;
@end

@implementation PKLiteral

+ (PKLiteral *)literalWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)initWithString:(NSString *)s {
    //NSParameterAssert(s);
    self = [super initWithString:s];
    if (self) {
        self.literal = [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:s floatValue:0.0];
    }
    return self;
}


- (void)dealloc {
    self.literal = nil;
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    return [literal.stringValue isEqualToString:[obj stringValue]];
    //return [literal isEqual:obj];
}


- (NSString *)description {
    NSString *className = [NSStringFromClass([self class]) substringFromIndex:2];
    if ([name length]) {
        return [NSString stringWithFormat:@"%@ (%@) %@", className, name, literal.stringValue];
    } else {
        return [NSString stringWithFormat:@"%@ %@", className, literal.stringValue];
    }
}

@synthesize literal;
@end
