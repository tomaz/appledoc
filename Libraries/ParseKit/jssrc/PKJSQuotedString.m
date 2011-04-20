//
//  PKJSQuotedString.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSQuotedString.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKQuotedString.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKQuotedString_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKQuotedString_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKQuotedString_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKQuotedString_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKQuotedString_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKQuotedString_staticFunctions;
        def.staticValues = PKQuotedString_staticValues;
        def.initialize = PKQuotedString_initialize;
        def.finalize = PKQuotedString_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKQuotedString_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKQuotedString_class(ctx), data);
}

JSObjectRef PKQuotedString_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKQuotedString *data = [[PKQuotedString alloc] init];
    return PKQuotedString_new(ctx, data);
}
