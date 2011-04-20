//
//  PKJSTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKTerminal_new(JSContextRef ctx, void *data);
JSClassRef PKTerminal_class(JSContextRef ctx);
