//
//  PKJSUtils.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#define PKPreconditionInstaceOf(cls, meth)
#define PKPreconditionMethodArgc(n, meth)
#define PKPreconditionConstructorArgc(n, meth)

JSValueRef PKCFTypeToJSValue(JSContextRef ctx, CFTypeRef value, JSValueRef *ex);
JSValueRef PKCFStringToJSValue(JSContextRef ctx, CFStringRef cfStr, JSValueRef *ex);
JSValueRef PKNSStringToJSValue(JSContextRef ctx, NSString *nsStr, JSValueRef *ex);
JSObjectRef PKCFArrayToJSObject(JSContextRef ctx, CFArrayRef cfArray, JSValueRef *ex);
JSObjectRef PKNSArrayToJSObject(JSContextRef ctx, NSArray *nsArray, JSValueRef *ex);
JSObjectRef PKCFDictionaryToJSObject(JSContextRef ctx, CFDictionaryRef cfDict, JSValueRef *ex);
JSObjectRef PKNSDictionaryToJSObject(JSContextRef ctx, NSDictionary *nsDict, JSValueRef *ex);

CFTypeRef PKJSValueCopyCFType(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
id PKJSValueGetId(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
CFStringRef PKJSValueCopyCFString(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
NSString *PKJSValueGetNSString(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
CFArrayRef PKJSObjectCopyCFArray(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex);
CFDictionaryRef PKJSObjectCopyCFDictionary(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex);

JSObjectRef PKNSErrorToJSObject(JSContextRef ctx, NSError *nsErr, JSValueRef *ex);
bool PKJSValueIsInstanceOfClass(JSContextRef ctx, JSValueRef value, char *className, JSValueRef* ex);