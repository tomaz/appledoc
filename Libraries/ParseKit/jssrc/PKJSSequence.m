//
//  PKJSSequence.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSSequence.h"
#import "PKJSUtils.h"
#import "PKJSCollectionParser.h"
#import <ParseKit/PKSequence.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKSequence_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKSequence_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKSequence_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKSequence_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKSequence_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKCollectionParser_class(ctx);
        def.staticFunctions = PKSequence_staticFunctions;
        def.staticValues = PKSequence_staticValues;
        def.initialize = PKSequence_initialize;
        def.finalize = PKSequence_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKSequence_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKSequence_class(ctx), data);
}

JSObjectRef PKSequence_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKSequence *data = [[PKSequence alloc] init];
    return PKSequence_new(ctx, data);
}
