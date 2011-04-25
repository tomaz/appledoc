//
//  PKCharacterAssembly.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKCharacterAssembly.h>
#import <ParseKit/PKTypes.h>

@interface PKAssembly ()
@property (nonatomic, readwrite, retain) NSString *defaultDelimiter;
@end

@implementation PKCharacterAssembly

- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    self = [super initWithString:s];
    if (self) {
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
