//
//  PKJSUtils.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKJSUtils.h"

JSValueRef PKCFTypeToJSValue(JSContextRef ctx, CFTypeRef value, JSValueRef *ex) {
    JSValueRef result = NULL;
    CFTypeID typeID = CFGetTypeID(value);

    if (CFNumberGetTypeID() == typeID) {
        double d;
        CFNumberGetValue(value, kCFNumberDoubleType, &d);
        result = JSValueMakeNumber(ctx, d);
    } else if (CFBooleanGetTypeID() == typeID) {
        Boolean b = CFBooleanGetValue(value);
        result = JSValueMakeBoolean(ctx, b);
    } else if (CFStringGetTypeID() == typeID) {
        result = PKCFStringToJSValue(ctx, value, ex);
    } else if (CFArrayGetTypeID() == typeID) {
        result = PKCFArrayToJSObject(ctx, value, ex);
    } else if (CFDictionaryGetTypeID() == typeID) {
        result = PKCFDictionaryToJSObject(ctx, value, ex);
    } else {
        result = JSValueMakeNull(ctx);
    }
    
    return result;
}

JSValueRef PKCFStringToJSValue(JSContextRef ctx, CFStringRef cfStr, JSValueRef *ex) {
    JSStringRef str = JSStringCreateWithCFString(cfStr);
    JSValueRef result = JSValueMakeString(ctx, str);
    JSStringRelease(str);
    return result;
}

JSValueRef PKNSStringToJSValue(JSContextRef ctx, NSString *nsStr, JSValueRef *ex) {
    return PKCFStringToJSValue(ctx, (CFStringRef)nsStr, ex);
}

JSObjectRef PKCFArrayToJSObject(JSContextRef ctx, CFArrayRef cfArray, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Array");
    JSObjectRef arrayConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, NULL);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, arrayConstr, 0, NULL, NULL);

    CFIndex len = 0;
    if (NULL != cfArray) {
        len = CFArrayGetCount(cfArray);
    }
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        CFTypeRef value = CFArrayGetValueAtIndex(cfArray, i);
        JSValueRef propVal = PKCFTypeToJSValue(ctx, value, ex);
        JSObjectSetPropertyAtIndex(ctx, obj, i, propVal, NULL);
    }
    
    return obj;
}

JSObjectRef PKNSArrayToJSObject(JSContextRef ctx, NSArray *nsArray, JSValueRef *ex) {
    return PKCFArrayToJSObject(ctx, (CFArrayRef)nsArray, ex);
}

JSObjectRef PKCFDictionaryToJSObject(JSContextRef ctx, CFDictionaryRef cfDict, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Object");
    JSObjectRef objConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, NULL);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, objConstr, 0, NULL, NULL);
    
    if (NULL != cfDict) {
        CFIndex len = CFDictionaryGetCount(cfDict);
        CFStringRef keys[len];
        CFTypeRef values[len];
        CFDictionaryGetKeysAndValues(cfDict, (const void**)keys, (const void**)values);
        
        CFIndex i = 0;
        for ( ; i < len; i++) {
            CFStringRef key = keys[i];
            CFTypeRef value = values[i];
            
            JSStringRef propName = JSStringCreateWithCFString(key);
            JSValueRef propVal = PKCFTypeToJSValue(ctx, value, ex);
            JSObjectSetProperty(ctx, obj, propName, propVal, kJSPropertyAttributeNone, NULL);
            JSStringRelease(propName);
        }
    }
    
    return obj;
}

JSObjectRef PKNSDictionaryToJSObject(JSContextRef ctx, NSDictionary *nsDict, JSValueRef *ex) {
    return PKCFDictionaryToJSObject(ctx, (CFDictionaryRef)nsDict, ex);
}

CFTypeRef PKJSValueCopyCFType(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    CFTypeRef result = NULL;
    
    if (JSValueIsBoolean(ctx, value)) {
        Boolean b = JSValueToBoolean(ctx, value);
        result = (b ? kCFBooleanTrue : kCFBooleanFalse);
    } else if (JSValueIsNull(ctx, value)) {
        result = NULL;
    } else if (JSValueIsNumber(ctx, value)) {
        CGFloat d = JSValueToNumber(ctx, value, NULL);
        result = CFNumberCreate(NULL, kCFNumberCGFloatType, &d);
    } else if (JSValueIsString(ctx, value)) {
        result = PKJSValueCopyCFString(ctx, value, ex);
    } else if (JSValueIsObject(ctx, value)) {
        if (PKJSValueIsInstanceOfClass(ctx, value, "Array", NULL)) {
            result = PKJSObjectCopyCFArray(ctx, (JSObjectRef)value, ex);
        } else {
            result = PKJSObjectCopyCFDictionary(ctx, (JSObjectRef)value, ex);
        }
    }
    
    return result;
}

id PKJSValueGetId(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    return [(id)PKJSValueCopyCFType(ctx, value, ex) autorelease];
}

CFStringRef PKJSValueCopyCFString(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    JSStringRef str = JSValueToStringCopy(ctx, value, ex);
    CFStringRef result = JSStringCopyCFString(NULL, str);
    JSStringRelease(str);
    return result;
}

NSString *PKJSValueGetNSString(JSContextRef ctx, JSValueRef value, JSValueRef *ex) {
    return [(id)PKJSValueCopyCFString(ctx, value, ex) autorelease];
}

CFArrayRef PKJSObjectCopyCFArray(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex) {
    JSStringRef propName = JSStringCreateWithUTF8CString("length");
    JSValueRef propVal = JSObjectGetProperty(ctx, obj, propName, NULL);
    JSStringRelease(propName);
    CFIndex len = (CFIndex)JSValueToNumber(ctx, propVal, NULL);
    
    CFMutableArrayRef cfArray = CFArrayCreateMutable(NULL, len, NULL);
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        JSValueRef val = JSObjectGetPropertyAtIndex(ctx, obj, i, NULL);
        CFTypeRef cfType = PKJSValueCopyCFType(ctx, val, ex);
        CFArraySetValueAtIndex(cfArray, i, cfType);
        
        CFRelease(cfType);
    }
    
    CFArrayRef result = CFArrayCreateCopy(NULL, cfArray);
    CFRelease(cfArray);
    
    return result;
}

CFDictionaryRef PKJSObjectCopyCFDictionary(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex) {
    JSPropertyNameArrayRef propNames = JSObjectCopyPropertyNames(ctx, obj);
    CFIndex len = JSPropertyNameArrayGetCount(propNames);
    
    CFMutableDictionaryRef cfDict = CFDictionaryCreateMutable(NULL, len, NULL, NULL);
    
    CFIndex i = 0;
    for ( ; i < len; i++) {
        JSStringRef propName = JSPropertyNameArrayGetNameAtIndex(propNames, i);
        JSValueRef val = JSObjectGetProperty(ctx, obj, propName, NULL);
        CFTypeRef cfType = PKJSValueCopyCFType(ctx, val, ex);
        
        CFStringRef key = JSStringCopyCFString(NULL, propName);
        CFDictionarySetValue(cfDict, (const void *)key, (const void *)cfType);

        CFRelease(key);
        CFRelease(cfType);
    }
    
    JSPropertyNameArrayRelease(propNames);
    CFDictionaryRef result = CFDictionaryCreateCopy(NULL, cfDict);
    CFRelease(cfDict);
    
    return result;
}

JSObjectRef PKNSErrorToJSObject(JSContextRef ctx, NSError *nsErr, JSValueRef *ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef className = JSStringCreateWithUTF8CString("Error");
    JSObjectRef errConstr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, className, ex);
    JSStringRelease(className);
    
    JSObjectRef obj = (JSObjectRef)JSObjectCallAsConstructor(ctx, errConstr, 0, NULL, ex);
    
    if (nsErr) {
        JSStringRef nameStr = JSStringCreateWithUTF8CString("ParseKitError");
        JSValueRef name = JSValueMakeString(ctx, nameStr);
        JSStringRelease(nameStr);
        
        JSStringRef msgStr = JSStringCreateWithCFString((CFStringRef)[nsErr localizedDescription]);
        JSValueRef msg = JSValueMakeString(ctx, msgStr);
        JSStringRelease(msgStr);
        
        JSValueRef code = JSValueMakeNumber(ctx, [nsErr code]);
        
        JSStringRef propName = JSStringCreateWithUTF8CString("name");
        JSObjectSetProperty(ctx, obj, propName, name, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
        
        propName = JSStringCreateWithUTF8CString("message");
        JSObjectSetProperty(ctx, obj, propName, msg, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
        
        propName = JSStringCreateWithUTF8CString("code");
        JSObjectSetProperty(ctx, obj, propName, code, kJSPropertyAttributeReadOnly|kJSPropertyAttributeDontDelete, ex);
        JSStringRelease(propName);
    }
    
    return obj;
}

bool PKJSValueIsInstanceOfClass(JSContextRef ctx, JSValueRef value, char *className, JSValueRef* ex) {
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSStringRef classNameStr = JSStringCreateWithUTF8CString(className);
    JSObjectRef constr = (JSObjectRef)JSObjectGetProperty(ctx, globalObj, classNameStr, ex);
    JSStringRelease(classNameStr);
    
    return JSValueIsInstanceOfConstructor(ctx, value, constr, NULL);
}
