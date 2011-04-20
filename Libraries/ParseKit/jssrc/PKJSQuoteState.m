//
//  PKJSQuoteState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSQuoteState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKQuoteState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKQuoteState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKQuoteState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKQuoteState]", ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKQuoteState_getBalancesEOFTerminatedQuotes(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKQuoteState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.balancesEOFTerminatedQuotes);
}

static bool PKQuoteState_setBalancesEOFTerminatedQuotes(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKQuoteState *data = JSObjectGetPrivate(this);
    data.balancesEOFTerminatedQuotes = JSValueToBoolean(ctx, value);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKQuoteState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKQuoteState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKQuoteState_staticFunctions[] = {
{ "toString", PKQuoteState_toString, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKQuoteState_staticValues[] = {
{ "balancesEOFTerminatedQuotes", PKQuoteState_getBalancesEOFTerminatedQuotes, PKQuoteState_setBalancesEOFTerminatedQuotes, kJSPropertyAttributeDontDelete }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKQuoteState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKQuoteState_staticFunctions;
        def.staticValues = PKQuoteState_staticValues;
        def.initialize = PKQuoteState_initialize;
        def.finalize = PKQuoteState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKQuoteState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKQuoteState_class(ctx), data);
}

JSObjectRef PKQuoteState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKQuoteState *data = [[PKQuoteState alloc] init];
    return PKQuoteState_new(ctx, data);
}
