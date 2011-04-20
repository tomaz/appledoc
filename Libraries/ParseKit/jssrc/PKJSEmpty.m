//
//  PKJSEmpty.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSEmpty.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKEmpty.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKEmpty_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKEmpty_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKEmpty_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKEmpty_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKEmpty_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKEmpty_staticFunctions;
        def.staticValues = PKEmpty_staticValues;
        def.initialize = PKEmpty_initialize;
        def.finalize = PKEmpty_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKEmpty_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKEmpty_class(ctx), data);
}

JSObjectRef PKEmpty_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKEmpty *data = [[PKEmpty alloc] init];
    return PKEmpty_new(ctx, data);
}
