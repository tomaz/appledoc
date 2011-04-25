//
//  PKJSTokenAssembly.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/3/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSTokenAssembly.h"
#import "PKJSToken.h"
#import "PKJSUtils.h"
#import "PKJSAssembly.h"
#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKToken.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKTokenAssembly_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenAssembly_class, "toString");
    PKTokenAssembly *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, [data description], ex);
}

static JSValueRef PKTokenAssembly_pop(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenAssembly_class, "pop");
    PKTokenAssembly *data = JSObjectGetPrivate(this);
    PKToken *tok = [data pop];
    return PKToken_new(ctx, tok);
}

static JSValueRef PKTokenAssembly_push(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenAssembly_class, "push");
    PKPreconditionMethodArgc(1, "PKTokenAssembly.push");
    
    JSValueRef v = argv[0];

    PKTokenAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    [data push:obj];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKTokenAssembly_objectsAbove(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTokenAssembly_class, "objectsAbove");
    PKPreconditionMethodArgc(1, "PKTokenAssembly.objectsAbove");
    
    JSValueRef v = argv[0];
    
    PKTokenAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    id array = [data objectsAbove:obj];
    
    return PKNSArrayToJSObject(ctx, array, ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKTokenAssembly_getLength(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKTokenAssembly *data = JSObjectGetPrivate(this);
    return JSValueMakeNumber(ctx, [data length]);
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKTokenAssembly_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKTokenAssembly_finalize(JSObjectRef this) {
    // released in PKAssembly_finalize
}

static JSStaticFunction PKTokenAssembly_staticFunctions[] = {
{ "toString", PKTokenAssembly_toString, kJSPropertyAttributeDontDelete },        
{ "pop", PKTokenAssembly_pop, kJSPropertyAttributeDontDelete },        
{ "push", PKTokenAssembly_push, kJSPropertyAttributeDontDelete },        
{ "objectsAbove", PKTokenAssembly_objectsAbove, kJSPropertyAttributeDontDelete },        
{ 0, 0, 0 }
};

static JSStaticValue PKTokenAssembly_staticValues[] = {        
{ "length", PKTokenAssembly_getLength, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Number
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark ClassMethods

#pragma mark -
#pragma mark Public

JSClassRef PKTokenAssembly_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKAssembly_class(ctx);
        def.staticFunctions = PKTokenAssembly_staticFunctions;
        def.staticValues = PKTokenAssembly_staticValues;
        def.initialize = PKTokenAssembly_initialize;
        def.finalize = PKTokenAssembly_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKTokenAssembly_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKTokenAssembly_class(ctx), data);
}

JSObjectRef PKTokenAssembly_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKTokenAssembly");

    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);

    PKTokenAssembly *data = [[PKTokenAssembly alloc] initWithString:s];
    return PKTokenAssembly_new(ctx, data);
}
