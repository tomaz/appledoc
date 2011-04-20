//
//  PKJSParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/10/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSParser.h"
#import "PKJSUtils.h"
#import "PKJSAssemblerAdapter.h"
#import "PKJSAssembly.h"
#import "PKJSTokenAssembly.h"
#import "PKJSCharacterAssembly.h"
#import <ParseKit/PKParser.h>
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKCharacterAssembly.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKParser_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKParser_class, "toString");
    PKParser *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, [data description], ex);
}

static JSValueRef PKParser_bestMatch(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKParser_class, "bestMatch");
    PKPreconditionMethodArgc(1, "bestMatch");
    
    PKParser *data = JSObjectGetPrivate(this);

    JSObjectRef arg = (JSObjectRef)argv[0];
    PKAssembly *a = (PKAssembly *)JSObjectGetPrivate(arg);
    a = [data bestMatchFor:a];
    
    JSObjectRef result = NULL;
    if ([a isMemberOfClass:[PKTokenAssembly class]]) {
        result = PKTokenAssembly_new(ctx, a);
    } else if ([a isMemberOfClass:[PKCharacterAssembly class]]) {
        result = PKCharacterAssembly_new(ctx, a);
    }

    return result;
}

static JSValueRef PKParser_completeMatch(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKParser_class, "completeMatch");
    PKPreconditionMethodArgc(1, "completeMatch");
    
    PKParser *data = JSObjectGetPrivate(this);
    
    JSObjectRef arg = (JSObjectRef)argv[0];
    PKAssembly *a = (PKAssembly *)JSObjectGetPrivate(arg);
    a = [data completeMatchFor:a];
    
    JSObjectRef result = NULL;
    if ([a isMemberOfClass:[PKTokenAssembly class]]) {
        result = PKTokenAssembly_new(ctx, a);
    } else if ([a isMemberOfClass:[PKCharacterAssembly class]]) {
        result = PKCharacterAssembly_new(ctx, a);
    }
    
    return result;
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKParser_getAssembler(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKParser *data = JSObjectGetPrivate(this);
    id assembler = data.assembler;
    if ([assembler isMemberOfClass:[PKJSAssemblerAdapter class]]) {
        return [assembler assemblerFunction];
    } else {
        return NULL;
    }
}

static bool PKParser_setAssembler(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    if (!JSValueIsObject(ctx, value) || !JSObjectIsFunction(ctx, (JSObjectRef)value)) {
        (*ex) = PKNSStringToJSValue(ctx, @"only a function object can be set as a parser's assembler property", ex);
        return false;
    }
    
    PKParser *data = JSObjectGetPrivate(this);
    PKJSAssemblerAdapter *adapter = [[PKJSAssemblerAdapter alloc] init]; // retained. released in PKParser_finalize
    [adapter setAssemblerFunction:(JSObjectRef)value fromContext:ctx];
    [data setAssembler:adapter selector:@selector(didMatch:)];
    return true;
}

static JSValueRef PKParser_getName(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKParser *data = JSObjectGetPrivate(this);
    return PKNSStringToJSValue(ctx, data.name, ex);
}

static bool PKParser_setName(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKParser *data = JSObjectGetPrivate(this);
    data.name = PKJSValueGetNSString(ctx, value, ex);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKParser_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKParser_finalize(JSObjectRef this) {
    PKParser *data = (PKParser *)JSObjectGetPrivate(this);
    id assembler = data.assembler;
    data.assembler = nil;
    if ([assembler isMemberOfClass:[PKJSAssemblerAdapter class]]) {
        [assembler autorelease];
    }
    [data autorelease];
}

static JSStaticFunction PKParser_staticFunctions[] = {
{ "toString", PKParser_toString, kJSPropertyAttributeDontDelete },
{ "bestMatch", PKParser_bestMatch, kJSPropertyAttributeDontDelete },
{ "completeMatch", PKParser_completeMatch, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKParser_staticValues[] = {        
{ "assembler", PKParser_getAssembler, PKParser_setAssembler, kJSPropertyAttributeDontDelete }, // Function
{ "name", PKParser_getName, PKParser_setName, kJSPropertyAttributeDontDelete }, // String
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKParser_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.staticFunctions = PKParser_staticFunctions;
        def.staticValues = PKParser_staticValues;
        def.initialize = PKParser_initialize;
        def.finalize = PKParser_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKParser_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKParser_class(ctx), data);
}
