//
//  PKJSAssemblerAdapter.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/10/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSAssemblerAdapter.h"
#import "PKJSTokenAssembly.h"
#import "PKJSCharacterAssembly.h"
#import "PKJSUtils.h"
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKCharacterAssembly.h>

@implementation PKJSAssemblerAdapter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)dealloc {
    [self setAssemblerFunction:NULL fromContext:NULL];
    [super dealloc];
}


- (void)didMatch:(PKAssembly *)a {
    JSValueRef arg = NULL;
    if ([a isMemberOfClass:[PKTokenAssembly class]]) {
        arg = (JSValueRef)PKTokenAssembly_new(ctx, a);
    } else if ([a isMemberOfClass:[PKCharacterAssembly class]]) {
        arg = (JSValueRef)PKCharacterAssembly_new(ctx, a);
    } else {
        NSAssert(0, @"Should not reach here.");
    }
    
    JSValueRef argv[] = { arg };
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSValueRef ex = NULL;
    JSObjectCallAsFunction(ctx, assemblerFunction, globalObj, 1, argv, &ex);
    if (ex) {
        NSString *s = PKJSValueGetNSString(ctx, ex, NULL);
        [NSException raise:@"PKJSException" format:s arguments:NULL];
    }
}


- (JSObjectRef)assemblerFunction {
    return assemblerFunction;
}


- (void)setAssemblerFunction:(JSObjectRef)f fromContext:(JSContextRef)c {
    if (assemblerFunction != f) {
        if (ctx && assemblerFunction) {
            JSValueUnprotect(ctx, assemblerFunction);
            JSGarbageCollect(ctx);
        }
        
        ctx = c;
        assemblerFunction = f;
        if (ctx && assemblerFunction) {
            JSValueProtect(ctx, assemblerFunction);
        }
    }
}

@end
