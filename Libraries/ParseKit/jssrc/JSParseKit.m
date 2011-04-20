//
//  PKJSParseKit.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/10/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <JSParseKit/JSParseKit.h>
#import <ParseKit/PKToken.h>
#import "PKJSUtils.h"
#import "PKJSToken.h"
#import "PKJSTokenizer.h"
#import "PKJSTokenizerState.h"
#import "PKJSAssembly.h"
#import "PKJSTokenAssembly.h"
#import "PKJSCharacterAssembly.h"
#import "PKJSWordState.h"
#import "PKJSNumberState.h"
#import "PKJSWhitespaceState.h"
#import "PKJSCommentState.h"
#import "PKJSQuoteState.h"
#import "PKJSSymbolState.h"
#import "PKJSRepetition.h"
#import "PKJSSequence.h"
#import "PKJSTrack.h"
#import "PKJSAlternation.h"
#import "PKJSEmpty.h"
#import "PKJSAny.h"
#import "PKJSWord.h"
#import "PKJSNum.h"
#import "PKJSQuotedString.h"
#import "PKJSSymbol.h"
#import "PKJSComment.h"
#import "PKJSLiteral.h"
#import "PKJSCaseInsensitiveLiteral.h"
#import "PKJSUppercaseWord.h"
#import "PKJSLowercaseWord.h"

static void printValue(JSContextRef ctx, JSValueRef val) {
    NSString *s = PKJSValueGetNSString(ctx, val, NULL);
    NSLog(@"%@", s);
}

static JSValueRef print(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    printValue(ctx, argv[0]); // TODO check args
    return JSValueMakeUndefined(ctx);
}

static JSObjectRef setUpFunction(JSContextRef ctx, char *funcName, JSObjectCallAsFunctionCallback funcCallback, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef funcNameStr = JSStringCreateWithUTF8CString(funcName);
    JSObjectRef func = JSObjectMakeFunctionWithCallback(ctx, funcNameStr, funcCallback);
    JSObjectSetProperty(ctx, globalObj, funcNameStr, func, kJSPropertyAttributeNone, ex);
    JSStringRelease(funcNameStr);
    return func;
}

static JSObjectRef setUpConstructor(JSContextRef ctx, char *className, JSClassRef jsClass, JSObjectCallAsConstructorCallback constrCallback, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef classNameStr = JSStringCreateWithUTF8CString(className);
    JSObjectRef constr = JSObjectMakeConstructor(ctx, jsClass, constrCallback);
    JSObjectSetProperty(ctx, globalObj, classNameStr, constr, kJSPropertyAttributeNone, ex);
    JSStringRelease(classNameStr);
    return constr;
}

static void setUpClassProperty(JSContextRef ctx, char *propName, JSValueRef prop, JSObjectRef constr, JSValueRef *ex) {
    JSStringRef propNameStr = JSStringCreateWithUTF8CString(propName);
    JSObjectSetProperty(ctx, constr, propNameStr, prop, kJSPropertyAttributeDontDelete|kJSPropertyAttributeReadOnly, NULL);
    JSStringRelease(propNameStr);
}

void PKJSParseKitSetUpContext(JSContextRef ctx) {
    JSValueRef ex = NULL;

    setUpFunction(ctx, "print", print, &ex);
    
    // Assemblies
    setUpConstructor(ctx, "PKTokenAssembly", PKTokenAssembly_class(ctx), PKTokenAssembly_construct, &ex);
    setUpConstructor(ctx, "PKCharacterAssembly", PKCharacterAssembly_class(ctx), PKCharacterAssembly_construct, &ex);
    
    // Tokenization
    JSObjectRef constr = setUpConstructor(ctx, "PKToken", PKToken_class(ctx), PKToken_construct, &ex);
    setUpClassProperty(ctx, "EOFToken", PKToken_getEOFToken(ctx), constr, &ex); // Class property on Token constructor
    
    setUpConstructor(ctx, "PKTokenizer", PKTokenizer_class(ctx), PKTokenizer_construct, &ex);
    setUpConstructor(ctx, "PKWordState", PKWordState_class(ctx), PKWordState_construct, &ex);
    setUpConstructor(ctx, "PKQuoteState", PKQuoteState_class(ctx), PKQuoteState_construct, &ex);
    setUpConstructor(ctx, "PKNumberState", PKNumberState_class(ctx), PKNumberState_construct, &ex);
    setUpConstructor(ctx, "PKSymbolState", PKSymbolState_class(ctx), PKSymbolState_construct, &ex);
    setUpConstructor(ctx, "PKCommentState", PKCommentState_class(ctx), PKCommentState_construct, &ex);
    setUpConstructor(ctx, "PKWhitespaceState", PKWhitespaceState_class(ctx), PKWhitespaceState_construct, &ex);

    // Parsers
    setUpConstructor(ctx, "PKRepetition", PKRepetition_class(ctx), PKRepetition_construct, &ex);

    // Collection Parsers
    setUpConstructor(ctx, "PKAlternation", PKAlternation_class(ctx), PKAlternation_construct, &ex);
    setUpConstructor(ctx, "PKSequence", PKSequence_class(ctx), PKSequence_construct, &ex);
    
    // Terminal Parsers
    setUpConstructor(ctx, "PKEmpty", PKEmpty_class(ctx), PKEmpty_construct, &ex);
    setUpConstructor(ctx, "PKAny", PKAny_class(ctx), PKAny_construct, &ex);
    
    // Token Terminals
    setUpConstructor(ctx, "PKWord", PKWord_class(ctx), PKWord_construct, &ex);
    setUpConstructor(ctx, "PKNum", PKNum_class(ctx), PKNum_construct, &ex);
    setUpConstructor(ctx, "PKQuotedString", PKQuotedString_class(ctx), PKQuotedString_construct, &ex);
    setUpConstructor(ctx, "PKSymbol", PKSymbol_class(ctx), PKSymbol_construct, &ex);
    setUpConstructor(ctx, "PKComment", PKComment_class(ctx), PKComment_construct, &ex);
    setUpConstructor(ctx, "PKLiteral", PKLiteral_class(ctx), PKLiteral_construct, &ex);
    setUpConstructor(ctx, "PKCaseInsensitiveLiteral", PKCaseInsensitiveLiteral_class(ctx), PKCaseInsensitiveLiteral_construct, &ex);
    setUpConstructor(ctx, "PKUppercaseWord", PKUppercaseWord_class(ctx), PKUppercaseWord_construct, &ex);
    setUpConstructor(ctx, "PKLowercaseWord", PKLowercaseWord_class(ctx), PKLowercaseWord_construct, &ex);
}
