/*
 *  PKJSUtils_macros.h
 *  ParseKit
 *
 *  Created by Todd Ditchendorf on 1/11/09.
 *  Copyright 2009 Todd Ditchendorf. All rights reserved.
 *
 */

#undef PKPreconditionInstaceOf
#define PKPreconditionInstaceOf(cls, meth) \
    if (!JSValueIsObjectOfClass(ctx, this, (cls)(ctx))) { \
        NSString *s = [NSString stringWithFormat:@"calling method '%s' on an object that is not an instance of '%s'", (meth), #cls]; \
        (*ex) = PKNSStringToJSValue(ctx, s, ex); \
        return JSValueMakeUndefined(ctx); \
    }

#undef PKPreconditionMethodArgc
#define PKPreconditionMethodArgc(n, meth) \
    if (argc < (n)) { \
        NSString *s = [NSString stringWithFormat:@"%s() requires %d arguments", (meth), (n)]; \
        (*ex) = PKNSStringToJSValue(ctx, s, ex); \
        return JSValueMakeUndefined(ctx); \
    }

#undef PKPreconditionConstructorArgc
#define PKPreconditionConstructorArgc(n, meth) \
    if (argc < (n)) { \
        NSString *s = [NSString stringWithFormat:@"%s constructor requires %d arguments", (meth), (n)]; \
        (*ex) = PKNSStringToJSValue(ctx, s, ex); \
        return NULL; \
    }

