// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if (TARGET_OS_IPHONE)
// http://iphonedevelopment.blogspot.com/2008/10/device-vs-simulator.html
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-runtime.h>
#endif

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


static NSInteger BOOLPropertyType = NSNotFound;

@interface GRMustacheProperty: NSObject
@property BOOL BOOLProperty;
+ (BOOL)class:(Class)class hasBOOLPropertyNamed:(NSString *)propertyName;
@end

@implementation GRMustacheProperty
@dynamic BOOLProperty;

+ (NSInteger)typeForPropertyNamed:(NSString *)propertyName ofClass:(Class)class {
	objc_property_t property = class_getProperty(class, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
	if (property != NULL) {
		const char *attributesCString = property_getAttributes(property);
		while (attributesCString) {
			if (attributesCString[0] == 'T') {
				return attributesCString[1];
			}
			attributesCString = strchr(attributesCString, ',');
			if (attributesCString) {
				attributesCString++;
			}
		}
	}
	return NSNotFound;
}

+ (BOOL)class:(Class)class hasBOOLPropertyNamed:(NSString *)propertyName {
	static NSMutableDictionary *classes = nil;
	
	if (classes == nil) {
		classes = [[NSMutableDictionary dictionaryWithCapacity:12] retain];
	}
	
	NSMutableDictionary *propertyNames = [classes objectForKey:class];
	if (propertyNames == nil) {
		propertyNames = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
		[classes setObject:propertyNames forKey:class];
	}
	
	NSNumber *boolNumber = [propertyNames objectForKey:propertyName];
	if (boolNumber == nil) {
		if (BOOLPropertyType == NSNotFound) {
			BOOLPropertyType = [self typeForPropertyNamed:@"BOOLProperty" ofClass:self];
		}
		BOOL booleanProperty = ([self typeForPropertyNamed:propertyName ofClass:class] == BOOLPropertyType);
		[propertyNames setObject:[NSNumber numberWithBool:booleanProperty] forKey:propertyName];
		return booleanProperty;
	}
	
	return [boolNumber boolValue];

}

@end


@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(BOOL *)outBool;
- (id)valueForKeyComponent:(NSString *)key foundInContext:(GRMustacheContext **)outContext;
@end


@implementation GRMustacheContext
@synthesize object;
@synthesize parent;

+ (id)contextWithObject:(id)object {
	return [self contextWithObject:object parent:nil];
}

+ (id)contextWithObject:(id)object parent:(GRMustacheContext *)parent {
	return [[[self alloc] initWithObject:object parent:parent] autorelease];
}

- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent {
	if (self = [self init]) {
		object = [theObject retain];
		parent = [theParent retain];
	}
	return self;
}

- (id)valueForKey:(NSString *)key {
	GRMustacheContext *context = self;
	NSArray *components = [key componentsSeparatedByString:@"/"];
	for (NSString *component in components) {
		if (component.length == 0) {
			continue;
		}
		if ([component isEqualToString:@"."]) {
			continue;
		}
		if ([component isEqualToString:@".."]) {
			if (parent == nil) {
				// went too far
				return nil;
			}
			context = parent;
			continue;
		}
		GRMustacheContext *valueContext = nil;
		id value = [context valueForKeyComponent:component foundInContext:&valueContext];
		if (value == nil) {
			return nil;
		}
		context = [GRMustacheContext contextWithObject:value parent:valueContext];
	}
	return context.object;
}

- (void)dealloc {
	[object release];
	[parent release];
	[super dealloc];
}

- (id)valueForKeyComponent:(NSString *)key foundInContext:(GRMustacheContext **)outContext {
	id value = nil;
	@try {
		value = [object valueForKey:key];
	}
	@catch (NSException *exception) {
		if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
			[[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
			![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
		{
			// that's some exception we are not related to
			@throw;
		}
	}
	
	if (value != nil) {
		if (outContext != NULL) {
			*outContext = self;
		}
		BOOL boolValue;
		if ([self shouldConsiderObjectValue:value forKey:key asBoolean:&boolValue]) {
			if (boolValue) {
				return [GRYes yes];
			} else {
				return [GRNo no];
			}
		}
		return value;
	}
	
	if (parent == nil) {
		return nil;
	}
	
	return [parent valueForKeyComponent:key foundInContext:outContext];
}

- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(BOOL *)outBool {
	// C99 bool type
	if (CFBooleanGetTypeID() == CFGetTypeID(value)) {
		if (outBool) {
			*outBool = CFBooleanGetValue((CFBooleanRef)value);
		}
		return YES;
	}
	
	if (![GRMustache strictBooleanMode] && [GRMustacheProperty class:[object class] hasBOOLPropertyNamed:key]) {
		if (outBool) {
			*outBool = [(NSNumber *)value boolValue];
		}
		return YES;
	}
	
	return NO;
}

@end
