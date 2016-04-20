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
#import "GRMustacheBuffer_private.h"
#import "GRMustacheContentType.h"

@class GRMustacheContext;

/**
 * The protocol for "template components".
 * 
 * When parsing a Mustache template, GRMustacheCompiler builds an abstract
 * tree of objects representing raw text and various mustache tags.
 * 
 * This abstract tree is made of objects conforming to the
 * GRMustacheTemplateComponent.
 * 
 * Their responsability is to render, provided with a Mustache rendering
 * context, through their `renderWithContext:inBuffer:error:`
 * implementation.
 * 
 * For example, the template string "hello {{name}}!" would give four template
 * components:
 *
 * - a GRMustacheTextComponent that renders "hello ".
 * - a GRMustacheVariableTag that renders the value of the `name` key in the
 *   rendering context.
 * - a GRMustacheTextComponent that renders "!".
 * - a GRMustacheTemplate that would contain the three previous components, and
 *   render the concatenation of their renderings.
 * 
 * Template components are able to override other template components, in the
 * context of Mustache template inheritance. This feature is backed on the
 * `resolveTemplateComponent:` method.
 *
 * @see GRMustacheCompiler
 * @see GRMustacheContext
 */
@protocol GRMustacheTemplateComponent<NSObject>
@required

/**
 * Appends the rendering of the receiver to a buffer.
 * 
 * @param requiredContentType  The required content type of the rendering
 * @param buffer               A buffer
 * @param context              A rendering context
 * @param error                If there is an error performing the rendering,
 *                             upon return contains an NSError object that
 *                             describes the problem.
 *
 * @return YES if the receiver could append its rendering to the buffer.
 *
 * @see GRMustacheContext
 */
- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error GRMUSTACHE_API_INTERNAL;

/**
 * In the context of template inheritance, return the component that should be
 * rendered in lieu of _component_, should _component_ be overriden by another
 * component.
 *
 * All classes conforming to the GRMustacheTemplateComponent protocol return
 * _component_, but GRMustacheInheritableSectionTag and
 * GRMustacheInheritablePartial.
 *
 * @param component  A template component
 *
 * @return The resolution of the component in the context of Mustache
 *         template inheritance.
 *
 * @see GRMustacheSectionTag
 * @see GRMustacheTemplate
 * @see GRMustacheInheritablePartial
 */
- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component GRMUSTACHE_API_INTERNAL;
@end
