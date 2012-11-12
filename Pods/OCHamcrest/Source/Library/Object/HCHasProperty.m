//
//  OCHamcrest - HCHasProperty.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Justin Shacklette
//

#import "HCHasProperty.h"

#import "HCDescription.h"
#import "HCRequireNonNilObject.h"
#import "HCWrapInMatcher.h"

@interface HCHasProperty ()
- (id)objectFromInvokingSelector:(SEL)selector onObject:(id)item;
@end


@implementation HCHasProperty

+ (id)hasProperty:(NSString *)property value:(id<HCMatcher>)aValueMatcher
{
    return [[[self alloc] initWithProperty:property value:aValueMatcher] autorelease];
}

- (id)initWithProperty:(NSString *)property value:(id<HCMatcher>)aValueMatcher
{
    HCRequireNonNilObject(property);
    
    self = [super init];
    if (self != nil)
    {
        propertyName = [property copy];
        valueMatcher = [aValueMatcher retain];
    }
    return self;
}

- (void)dealloc
{
    [propertyName release];
    [valueMatcher release];
    [super dealloc];
}

- (BOOL)matches:(id)item
{
    SEL propertyGetter = NSSelectorFromString(propertyName);
    if (![item respondsToSelector:propertyGetter])
        return NO;

    id propertyValue = [self objectFromInvokingSelector:propertyGetter onObject:item];
    return [valueMatcher matches:propertyValue];
}

- (id)objectFromInvokingSelector:(SEL)selector onObject:(id)object
{
    NSMethodSignature *getterSignature = [object methodSignatureForSelector:selector];
    NSInvocation *getterInvocation = [NSInvocation invocationWithMethodSignature:getterSignature];
    [getterInvocation setTarget:object];
    [getterInvocation setSelector:selector];
    [getterInvocation invoke];
    
    char charValue;
    int intValue;
    short shortValue;
    long longValue;
    long long longLongValue;
    unsigned char unsignedCharValue;
    unsigned int unsignedIntValue;
    unsigned short unsignedShortValue;
    unsigned long unsignedLongValue;
    unsigned long long unsignedLongLongValue;
    float floatValue;
    double doubleValue;

    id result = nil;
    const char *argType = [getterSignature methodReturnType];
    switch (argType[0])
    {
        case 'c':
            [getterInvocation getReturnValue:&charValue];
            result = [NSNumber numberWithChar:charValue];
            break;
            
        case 'i':
            [getterInvocation getReturnValue:&intValue];
            result = [NSNumber numberWithInt:intValue];
            break;
            
        case 's':
            [getterInvocation getReturnValue:&shortValue];
            result = [NSNumber numberWithShort:shortValue];
            break;
            
        case 'l':
            [getterInvocation getReturnValue:&longValue];
            result = [NSNumber numberWithLong:longValue];
            break;
            
        case 'q':
            [getterInvocation getReturnValue:&longLongValue];
            result = [NSNumber numberWithLong:longLongValue];
            break;
            
        case 'C':
            [getterInvocation getReturnValue:&unsignedCharValue];
            result = [NSNumber numberWithUnsignedChar:unsignedCharValue];
            break;
            
        case 'I':
            [getterInvocation getReturnValue:&unsignedIntValue];
            result = [NSNumber numberWithUnsignedInt:unsignedIntValue];
            break;
            
        case 'S':
            [getterInvocation getReturnValue:&unsignedShortValue];
            result = [NSNumber numberWithUnsignedShort:unsignedShortValue];
            break;
            
        case 'L':
            [getterInvocation getReturnValue:&unsignedLongValue];
            result = [NSNumber numberWithUnsignedLong:unsignedLongValue];
            break;
            
        case 'Q':
            [getterInvocation getReturnValue:&unsignedLongLongValue];
            result = [NSNumber numberWithUnsignedLongLong:unsignedLongLongValue];
            break;
            
        case 'f':
            [getterInvocation getReturnValue:&floatValue];
            result = [NSNumber numberWithFloat:floatValue];
            break;
            
        case 'd':
            [getterInvocation getReturnValue:&doubleValue];
            result = [NSNumber numberWithDouble:doubleValue];
            break;
            
        case '@':
            [getterInvocation getReturnValue:&result];
            break;
    }
    
    return result;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[[[description appendText:@"an object with "]
                    appendText:propertyName]
                    appendText:@" "]
                    appendDescriptionOf:valueMatcher];
}
@end


#pragma mark -

id<HCMatcher> HC_hasProperty(NSString *name, id valueMatch)
{
    return [HCHasProperty hasProperty:name value:HCWrapInMatcher(valueMatch)];
}
