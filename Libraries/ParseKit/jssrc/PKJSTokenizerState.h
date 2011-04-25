//
//  PKJSTokenizerState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKTokenizerState_new(JSContextRef ctx, void *data);
JSClassRef PKTokenizerState_class(JSContextRef ctx);
