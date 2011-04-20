//
//  PKJSToken.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSToken.h"
#import "PKJSUtils.h"
#import <ParseKit/PKToken.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKToken_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKToken_class, "toString");
    PKToken *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, [data debugDescription], ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKToken_getTokenType(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeNumber(ctx, data.tokenType);
}

static JSValueRef PKToken_getStringValue(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, data.stringValue, ex);
}

static JSValueRef PKToken_getFloatValue(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeNumber(ctx, data.floatValue);
}

static JSValueRef PKToken_getIsNumber(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isNumber);
}

static JSValueRef PKToken_getIsSymbol(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isSymbol);
}

static JSValueRef PKToken_getIsWord(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isWord);
}

static JSValueRef PKToken_getIsQuotedString(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isQuotedString);
}

static JSValueRef PKToken_getIsWhitespace(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isWhitespace);
}

static JSValueRef PKToken_getIsComment(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isComment);
}

static JSValueRef PKToken_getIsDelimitedString(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKToken *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isDelimitedString);
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKToken_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKToken_finalize(JSObjectRef this) {
    PKToken *data = (PKToken *)JSObjectGetPrivate(this);
    [data autorelease];
}

static JSStaticFunction PKToken_staticFunctions[] = {
{ "toString", PKToken_toString, kJSPropertyAttributeDontDelete },        
{ 0, 0, 0 }
};

static JSStaticValue PKToken_staticValues[] = {        
{ "tokenType", PKToken_getTokenType, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Number
{ "stringValue", PKToken_getStringValue, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // String
{ "floatValue", PKToken_getFloatValue, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Number
{ "isNumber", PKToken_getIsNumber, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isSymbol", PKToken_getIsSymbol, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isWord", PKToken_getIsWord, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isQuotedString", PKToken_getIsQuotedString, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isWhitespace", PKToken_getIsWhitespace, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isComment", PKToken_getIsComment, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ "isDelimitedString", PKToken_getIsDelimitedString, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Class Methods

// JSObjectCallAsFunctionCallback
//JSValueRef PKToken_EOFToken(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
//    static JSValueRef eof = NULL;
//    if (!eof) {
//        eof = PKToken_new(ctx, [PKToken EOFToken]);
//        JSValueProtect(ctx, eof); // is this necessary/appropriate?
//    }
//    return eof;
//}

#pragma mark -
#pragma mark Class Properties

JSValueRef PKToken_getEOFToken(JSContextRef ctx) {
    static JSObjectRef eof = NULL;
    if (!eof) {
        eof = PKToken_new(ctx, [PKToken EOFToken]);
    }
    return eof;
}

#pragma mark -
#pragma mark Public

JSClassRef PKToken_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.staticFunctions = PKToken_staticFunctions;
        def.staticValues = PKToken_staticValues;
        def.initialize = PKToken_initialize;
        def.finalize = PKToken_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKToken_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKToken_class(ctx), data);
}

JSObjectRef PKToken_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(3, "PKToken");
    
    CGFloat tokenType = JSValueToNumber(ctx, argv[0], NULL);
    NSString *stringValue = PKJSValueGetNSString(ctx, argv[1], ex);
    CGFloat floatValue = JSValueToNumber(ctx, argv[2], NULL);

    PKToken *data = [[PKToken alloc] initWithTokenType:tokenType stringValue:stringValue floatValue:floatValue];
    return PKToken_new(ctx, data);
}
