//
//  PKJSTokenizer.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/3/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKTokenizer_new(JSContextRef ctx, void *data);
JSClassRef PKTokenizer_class(JSContextRef ctx);
JSObjectRef PKTokenizer_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
