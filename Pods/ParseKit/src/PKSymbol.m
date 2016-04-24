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

#import <ParseKit/PKSymbol.h>
#import <ParseKit/PKToken.h>

@interface PKSymbol ()
@property (nonatomic, retain) PKToken *symbol;
@end

@implementation PKSymbol

+ (PKSymbol *)symbol {
    return [[[self alloc] initWithString:nil] autorelease];
}


+ (PKSymbol *)symbolWithString:(NSString *)s {
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
