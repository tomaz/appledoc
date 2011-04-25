//
//  PKJSValueHolder.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValueHolder : NSObject {
    JSContextRef context;
    JSValueRef heldValue;
}
- (id)initWithContext:(JSContextRef)c heldValue:(JSValueRef)v;

@property (nonatomic) JSContextRef context;
@property (nonatomic) JSValueRef heldValue;
@end