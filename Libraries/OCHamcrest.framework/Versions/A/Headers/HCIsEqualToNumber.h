//
//  OCHamcrest - HCIsEqualToNumber.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


#ifdef __cplusplus
extern "C" {
#endif

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToBool(BOOL value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToChar(char value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToDouble(double value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToFloat(float value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToInt(int value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToLong(long value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToLongLong(long long value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToShort(short value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedChar(unsigned char value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedInt(unsigned int value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedLong(unsigned long value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedLongLong(unsigned long long value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedShort(unsigned short value);


#if defined(OBJC_API_VERSION) && OBJC_API_VERSION >= 2

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToInteger(NSInteger value);

/**
    Is the value, when converted to an NSNumber, equal to another object?
*/
id<HCMatcher> HC_equalToUnsignedInteger(NSUInteger value);

#endif  // Objective-C 2.0


#ifdef __cplusplus
}
#endif


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_equalToBool, available if HC_SHORTHAND is defined.
*/
#define equalToBool HC_equalToBool

/**
    Shorthand for HC_equalToChar, available if HC_SHORTHAND is defined.
*/
#define equalToChar HC_equalToChar

/**
    Shorthand for HC_equalToDouble, available if HC_SHORTHAND is defined.
*/
#define equalToDouble HC_equalToDouble

/**
    Shorthand for HC_equalToFloat, available if HC_SHORTHAND is defined.
*/
#define equalToFloat HC_equalToFloat

/**
    Shorthand for HC_equalToInt, available if HC_SHORTHAND is defined.
*/
#define equalToInt HC_equalToInt

/**
    Shorthand for HC_equalToLong, available if HC_SHORTHAND is defined.
*/
#define equalToLong HC_equalToLong

/**
    Shorthand for HC_equalToLongLong, available if HC_SHORTHAND is defined.
*/
#define equalToLongLong HC_equalToLongLong

/**
    Shorthand for HC_equalToShort, available if HC_SHORTHAND is defined.
*/
#define equalToShort HC_equalToShort

/**
    Shorthand for HC_equalToUnsignedChar, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedChar HC_equalToUnsignedChar

/**
    Shorthand for HC_equalToUnsignedInt, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedInt HC_equalToUnsignedInt

/**
    Shorthand for HC_equalToUnsignedLong, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedLong HC_equalToUnsignedLong

/**
    Shorthand for HC_equalToUnsignedLongLong, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedLongLong HC_equalToUnsignedLongLong

/**
    Shorthand for HC_equalToUnsignedShort, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedShort HC_equalToUnsignedShort


#if defined(OBJC_API_VERSION) && OBJC_API_VERSION >= 2

/**
    Shorthand for HC_equalToInteger, available if HC_SHORTHAND is defined.
*/
#define equalToInteger HC_equalToInteger

/**
    Shorthand for HC_equalToUnsignedInteger, available if HC_SHORTHAND is defined.
*/
#define equalToUnsignedInteger HC_equalToUnsignedInteger

#endif  // Objective-C 2.0


#endif  // HC_SHORTHAND
