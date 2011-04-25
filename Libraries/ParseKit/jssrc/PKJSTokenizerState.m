//
//  PKJSTokenizerState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSTokenizerState.h"
#import "PKJSUtils.h"
#import "PKJSToken.h"
#import <ParseKit/PKTokenizerState.h>
#import <ParseKit/PKToken.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKTokenizerState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKTokenizerState_finalize(JSObjectRef this) {
    PKTokenizerState *data = (PKTokenizerState *)JSObjectGetPrivate(this);
    [data autorelease];
}

static JSStaticFunction PKTokenizerState_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKTokenizerState_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKTokenizerState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.staticFunctions = PKTokenizerState_staticFunctions;
        def.staticValues = PKTokenizerState_staticValues;
        def.initialize = PKTokenizerState_initialize;
        def.finalize = PKTokenizerState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKTokenizerState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKTokenizerState_class(ctx), data);
}
