//
//  PKJSDelimitedString.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKDelimitedString_new(JSContextRef ctx, void *data);
JSClassRef PKDelimitedString_class(JSContextRef ctx);
JSObjectRef PKDelimitedString_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
