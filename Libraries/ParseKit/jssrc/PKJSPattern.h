//
//  PKJSPattern.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKPattern_new(JSContextRef ctx, void *data);
JSClassRef PKPattern_class(JSContextRef ctx);
JSObjectRef PKPattern_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
