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
 * A GRMustacheVariableTag is a template component that renders variable
 * tags such as `{{name}}` and `{{{name}}}`.
 *
 * For example, the template string "{{name}} is {{age}} years old." would give
 * two GRMustacheVariableTag instances:
 *
 * - a GRMustacheVariableTag that renders the `name` key in a context.
 * - a GRMustacheVariableTag that renders the `age` key in a context.
 *
 * @see GRMustacheTemplateComponent
 */
@interface GRMustacheVariableTag: GRMustacheTag<GRMustacheTemplateComponent> {
@private
    BOOL _escapesHTML;
}

/**
 * Builds and returns a GRMustacheVariableTag.
 *
 * @param expression   The expression that would evaluate against a rendering
 *                     contex.
 * @param contentType  The content type of the tag rendering.
 * @param escapesHTML  YES if the value should be escaped.
 *
 * @return a GRMustacheVariableTag
 *
 * @see GRMustacheExpression
 */
+ (instancetype)variableTagWithExpression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType escapesHTML:(BOOL)escapesHTML GRMUSTACHE_API_INTERNAL;

@end
