//
//  PKJSCharacterAssembly.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKCharacterAssembly_new(JSContextRef ctx, void *data);
JSClassRef PKCharacterAssembly_class(JSContextRef ctx);
JSObjectRef PKCharacterAssembly_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);
