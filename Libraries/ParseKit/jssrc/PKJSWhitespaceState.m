//
//  PKJSWhitespaceState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSWhitespaceState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKWhitespaceState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKWhitespaceState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWhitespaceState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKWhitespaceState]", ex);
}

static JSValueRef PKWhitespaceState_setWhitespaceChars(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWhitespaceState_class, "setWhitespaceChars");
    PKPreconditionMethodArgc(3, "PKWhitespaceState.setWhitespaceChars");
    
    BOOL yn = JSValueToBoolean(ctx, argv[0]);
    NSString *start = PKJSValueGetNSString(ctx, argv[1], ex);
    NSString *end = PKJSValueGetNSString(ctx, argv[2], ex);
    
    PKWhitespaceState *data = JSObjectGetPrivate(this);
    [data setWhitespaceChars:yn from:[start characterAtIndex:0] to:[end characterAtIndex:0]];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKWhitespaceState_isWhitespaceChar(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWhitespaceState_class, "isWhitespaceChar");
    PKPreconditionMethodArgc(1, "PKWhitespaceState.add");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKWhitespaceState *data = JSObjectGetPrivate(this);
    BOOL yn = [data isWhitespaceChar:[s characterAtIndex:0]];
    
    return JSValueMakeBoolean(ctx, yn);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKWhitespaceState_getReportsWhitespaceTokens(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKWhitespaceState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.reportsWhitespaceTokens);
}

static bool PKWhitespaceState_setReportsWhitespaceTokens(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKWhitespaceState *data = JSObjectGetPrivate(this);
    data.reportsWhitespaceTokens = JSValueToBoolean(ctx, value);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKWhitespaceState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKWhitespaceState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKWhitespaceState_staticFunctions[] = {
{ "toString", PKWhitespaceState_toString, kJSPropertyAttributeDontDelete },
{ "setWhitespaceChars", PKWhitespaceState_setWhitespaceChars, kJSPropertyAttributeDontDelete },
{ "isWhitespaceChar", PKWhitespaceState_isWhitespaceChar, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKWhitespaceState_staticValues[] = {        
{ "reportsWhitespaceTokens", PKWhitespaceState_getReportsWhitespaceTokens, PKWhitespaceState_setReportsWhitespaceTokens, kJSPropertyAttributeDontDelete }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKWhitespaceState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKWhitespaceState_staticFunctions;
        def.staticValues = PKWhitespaceState_staticValues;
        def.initialize = PKWhitespaceState_initialize;
        def.finalize = PKWhitespaceState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKWhitespaceState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKWhitespaceState_class(ctx), data);
}

JSObjectRef PKWhitespaceState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKWhitespaceState *data = [[PKWhitespaceState alloc] init];
    return PKWhitespaceState_new(ctx, data);
}
