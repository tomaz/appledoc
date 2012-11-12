//
//  OCHamcrest - HCIsEqualToNumber.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsEqualToNumber.h"

#import "HCIsEqual.h"


#define DEFINE_EQUAL_TO_NUMBER(name, type)                                  \
    OBJC_EXPORT id<HCMatcher> HC_equalTo ## name(type value)                \
    {                                                                       \
        return [HCIsEqual isEqualTo:[NSNumber numberWith ## name :value]];  \
    }

DEFINE_EQUAL_TO_NUMBER(Bool, BOOL)
DEFINE_EQUAL_TO_NUMBER(Char, char)
DEFINE_EQUAL_TO_NUMBER(Double, double)
DEFINE_EQUAL_TO_NUMBER(Float, float)
DEFINE_EQUAL_TO_NUMBER(Int, int)
DEFINE_EQUAL_TO_NUMBER(Long, long)
DEFINE_EQUAL_TO_NUMBER(LongLong, long long)
DEFINE_EQUAL_TO_NUMBER(Short, short)
DEFINE_EQUAL_TO_NUMBER(UnsignedChar, unsigned char)
DEFINE_EQUAL_TO_NUMBER(UnsignedInt, unsigned int)
DEFINE_EQUAL_TO_NUMBER(UnsignedLong, unsigned long)
DEFINE_EQUAL_TO_NUMBER(UnsignedLongLong, unsigned long long)
DEFINE_EQUAL_TO_NUMBER(UnsignedShort, unsigned short)
DEFINE_EQUAL_TO_NUMBER(Integer, NSInteger)
DEFINE_EQUAL_TO_NUMBER(UnsignedInteger, NSUInteger)
