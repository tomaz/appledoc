//
//  PKJSDelimitState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSDelimitState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKDelimitState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKDelimitState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKDelimitState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKDelimitState]", ex);
}

static JSValueRef PKDelimitState_add(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKDelimitState_class, "add");
    PKPreconditionMethodArgc(4, "PKDelimitState.add");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    NSString *end = PKJSValueGetNSString(ctx, argv[1], ex);
    NSString *chars = PKJSValueGetNSString(ctx, argv[2], ex);
    BOOL invert = JSValueToBoolean(ctx, argv[3]);
    
    PKDelimitState *data = JSObjectGetPrivate(this);
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:chars];
    if (invert) {
        cs = [cs invertedSet];
    }
    [data addStartMarker:start endMarker:end allowedCharacterSet:cs];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKDelimitState_remove(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKDelimitState_class, "remove");
    PKPreconditionMethodArgc(1, "PKDelimitState.remove");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKDelimitState *data = JSObjectGetPrivate(this);
    [data removeStartMarker:start];
    
    return JSValueMakeUndefined(ctx);
}

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKDelimitState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKDelimitState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKDelimitState_staticFunctions[] = {
{ "toString", PKDelimitState_toString, kJSPropertyAttributeDontDelete },
{ "add", PKDelimitState_add, kJSPropertyAttributeDontDelete },
{ "remove", PKDelimitState_remove, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKDelimitState_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKDelimitState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKDelimitState_staticFunctions;
        def.staticValues = PKDelimitState_staticValues;
        def.initialize = PKDelimitState_initialize;
        def.finalize = PKDelimitState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKDelimitState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKDelimitState_class(ctx), data);
}

JSObjectRef PKDelimitState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKDelimitState *data = [[PKDelimitState alloc] init];
    return PKDelimitState_new(ctx, data);
}
