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

#import <Foundation/Foundation.h>
#import "GRMustacheTemplateLoader.h"


/**
 Class extension exposed to the subclasses of GRMustacheTemplateLoader.
 
 @since v1.0.0
 */
@interface GRMustacheTemplateLoader()

/**
 The extension of loaded templates (if applicable).
 
 This property is never nil, but may contain an empty NSString.
 
 @see GRMustacheTemplateLoader#initWithExtension:encoding:
 @since v1.0.0
 */
@property (nonatomic, readonly, retain) NSString *extension;

/**
 The encoding of data containing templates (if applicable)
 
 @see GRMustacheTemplateLoader#initWithExtension:encoding:
 @since v1.0.0
 */
@property (nonatomic, readonly) NSStringEncoding encoding;

/**
 The designated GRMustacheTemplateLoader initializer.
 
 Don't use this method unless you implement a GRMustacheTemplateLoader subclass.
 
 @returns a GRMustacheTemplateLoader instance.
 @param ext The file name extension of loaded templates.
 @param encoding The encoding of data containing templates.
 
 The returned template loader will load templates with the provided file
 name extension, and interpret any template data with the provided encoding.
 
 If the ext parameter is nil, the "mustache" extension will be assumed.
 
 If the ext parameter is the empty string, loaded partials won't have any extension.
 
 For initializing GRMustacheTemplateLoader subclasses which ignore extensions or
 encoding, you may pass any value in those parameters.
 
 @see GRMustacheTemplateLoader#templateStringForTemplateId:error:
 @since v1.0.0
 */
- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;

/**
 Don't use this method.
 
 Subclasses must override it.
 
 @returns a template identifier
 @param name The name of a partial or a template
 @param baseTemplateId The identifier of the template refering to the name
 
 Your subclass will return a template identifier, that is to say an object which
 uniquely identifies a template. There must not be two identifiers for a single
 template.
 
 If the baseTemplateId parameter is nil, then the name parameter refers to a
 "root template". Otherwise, the name parameter refers to the name of a partial
 loaded from the template identified by baseTemplateId.
 
 @since v1.0.0
*/
- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId;

/**
 Don't use this method.
 
 Subclasses must override it.
 
 @returns A template string
 @param templateId A template identifier
 @param outError If there is an error building the template string, upon return
 contains an NSError object that describes the problem.
 
 Your subclass will return the string of the template identified by templateId.
 
 If applicable, your implementation will use the extension and encoding properties.
 
 @see GRMustacheTemplateLoader#extension
 @see GRMustacheTemplateLoader#encoding
 
 @since v1.0.0
 */
// Override this method, and return a template string.
// If applicable, it is your responsability to use the extension property in order to load the correct template.
- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError;
@end
