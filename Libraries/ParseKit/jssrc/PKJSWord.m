//
//  PKJSWord.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSWord.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKWord.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKWord_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKWord_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKWord_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKWord_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKWord_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKWord_staticFunctions;
        def.staticValues = PKWord_staticValues;
        def.initialize = PKWord_initialize;
        def.finalize = PKWord_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKWord_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKWord_class(ctx), data);
}

JSObjectRef PKWord_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKWord *data = [[PKWord alloc] init];
    return PKWord_new(ctx, data);
}
