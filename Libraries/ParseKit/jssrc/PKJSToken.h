//
//  PKJSToken.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKToken_new(JSContextRef ctx, void *data);
JSClassRef PKToken_class(JSContextRef ctx);
JSObjectRef PKToken_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);

// a JS Class method
//JSValueRef PKToken_EOFToken(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef* ex);

// a JS Class property
JSValueRef PKToken_getEOFToken(JSContextRef ctx);
