//
//  PKJSAssembly.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/3/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSAssembly.h"
#import "PKJSToken.h"
#import "PKJSUtils.h"
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKToken.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKAssembly_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKAssembly_class, "toString");
    PKAssembly *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, [data description], ex);
}

static JSValueRef PKAssembly_pop(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKAssembly_class, "pop");
    
    PKAssembly *data = JSObjectGetPrivate(this);
    PKToken *tok = [data pop];
    return PKToken_new(ctx, tok);
}

static JSValueRef PKAssembly_push(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKAssembly_class, "push");
    PKPreconditionMethodArgc(1, "PKAssembly.push");
    
    JSValueRef v = argv[0];
    
    PKAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    [data push:obj];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKAssembly_objectsAbove(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKAssembly_class, "objectsAbove");
    PKPreconditionMethodArgc(1, "PKAssembly.objectsAbove");
    
    JSValueRef v = argv[0];
    
    PKAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    id array = [data objectsAbove:obj];
    
    return PKNSArrayToJSObject(ctx, array, ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKAssembly_getDefaultDelimiter(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKAssembly *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, data.defaultDelimiter, ex);
}

static JSValueRef PKAssembly_getStack(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKAssembly *data = JSObjectGetPrivate(this);
    return PKNSArrayToJSObject(ctx, data.stack, ex);
}

static JSValueRef PKAssembly_getTarget(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKAssembly *data = JSObjectGetPrivate(this);
    return PKCFTypeToJSValue(ctx, (CFTypeRef)data.target, ex);
}

static bool PKAssembly_setTarget(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKAssembly *data = JSObjectGetPrivate(this);
    data.target = PKJSValueGetId(ctx, value, ex);
    return true;
}

static JSValueRef PKAssembly_getIsStackEmpty(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKAssembly *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.isStackEmpty);
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKAssembly_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKAssembly_finalize(JSObjectRef this) {
    PKAssembly *data = (PKAssembly *)JSObjectGetPrivate(this);
    [data autorelease];
}

static JSStaticFunction PKAssembly_staticFunctions[] = {
{ "toString", PKAssembly_toString, kJSPropertyAttributeDontDelete },        
{ "pop", PKAssembly_pop, kJSPropertyAttributeDontDelete },        
{ "push", PKAssembly_push, kJSPropertyAttributeDontDelete },        
{ "objectsAbove", PKAssembly_objectsAbove, kJSPropertyAttributeDontDelete },        
{ 0, 0, 0 }
};

static JSStaticValue PKAssembly_staticValues[] = {        
{ "defaulDelimiter", PKAssembly_getDefaultDelimiter, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // String
{ "stack", PKAssembly_getStack, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Array
{ "target", PKAssembly_getTarget, PKAssembly_setTarget, kJSPropertyAttributeDontDelete }, // Object
{ "isStackEmpty", PKAssembly_getIsStackEmpty, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark ClassMethods

#pragma mark -
#pragma mark Public

JSClassRef PKAssembly_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.staticFunctions = PKAssembly_staticFunctions;
        def.staticValues = PKAssembly_staticValues;
        def.initialize = PKAssembly_initialize;
        def.finalize = PKAssembly_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKAssembly_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKAssembly_class(ctx), data);
}
