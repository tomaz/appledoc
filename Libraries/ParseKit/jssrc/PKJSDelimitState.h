//
//  PKJSDelimitState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKDelimitState_new(JSContextRef ctx, void *data);
JSClassRef PKDelimitState_class(JSContextRef ctx);
JSObjectRef PKDelimitState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
