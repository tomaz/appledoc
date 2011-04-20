//
//  PKJSNum.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSNum.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKNumber.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKNum_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKNum_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKNum_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKNum_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKNum_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKNum_staticFunctions;
        def.staticValues = PKNum_staticValues;
        def.initialize = PKNum_initialize;
        def.finalize = PKNum_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKNum_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKNum_class(ctx), data);
}

JSObjectRef PKNum_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKNumber *data = [[PKNumber alloc] init];
    return PKNum_new(ctx, data);
}
