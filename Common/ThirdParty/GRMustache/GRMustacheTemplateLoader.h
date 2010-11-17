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


@class GRMustacheTemplate;

/**
 The GRMustacheTemplateLoader provides with template loading services.
 
 @since v1.0.0
 */
@interface GRMustacheTemplateLoader: NSObject {
@private
	NSString *extension;
	NSStringEncoding encoding;
	NSMutableDictionary *templatesById;
}

/**
 @returns A GRMustacheTemplateLoader instance
 @param url The url of a directory
 
 The returned template loader will load templates and partials from the provided directory url,
 with extension "mustache", encoded in UTF8.

 @since v1.0.0
*/
+ (id)templateLoaderWithBaseURL:(NSURL *)url;

/**
 @returns A GRMustacheTemplateLoader instance
 @param url The url of a directory
 @param ext The file name extension of loaded templates.
 
 The returned template loader will load templates and partials from the provided directory url,
 with provided extension, encoded in UTF8.
 
 If the ext parameter is nil, the "mustache" extension will be assumed.
 
 If the ext parameter is the empty string, loaded partials won't have any extension.

 @since v1.0.0
*/
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext;

/**
 @returns A GRMustacheTemplateLoader instance
 @param url The url of a directory
 @param ext The file name extension of loaded templates.
 @param encoding The encoding of template files.
 
 The returned template loader will load templates and partials from the provided directory url,
 with provided extension, encoded in provided encoding.
 
 If the ext parameter is nil, the "mustache" extension will be assumed.
 
 If the ext parameter is the empty string, loaded partials won't have any extension.

 @since v1.0.0
*/
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding;

/**
 @returns A GRMustacheTemplateLoader instance
 @param bundle A bundle
 
 The returned template loader will load templates and partials from the provided bundle,
 with extension "mustache", encoded in UTF8.

 @since v1.0.0
*/
+ (id)templateLoaderWithBundle:(NSBundle *)bundle;

/**
 @returns A GRMustacheTemplateLoader instance
 @param bundle A bundle
 @param ext The extension of loaded templates.
 
 The returned template loader will load templates and partials from the provided bundle,
 with provided extension, encoded in UTF8.
 
 If the ext parameter is nil, the "mustache" extension will be assumed.

 @since v1.0.0
*/
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext;

/**
 @returns A GRMustacheTemplateLoader instance
 @param bundle A bundle
 @param ext The extension of loaded templates.
 @param encoding The encoding of template resources.
 
 The returned template loader will load templates and partials from the provided bundle,
 with provided extension, encoded in the provided encoding.
 
 If the ext parameter is nil, the "mustache" extension will be assumed.

 @since v1.0.0
*/
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding;

/**
 @returns a GRMustacheTemplate instance
 @param name The name of the template
 @param outError If there is an error loading or parsing the template, upon return
 contains an NSError object that describes the problem.
 
 Loads, parses, and returns the template of provided name.
 
 @since v1.0.0
 */
- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError;

/**
 @returns a GRMustacheTemplate instance
 @param templateString The template string
 @param outError If there is an error parsing the template string or loading a partial, upon return
 contains an NSError object that describes the problem.
 
 Parses the template string, and returns a GRMustacheTemplate instance.
 
 @since v1.0.0
 */
- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError;
@end
