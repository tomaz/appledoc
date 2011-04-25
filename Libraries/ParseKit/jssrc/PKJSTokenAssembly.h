//
//  PKJSTokenAssembly.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/3/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKTokenAssembly_new(JSContextRef ctx, void *data);
JSClassRef PKTokenAssembly_class(JSContextRef ctx);
JSObjectRef PKTokenAssembly_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
