//
//  PKJSTokenizer.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/3/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSTokenizer.h"
#import "PKJSUtils.h"
#import "PKJSToken.h"
#import "PKJSWordState.h"
#import "PKJSNumberState.h"
#import "PKJSQuoteState.h"
#import "PKJSWhitespaceState.h"
#import "PKJSCommentState.h"
#import "PKJSSymbolState.h"
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizerState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKTokenizer_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenizer_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKTokenizer]", ex);
}

static JSValueRef PKTokenizer_nextToken(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenizer_class, "nextToken");
    PKTokenizer *data = JSObjectGetPrivate(this);

    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [data nextToken];
    
    if (eof == tok) {
        return PKToken_getEOFToken(ctx);
    }
    
    return PKToken_new(ctx, tok);
}

static JSValueRef PKTokenizer_setTokenizerState(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenizer_class, "setTokenizerState");
    PKPreconditionMethodArgc(3, "PKTokenizer.setTokenizerState");
    
    JSObjectRef stateObj = (JSObjectRef)argv[0];
    PKTokenizerState *state = JSObjectGetPrivate(stateObj);
    NSString *from = PKJSValueGetNSString(ctx, argv[1], ex);
    NSString *to = PKJSValueGetNSString(ctx, argv[2], ex);
    
    PKTokenizer *data = JSObjectGetPrivate(this);
    [data setTokenizerState:state from:[from characterAtIndex:0] to:[to characterAtIndex:0]];

    return JSValueMakeUndefined(ctx);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKTokenizer_getString(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, data.string, ex);
}

static bool PKTokenizer_setString(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    data.string = PKJSValueGetNSString(ctx, value, ex);
    return true;
}

static JSValueRef PKTokenizer_getWordState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKWordState_new(ctx, data.wordState);
    return NULL;
}

static bool PKTokenizer_setWordState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKWordState *state = JSObjectGetPrivate(stateObj);
    data.wordState = state;
    return true;
}

static JSValueRef PKTokenizer_getNumberState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKNumberState_new(ctx, data.numberState);
    return NULL;
}

static bool PKTokenizer_setNumberState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKNumberState *state = JSObjectGetPrivate(stateObj);
    data.numberState = state;
    return true;
}

static JSValueRef PKTokenizer_getQuoteState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKQuoteState_new(ctx, data.quoteState);
    return NULL;
}

static bool PKTokenizer_setQuoteState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKQuoteState *state = JSObjectGetPrivate(stateObj);
    data.quoteState = state;
    return true;
}

static JSValueRef PKTokenizer_getSymbolState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKSymbolState_new(ctx, data.symbolState);
    return NULL;
}

static bool PKTokenizer_setSymbolState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKSymbolState *state = JSObjectGetPrivate(stateObj);
    data.symbolState = state;
    return true;
}

static JSValueRef PKTokenizer_getWhitespaceState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKWhitespaceState_new(ctx, data.whitespaceState);
    return NULL;
}

static bool PKTokenizer_setWhitespaceState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKWhitespaceState *state = JSObjectGetPrivate(stateObj);
    data.whitespaceState = state;
    return true;
}

static JSValueRef PKTokenizer_getCommentState(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    return PKCommentState_new(ctx, data.commentState);
    return NULL;
}

static bool PKTokenizer_setCommentState(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKTokenizer *data = JSObjectGetPrivate(this);
    JSObjectRef stateObj = JSValueToObject(ctx, value, ex);
    PKCommentState *state = JSObjectGetPrivate(stateObj);
    data.commentState = state;
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKTokenizer_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKTokenizer_finalize(JSObjectRef this) {
    PKTokenizer *data = (PKTokenizer *)JSObjectGetPrivate(this);
    [data autorelease];
}

static JSStaticFunction PKTokenizer_staticFunctions[] = {
{ "toString", PKTokenizer_toString, kJSPropertyAttributeDontDelete },
{ "setTokenizerState", PKTokenizer_setTokenizerState, kJSPropertyAttributeDontDelete },
{ "nextToken", PKTokenizer_nextToken, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKTokenizer_staticValues[] = {        
{ "string", PKTokenizer_getString, PKTokenizer_setString, kJSPropertyAttributeDontDelete }, // String
{ "numberState", PKTokenizer_getNumberState, PKTokenizer_setNumberState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ "quoteState", PKTokenizer_getQuoteState, PKTokenizer_setQuoteState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ "commentState", PKTokenizer_getCommentState, PKTokenizer_setCommentState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ "symbolState", PKTokenizer_getSymbolState, PKTokenizer_setSymbolState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ "whitespaceState", PKTokenizer_getWhitespaceState, PKTokenizer_setWhitespaceState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ "wordState", PKTokenizer_getWordState, PKTokenizer_setWordState, kJSPropertyAttributeDontDelete }, // PKTokenizerState
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKTokenizer_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.staticFunctions = PKTokenizer_staticFunctions;
        def.staticValues = PKTokenizer_staticValues;
        def.initialize = PKTokenizer_initialize;
        def.finalize = PKTokenizer_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKTokenizer_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKTokenizer_class(ctx), data);
}

JSObjectRef PKTokenizer_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKTokenizer");
    
    JSValueRef s = argv[0];
    NSString *string = PKJSValueGetNSString(ctx, s, ex);
    
    PKTokenizer *data = [[PKTokenizer alloc] initWithString:string];
    return PKTokenizer_new(ctx, data);
}
