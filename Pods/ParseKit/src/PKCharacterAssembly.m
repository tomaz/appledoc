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

#import <ParseKit/PKCharacterAssembly.h>
#import <ParseKit/PKTypes.h>

@interface PKAssembly ()
@property (nonatomic, readwrite, retain) NSString *defaultDelimiter;
@end

@implementation PKCharacterAssembly

+ (PKCharacterAssembly *)assemblyWithString:(NSString *)s {
    return (PKCharacterAssembly *)[super assemblyWithString:s];
}


- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    if (self = [super initWithString:s]) {
        self.defaultDelimiter = @"";
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKCharacterAssembly *a = (PKCharacterAssembly *)[super copyWithZone:zone];
    return a;
}


- (id)peek {
    if (index >= [string length]) {
        return nil;
    }
    PKUniChar c = [string characterAtIndex:index];
    return [NSNumber numberWithInt:c];
}


- (id)next {
    id obj = [self peek];
    if (obj) {
        index++;
    }
    return obj;
}


- (BOOL)hasMore {
    return (index < [string length]);
}


- (NSUInteger)length {
    return [string length];
} 


- (NSUInteger)objectsConsumed {
    return index;
}


- (NSUInteger)objectsRemaining {
    return ([string length] - index);
}


- (NSString *)consumedObjectsJoinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    return [string substringToIndex:self.objectsConsumed];
}


- (NSString *)remainingObjectsJoinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    return [string substringFromIndex:self.objectsConsumed];
}


// overriding simply to print NSNumber objects as their unichar values
- (NSString *)description {
    NSMutableString *s = [NSMutableString string];
    [s appendString:@"["];
    
    NSUInteger i = 0;
    NSUInteger len = [stack count];
    
    for (id obj in self.stack) {
        if ([obj isKindOfClass:[NSNumber class]]) { // ***this is needed for Char Assemblies
            [s appendFormat:@"%C", [obj integerValue]];
        } else {
            [s appendString:[obj description]];
        }
        if (len - 1 != i++) {
            [s appendString:@", "];
        }
    }
    
    [s appendString:@"]"];
    
    [s appendString:[self consumedObjectsJoinedByString:self.defaultDelimiter]];
    [s appendString:@"^"];
    [s appendString:[self remainingObjectsJoinedByString:self.defaultDelimiter]];
    
    return [[s copy] autorelease];
}

@end
