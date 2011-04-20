//
//  PKJSTrack.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSTrack.h"
#import "PKJSUtils.h"
#import "PKJSSequence.h"
#import <ParseKit/PKTrack.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKTrack_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKTrack_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKTrack_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKTrack_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKTrack_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKSequence_class(ctx);
        def.staticFunctions = PKTrack_staticFunctions;
        def.staticValues = PKTrack_staticValues;
        def.initialize = PKTrack_initialize;
        def.finalize = PKTrack_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKTrack_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKTrack_class(ctx), data);
}

JSObjectRef PKTrack_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKTrack *data = [[PKTrack alloc] init];
    return PKTrack_new(ctx, data);
}
