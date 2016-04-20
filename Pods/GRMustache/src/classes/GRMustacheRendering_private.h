// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheContentType.h"

// prevent GRMustacheFilter.h to load
#define GRMUSTACHE_RENDERING


@class GRMustacheContext;
@class GRMustacheTag;
@class GRMustacheTemplateRepository;


// =============================================================================
#pragma mark - <GRMustacheRendering>


// Documented in GRMustacheRendering.h
@protocol GRMustacheRendering <NSObject>

// Documented in GRMustacheRendering.h
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error GRMUSTACHE_API_PUBLIC;

@end


// =============================================================================
#pragma mark - GRMustacheRendering

// Documented in GRMustacheRendering.h
@interface GRMustacheRendering : NSObject<GRMustacheRendering>

// Documented in GRMustacheRendering.h
+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheRendering.h
+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block GRMUSTACHE_API_PUBLIC;

+ (void)pushCurrentTemplateRepository:(GRMustacheTemplateRepository *)templateRepository GRMUSTACHE_API_INTERNAL;
+ (void)popCurrentTemplateRepository GRMUSTACHE_API_INTERNAL;
+ (GRMustacheTemplateRepository *)currentTemplateRepository GRMUSTACHE_API_INTERNAL;

+ (void)pushCurrentContentType:(GRMustacheContentType)contentType GRMUSTACHE_API_INTERNAL;
+ (void)popCurrentContentType GRMUSTACHE_API_INTERNAL;
+ (GRMustacheContentType)currentContentType GRMUSTACHE_API_INTERNAL;

@end

