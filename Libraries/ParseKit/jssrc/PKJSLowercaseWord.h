//
//  PKJSLowercaseWord.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/13/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKLowercaseWord_new(JSContextRef ctx, void *data);
JSClassRef PKLowercaseWord_class(JSContextRef ctx);
JSObjectRef PKLowercaseWord_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
