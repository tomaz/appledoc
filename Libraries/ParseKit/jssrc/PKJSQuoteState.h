//
//  PKJSQuoteState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKQuoteState_new(JSContextRef ctx, void *data);
JSClassRef PKQuoteState_class(JSContextRef ctx);
JSObjectRef PKQuoteState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
