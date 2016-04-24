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
#import "GRMustacheTemplateComponent_private.h"
#import "GRMustacheContentType.h"

@class GRMustacheExpression;
@class GRMustacheContext;
@class GRMustacheTemplateRepository;

// Documented in GRMustacheTag.h
typedef NS_ENUM(NSUInteger, GRMustacheTagType) {
    GRMustacheTagTypeVariable = 1 << 1 GRMUSTACHE_API_PUBLIC,
    GRMustacheTagTypeSection = 1 << 2 GRMUSTACHE_API_PUBLIC,
    GRMustacheTagTypeInvertedSection = 1 << 3 GRMUSTACHE_API_PUBLIC,
} GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@interface GRMustacheTag: NSObject<GRMustacheTemplateComponent> {
@public
    GRMustacheTagType _type;
    GRMustacheExpression *_expression;
    GRMustacheContentType _contentType;
}

// Abstract method whose default implementation raises an exception.
// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTagType type GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTag.h
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

/**
 * Returns the content type of the receiver.
 *
 * For example:
 *
 * - `{{name}}`: GRMustacheContentTypeHTML
 * - `{{{name}}}`: GRMustacheContentTypeHTML.
 * - `{{#name}}...{{/name}}`: GRMustacheContentTypeHTML.
 * - `{{%CONTENT_TYPE:TEXT}}{{name}}`: GRMustacheContentTypeText.
 * - `{{%CONTENT_TYPE:TEXT}}{{{name}}}`: GRMustacheContentTypeText
 * - `{{%CONTENT_TYPE:TEXT}}{{#name}}...{{/name}}`: GRMustacheContentTypeText.
 *
 * @see escapesHTML
 */
@property (nonatomic, readonly) GRMustacheContentType contentType GRMUSTACHE_API_INTERNAL;

/**
 * Returns YES if the received HTML-escapes its HTML-unsafe input.
 *
 * This property is used is and only if contentType is GRMustacheContentTypeHTML.
 *
 * For example:
 *
 * - `{{name}}`: the variable tag escapes HTML-unsafe input.
 * - `{{{name}}}`: the variable tag does not escape input.
 * - `{{#name}}...{{/name}}`: the section tag escapes HTML-unsafe input.
 * - `{{%CONTENT_TYPE:TEXT}}{{name}}`: the escapesHTML property is ignored.
 * - `{{%CONTENT_TYPE:TEXT}}{{{name}}}`: the escapesHTML property is ignored.
 * - `{{%CONTENT_TYPE:TEXT}}{{#name}}...{{/name}}`: the escapesHTML property is ignored.
 *
 * @see contentType
 */
@property (nonatomic, readonly) BOOL escapesHTML GRMUSTACHE_API_INTERNAL;

/**
 * The expression evaluated and rendered by the tag.
 *
 * For example:
 *
 * - `{{name}}` holds the `name` expression.
 * - `{{uppercase(person.name)}}` holds the `uppercase(person.name)` expression.
 */
@property (nonatomic, retain, readonly) GRMustacheExpression *expression GRMUSTACHE_API_INTERNAL;

/**
 * Returns a new GRMustacheTag.
 *
 * @param type         The tag type
 * @param expression   The expression to be evaluated when rendering the tag.
 * @param contentType  The content type of the tag rendering.
 */
- (id)initWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheTag.h
- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error GRMUSTACHE_API_PUBLIC;

@end
