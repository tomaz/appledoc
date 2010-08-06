//
//  OCHamcrest - HCNumberAssert.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

#import <Foundation/Foundation.h>

@protocol HCMatcher;


#ifdef __cplusplus
extern "C" {
#endif

void HC_assertThatBoolWithLocation(id testCase, BOOL actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatCharWithLocation(id testCase, char actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatDoubleWithLocation(id testCase, double actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatFloatWithLocation(id testCase, float actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatIntWithLocation(id testCase, int actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatLongWithLocation(id testCase, long actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatLongLongWithLocation(id testCase, long long actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatShortWithLocation(id testCase, short actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedCharWithLocation(id testCase, unsigned char actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedIntWithLocation(id testCase, unsigned int actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedLongWithLocation(id testCase, unsigned long actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedLongLongWithLocation(id testCase, unsigned long long actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedShortWithLocation(id testCase, unsigned short actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

#if defined(OBJC_API_VERSION) && OBJC_API_VERSION >= 2

void HC_assertThatIntegerWithLocation(id testCase, NSInteger actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

void HC_assertThatUnsignedIntegerWithLocation(id testCase, NSUInteger actual,
        id<HCMatcher> matcher, const char* fileName, int lineNumber);

#endif  // Objective-C 2.0

#ifdef __cplusplus
}
#endif

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatBool(actual, matcher)  \
    HC_assertThatBoolWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatChar(actual, matcher)  \
    HC_assertThatCharWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatDouble(actual, matcher)  \
    HC_assertThatDoubleWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatFloat(actual, matcher)  \
    HC_assertThatFloatWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatInt(actual, matcher)  \
    HC_assertThatIntWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatLong(actual, matcher)  \
    HC_assertThatLongWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatLongLong(actual, matcher)  \
    HC_assertThatLongLongWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatShort(actual, matcher)  \
    HC_assertThatShortWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedChar(actual, matcher)  \
    HC_assertThatUnsignedCharWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedInt(actual, matcher)  \
    HC_assertThatUnsignedIntWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedLong(actual, matcher)  \
    HC_assertThatUnsignedLongWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedLongLong(actual, matcher)  \
    HC_assertThatUnsignedLongLongWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedShort(actual, matcher)  \
    HC_assertThatUnsignedShortWithLocation(self, actual, matcher, __FILE__, __LINE__)


#if defined(OBJC_API_VERSION) && OBJC_API_VERSION >= 2

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatInteger(actual, matcher)  \
    HC_assertThatIntegerWithLocation(self, actual, matcher, __FILE__, __LINE__)

/**
    OCUnit integration asserting that actual value, when converted to an NSNumber satisfies matcher.
*/
#define HC_assertThatUnsignedInteger(actual, matcher)  \
    HC_assertThatUnsignedIntegerWithLocation(self, actual, matcher, __FILE__, __LINE__)

#endif  // Objective-C 2.0


#ifdef HC_SHORTHAND

/**
    Shorthand for HC_assertThatBool, available if HC_SHORTHAND is defined.
*/
#define assertThatBool HC_assertThatBool

/**
    Shorthand for HC_assertThatChar, available if HC_SHORTHAND is defined.
*/
#define assertThatChar HC_assertThatChar

/**
    Shorthand for HC_assertThatDouble, available if HC_SHORTHAND is defined.
*/
#define assertThatDouble HC_assertThatDouble

/**
    Shorthand for HC_assertThatFloat, available if HC_SHORTHAND is defined.
*/
#define assertThatFloat HC_assertThatFloat

/**
    Shorthand for HC_assertThatInt, available if HC_SHORTHAND is defined.
*/
#define assertThatInt HC_assertThatInt

/**
    Shorthand for HC_assertThatLong, available if HC_SHORTHAND is defined.
*/
#define assertThatLong HC_assertThatLong

/**
    Shorthand for HC_assertThatLongLong, available if HC_SHORTHAND is defined.
*/
#define assertThatLongLong HC_assertThatLongLong

/**
    Shorthand for HC_assertThatShort, available if HC_SHORTHAND is defined.
*/
#define assertThatShort HC_assertThatShort

/**
    Shorthand for HC_assertThatUnsignedChar, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedChar HC_assertThatUnsignedChar

/**
    Shorthand for HC_assertThatUnsignedInt, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedInt HC_assertThatUnsignedInt

/**
    Shorthand for HC_assertThatUnsignedLong, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedLong HC_assertThatUnsignedLong

/**
    Shorthand for HC_assertThatUnsignedLongLong, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedLongLong HC_assertThatUnsignedLongLong

/**
    Shorthand for HC_assertThatInt, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedShort HC_assertThatUnsignedShort


#if defined(OBJC_API_VERSION) && OBJC_API_VERSION >= 2

/**
    Shorthand for HC_assertThatInt, available if HC_SHORTHAND is defined.
*/
#define assertThatInteger HC_assertThatInteger

/**
    Shorthand for HC_assertThatInt, available if HC_SHORTHAND is defined.
*/
#define assertThatUnsignedInteger HC_assertThatUnsignedInteger

#endif  // Objective-C 2.0

#endif  // HC_SHORTHAND
