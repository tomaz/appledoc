//
//  PKJSUppercaseWord.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/13/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSUppercaseWord.h"
#import "PKJSUtils.h"
#import "PKJSWord.h"
#import <ParseKit/PKUppercaseWord.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKUppercaseWord_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKUppercaseWord_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKUppercaseWord_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKUppercaseWord_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKUppercaseWord_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKWord_class(ctx);
        def.staticFunctions = PKUppercaseWord_staticFunctions;
        def.staticValues = PKUppercaseWord_staticValues;
        def.initialize = PKUppercaseWord_initialize;
        def.finalize = PKUppercaseWord_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKUppercaseWord_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKUppercaseWord_class(ctx), data);
}

JSObjectRef PKUppercaseWord_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKUppercaseWord");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKUppercaseWord *data = [[PKUppercaseWord alloc] initWithString:s];
    return PKUppercaseWord_new(ctx, data);
}
