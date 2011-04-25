//
//  PKJSSymbol.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSSymbol.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKSymbol.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKSymbol_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKSymbol_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKSymbol_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKSymbol_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKSymbol_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKSymbol_staticFunctions;
        def.staticValues = PKSymbol_staticValues;
        def.initialize = PKSymbol_initialize;
        def.finalize = PKSymbol_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKSymbol_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKSymbol_class(ctx), data);
}

JSObjectRef PKSymbol_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    NSString *s = nil;
    
    if (argc > 0) {
        s = PKJSValueGetNSString(ctx, argv[0], ex);
    }
    
    PKSymbol *data = [[PKSymbol alloc] initWithString:s];
    return PKSymbol_new(ctx, data);
}
