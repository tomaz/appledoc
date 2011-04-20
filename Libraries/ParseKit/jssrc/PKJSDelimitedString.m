//
//  PKJSDelimitedString.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSDelimitedString.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKDelimitedString.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKDelimitedString_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKDelimitedString_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKDelimitedString_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKDelimitedString_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKDelimitedString_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKDelimitedString_staticFunctions;
        def.staticValues = PKDelimitedString_staticValues;
        def.initialize = PKDelimitedString_initialize;
        def.finalize = PKDelimitedString_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKDelimitedString_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKDelimitedString_class(ctx), data);
}

JSObjectRef PKDelimitedString_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKDelimitedString");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKDelimitedString *data = [[PKDelimitedString alloc] initWithString:s];
    return PKDelimitedString_new(ctx, data);
}
