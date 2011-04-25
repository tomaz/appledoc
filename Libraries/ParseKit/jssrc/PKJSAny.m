//
//  PKJSAny.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSAny.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKAny.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKAny_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKAny_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKAny_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKAny_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKAny_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKAny_staticFunctions;
        def.staticValues = PKAny_staticValues;
        def.initialize = PKAny_initialize;
        def.finalize = PKAny_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKAny_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKAny_class(ctx), data);
}

JSObjectRef PKAny_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKAny *data = [[PKAny alloc] init];
    return PKAny_new(ctx, data);
}
