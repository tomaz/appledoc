//
//  PKJSCharacterAssembly.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSCharacterAssembly.h"
#import "PKJSUtils.h"
#import "PKJSAssembly.h"
#import <ParseKit/PKCharacterAssembly.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKCharacterAssembly_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCharacterAssembly_class, "toString");
    PKCharacterAssembly *data = JSObjectGetPrivate(this);
    JSStringRef resStr = JSStringCreateWithCFString((CFStringRef)[data description]);
    JSValueRef res = JSValueMakeString(ctx, resStr);
    JSStringRelease(resStr);
    return res;
}

static JSValueRef PKCharacterAssembly_pop(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCharacterAssembly_class, "pop");
    PKCharacterAssembly *data = JSObjectGetPrivate(this);
    NSNumber *obj = [data pop];
    return JSValueMakeNumber(ctx, [obj doubleValue]);
}

static JSValueRef PKCharacterAssembly_push(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCharacterAssembly_class, "push");
    PKPreconditionMethodArgc(1, "PKCharacterAssembly.push");
    
    JSValueRef v = argv[0];
    
    PKCharacterAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    [data push:obj];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKCharacterAssembly_objectsAbove(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCharacterAssembly_class, "objectsAbove");
    PKPreconditionMethodArgc(1, "PKCharacterAssembly.objectsAbove");
    
    JSValueRef v = argv[0];
    
    PKCharacterAssembly *data = JSObjectGetPrivate(this);
    id obj = PKJSValueGetId(ctx, v, ex);
    id array = [data objectsAbove:obj];
    
    return PKNSArrayToJSObject(ctx, array, ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKCharacterAssembly_getLength(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKCharacterAssembly *data = JSObjectGetPrivate(this);
    return JSValueMakeNumber(ctx, [data length]);
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKCharacterAssembly_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKCharacterAssembly_finalize(JSObjectRef this) {
    // released in PKAssembly_finalize
}

static JSStaticFunction PKCharacterAssembly_staticFunctions[] = {
{ "toString", PKCharacterAssembly_toString, kJSPropertyAttributeDontDelete },        
{ "pop", PKCharacterAssembly_pop, kJSPropertyAttributeDontDelete },        
{ "push", PKCharacterAssembly_push, kJSPropertyAttributeDontDelete },        
{ "objectsAbove", PKCharacterAssembly_objectsAbove, kJSPropertyAttributeDontDelete },        
{ 0, 0, 0 }
};

static JSStaticValue PKCharacterAssembly_staticValues[] = {        
{ "length", PKCharacterAssembly_getLength, NULL, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly }, // Number
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark ClassMethods

#pragma mark -
#pragma mark Public

JSClassRef PKCharacterAssembly_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKAssembly_class(ctx);
        def.staticFunctions = PKCharacterAssembly_staticFunctions;
        def.staticValues = PKCharacterAssembly_staticValues;
        def.initialize = PKCharacterAssembly_initialize;
        def.finalize = PKCharacterAssembly_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKCharacterAssembly_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKCharacterAssembly_class(ctx), data);
}

JSObjectRef PKCharacterAssembly_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKCharacterAssembly");
    
    JSValueRef s = argv[0];
    NSString *string = PKJSValueGetNSString(ctx, s, ex);
    
    PKCharacterAssembly *data = [[PKCharacterAssembly alloc] initWithString:string];
    return PKCharacterAssembly_new(ctx, data);
}
