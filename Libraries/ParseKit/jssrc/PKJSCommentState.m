//
//  PKJSCommentState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSCommentState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKCommentState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKCommentState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCommentState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKCommentState]", ex);
}

static JSValueRef PKCommentState_addSingleLine(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCommentState_class, "addSingleLine");
    PKPreconditionMethodArgc(1, "PKCommentState.addSingleLine");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKCommentState *data = JSObjectGetPrivate(this);
    [data addSingleLineStartMarker:start];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKCommentState_removeSingleLine(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCommentState_class, "removeSingleLine");
    PKPreconditionMethodArgc(1, "PKCommentState.removeSingleLine");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKCommentState *data = JSObjectGetPrivate(this);
    [data removeSingleLineStartMarker:start];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKCommentState_addMultiLine(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCommentState_class, "addMultiLine");
    PKPreconditionMethodArgc(2, "PKCommentState.addMultiLine");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    NSString *end = PKJSValueGetNSString(ctx, argv[1], ex);
    
    PKCommentState *data = JSObjectGetPrivate(this);
    [data addMultiLineStartMarker:start endMarker:end];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKCommentState_removeMultiLine(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCommentState_class, "removeSingleLine");
    PKPreconditionMethodArgc(1, "PKCommentState.removeMultiLine");
    
    NSString *start = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKCommentState *data = JSObjectGetPrivate(this);
    [data removeMultiLineStartMarker:start];
    
    return JSValueMakeUndefined(ctx);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKCommentState_getReportsCommentTokens(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKCommentState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.reportsCommentTokens);
}

static bool PKCommentState_setReportsCommentTokens(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKCommentState *data = JSObjectGetPrivate(this);
    data.reportsCommentTokens = JSValueToBoolean(ctx, value);
    return true;
}

static JSValueRef PKCommentState_getBalancesEOFTerminatedComments(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKCommentState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.balancesEOFTerminatedComments);
}

static bool PKCommentState_setBalancesEOFTerminatedComments(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKCommentState *data = JSObjectGetPrivate(this);
    data.balancesEOFTerminatedComments = JSValueToBoolean(ctx, value);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKCommentState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKCommentState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKCommentState_staticFunctions[] = {
{ "toString", PKCommentState_toString, kJSPropertyAttributeDontDelete },
{ "addSingleLine", PKCommentState_addSingleLine, kJSPropertyAttributeDontDelete },
{ "removeSingleLine", PKCommentState_removeSingleLine, kJSPropertyAttributeDontDelete },
{ "addMultiLine", PKCommentState_addMultiLine, kJSPropertyAttributeDontDelete },
{ "removeMultiLine", PKCommentState_removeMultiLine, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};


static JSStaticValue PKCommentState_staticValues[] = {        
{ "reportsCommentTokens", PKCommentState_getReportsCommentTokens, PKCommentState_setReportsCommentTokens, kJSPropertyAttributeDontDelete }, // Boolean
{ "balancesEOFTerminatedComments", PKCommentState_getBalancesEOFTerminatedComments, PKCommentState_setBalancesEOFTerminatedComments, kJSPropertyAttributeDontDelete }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKCommentState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKCommentState_staticFunctions;
        def.staticValues = PKCommentState_staticValues;
        def.initialize = PKCommentState_initialize;
        def.finalize = PKCommentState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKCommentState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKCommentState_class(ctx), data);
}

JSObjectRef PKCommentState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKCommentState *data = [[PKCommentState alloc] init];
    return PKCommentState_new(ctx, data);
}
