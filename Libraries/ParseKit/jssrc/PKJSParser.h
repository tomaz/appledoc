//
//  PKJSParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/10/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKParser_new(JSContextRef ctx, void *data);
JSClassRef PKParser_class(JSContextRef ctx);
