//
//  PKJSPattern.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSPattern.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKPattern.h>

#pragma mark -
#pragma mark Methods

//static JSValueRef PKPattern_invertedPattern(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
//    PKPreconditionInstaceOf(PKPattern_class, "invertedPattern");
//    
//    PKPattern *data = JSObjectGetPrivate(this);
//    return PKPattern_new(ctx, [data invertedPattern]);
//}
//
#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKPattern_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKPattern_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKPattern_staticFunctions[] = {
//{ "invertedPattern", PKPattern_invertedPattern, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKPattern_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKPattern_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKPattern_staticFunctions;
        def.staticValues = PKPattern_staticValues;
        def.initialize = PKPattern_initialize;
        def.finalize = PKPattern_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKPattern_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKPattern_class(ctx), data);
}

JSObjectRef PKPattern_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKPattern");

    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    NSInteger opts = PKPatternOptionsNone;
    
    if (argc > 1) {
        opts = JSValueToNumber(ctx, argv[1], ex);
    }

    PKPattern *data = [[PKPattern alloc] initWithString:s options:opts];
    return PKPattern_new(ctx, data);
}
