//
//  PKJSAlternation.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSAlternation.h"
#import "PKJSUtils.h"
#import "PKJSCollectionParser.h"
#import <ParseKit/PKAlternation.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKAlternation_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKAlternation_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKAlternation_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKAlternation_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKAlternation_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKCollectionParser_class(ctx);
        def.staticFunctions = PKAlternation_staticFunctions;
        def.staticValues = PKAlternation_staticValues;
        def.initialize = PKAlternation_initialize;
        def.finalize = PKAlternation_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKAlternation_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKAlternation_class(ctx), data);
}

JSObjectRef PKAlternation_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKAlternation *data = [[PKAlternation alloc] init];
    return PKAlternation_new(ctx, data);
}
