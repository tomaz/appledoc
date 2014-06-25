//
//  SynthesizeSingleton.h
//  appledoc
//
//  Created by Teichmann, Bjoern on 25.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

//
// SynthesizeSingleton.h
// Copyright 2009 Matt Gallagher. All rights reserved.
//
// Modified by Oliver Jones and Byron Salau
//
// Permission is given to use this source code file without charge in any
// project, commercial or otherwise, entirely at your risk, with the condition
// that any redistribution (in part or whole) of source code must retain
// this copyright and permission notice. Attribution in compiled projects is
// appreciated but not required.

#if __has_feature(objc_arc)
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessorname) \
+ (classname *)accessorname\
{\
static classname *accessorname = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
accessorname = [[classname alloc] init];\
});\
return accessorname;\
}
#else
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessorname) \
static classname *shared##classname = nil; \
+ (void)cleanupFromTerminate \
{ \
classname *temp = shared##classname; \
shared##classname = nil; \
[temp dealloc]; \
} \
+ (classname *)accessorname \
{ \
static dispatch_once_t p; \
dispatch_once(&p, \
^{ \
if (shared##classname == nil) \
{ \
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; \
shared##classname = [[self alloc] init]; \
[pool drain]; \
} \
}); \
return shared##classname; \
} \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t p; \
__block classname* temp = nil; \
dispatch_once(&p, \
^{ \
if (shared##classname == nil) \
{ \
temp = shared##classname = [super allocWithZone:zone]; \
} \
}); \
return temp; \
} \
- (id)copyWithZone:(NSZone *)zone { return self; } \
- (id)retain { return self; } \
- (NSUInteger)retainCount { return NSUIntegerMax; } \
- (oneway void)release { } \
- (id)autorelease { return self; }
#endif
