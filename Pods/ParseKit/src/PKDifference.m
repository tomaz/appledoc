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

#import "PKDifference.h"

@interface NSMutableSet (PKDifferenceAdditions)
- (void)minusSetTestingEquality:(NSSet *)s;
@end

@implementation NSMutableSet (PKDifferenceAdditions)

- (void)minusSetTestingEquality:(NSSet *)s {
    for (id a1 in [[self copy] autorelease]) {
        for (id a2 in s) {
            if ([a1 isEqual:a2]) {
                [self removeObject:a1];
            }
        }
    }
}

@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@interface PKDifference ()
@property (nonatomic, retain, readwrite) PKParser *subparser;
@property (nonatomic, retain, readwrite) PKParser *minus;
@end

@implementation PKDifference

+ (PKDifference *)differenceWithSubparser:(PKParser *)s minus:(PKParser *)m {
    return [[[self alloc] initWithSubparser:s minus:m] autorelease];
}


- (id)initWithSubparser:(PKParser *)s minus:(PKParser *)m {
    if (self = [super init]) {
        self.subparser = s;
        self.minus = m;
    }
    return self;
}


- (void)dealloc {
    self.subparser = nil;
    self.minus = nil;
    [super dealloc];
}


- (PKParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    } else {
        // do bredth-first search
        if ([subparser.name isEqualToString:s]) {
            return subparser;
        }
        if ([minus.name isEqualToString:s]) {
            return minus;
        }
        
        PKParser *sub = [subparser parserNamed:s];
        if (sub) {
            return sub;
        }
        sub = [minus parserNamed:s];
        if (sub) {
            return sub;
        }
    }
    return nil;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);

    NSMutableSet *outAssemblies = [[[subparser matchAndAssemble:inAssemblies] mutableCopy] autorelease];
    [outAssemblies minusSetTestingEquality:[minus allMatchesFor:inAssemblies]];
    
    return outAssemblies;
}

@synthesize subparser;
@synthesize minus;
@end
