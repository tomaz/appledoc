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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheTemplateComponent_private.h"
#import "GRMustacheTag_private.h"

/**
 * A GRMustacheSectionTag is a template component that renders sections
 * such as `{{#name}}...{{/name}}`.
 *
 * @see GRMustacheTemplateComponent
 */
@interface GRMustacheSectionTag: GRMustacheTag<GRMustacheTemplateComponent> {
@private
    NSString *_templateString;
    NSRange _innerRange;
    NSArray *_components;
}

// Documented in GRMustacheSectionTag.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;


/**
 * Builds a GRMustacheSectionTag.
 * 
 * The rendering of Mustache sections depend on the value they are attached to.
 * The value is fetched by evaluating the _expression_ parameter against a
 * rendering context.
 *
 * The _components_ array contains the GRMustacheTemplateComponent objects
 * that make the section (texts, variables, other sections, etc.)
 * 
 * @param type            The type of the section.
 * @param expression      The expression that would evaluate against a
 *                        rendering context.
 * @param contentType     The content type of the tag rendering.
 * @param templateString  A Mustache template string.
 * @param innerRange      The range of the inner template string of the section
 *                        in _templateString_.
 * @param components      An array of GRMustacheTemplateComponent that make the
 *                        section.
 *
 * @return A GRMustacheSectionTag
 * 
 * @see GRMustacheExpression
 * @see GRMustacheContext
 * @see GRMustacheContext
 */
+ (instancetype)sectionTagWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange components:(NSArray *)components GRMUSTACHE_API_INTERNAL;

@end
