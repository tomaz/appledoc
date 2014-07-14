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

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheSectionElement_private.h"


@interface GRMustacheSectionElement()
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *templateString;
@property (nonatomic) BOOL inverted;
@property (nonatomic, retain) NSArray *elems;
- (id)initWithName:(NSString *)name string:(NSString *)templateString inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateString;
@synthesize name;
@synthesize inverted;
@synthesize elems;

+ (id)sectionElementWithName:(NSString *)name string:(NSString *)templateString inverted:(BOOL)inverted elements:(NSArray *)elems {
	return [[[self alloc] initWithName:name string:templateString inverted:inverted elements:elems] autorelease];
}

- (id)initWithName:(NSString *)theName string:(NSString *)theTemplateString inverted:(BOOL)theInverted elements:(NSArray *)theElems {
	if ((self = [self init])) {
		self.name = theName;
		self.templateString = theTemplateString;
		self.inverted = theInverted;
		self.elems = theElems;
	}
	return self;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	NSMutableString *buffer= [NSMutableString stringWithCapacity:1024];
	
	switch([GRMustache objectKind:value]) {
		case GRMustacheObjectKindFalseValue:
			if (inverted) {
				for (NSObject<GRMustacheElement> *elem in elems) {
					[buffer appendString:[elem renderContext:context]];
				}
			}
			break;
			
		case GRMustacheObjectKindTrueValue:
			if (!inverted) {
				GRMustacheContext *innerContext = [GRMustacheContext contextWithObject:value parent:context];
				for (NSObject<GRMustacheElement> *elem in elems) {
					[buffer appendString:[elem renderContext:innerContext]];
				}
			}
			break;
			
		case GRMustacheObjectKindEnumerable:
			if (inverted) {
				BOOL empty = YES;
				for (id object in value) {
					empty = NO;
					break;
				}
				if (empty) {
					for (NSObject<GRMustacheElement> *elem in elems) {
						[buffer appendString:[elem renderContext:context]];
					}
				}
			} else {
				for (id object in value) {
					GRMustacheContext *innerContext = [GRMustacheContext contextWithObject:object parent:context];
					for (NSObject<GRMustacheElement> *elem in elems) {
						[buffer appendString:[elem renderContext:innerContext]];
					}
				}
			}
			break;
			
		case GRMustacheObjectKindLambda:
			if (!inverted) {
				GRMustacheRenderer renderer = ^(id object){
					GRMustacheContext *renderedContext;
					if ([object isKindOfClass:[GRMustacheContext class]]) {
						renderedContext = object;
					} else {
						renderedContext = [GRMustacheContext contextWithObject:object parent:context];
					}
					NSMutableString *result = [NSMutableString stringWithCapacity:1024];
					for (NSObject<GRMustacheElement> *elem in elems) {
						[result appendString:[elem renderContext:renderedContext]];
					}
					return (NSString *)result;
				};
				[buffer appendString:[(GRMustacheLambdaBlockWrapper *)value renderObject:context
																			  fromString:templateString
																				renderer:renderer]];
			}
			break;
			
		default:
			// should not be here
			NSAssert(NO, nil);
	}
	
	return buffer;
}

- (void)dealloc {
	[name release];
	[templateString release];
	[elems release];
	[super dealloc];
}


@end
