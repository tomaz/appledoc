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

#import "GRMustacheURLTemplateLoader_private.h"


@implementation GRMustacheURLTemplateLoader

- (id)initWithURL:(NSURL *)theURL extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	if (self = [super initWithExtension:ext encoding:encoding]) {
		url = [theURL retain];
	}
	return self;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	NSAssert([templateId isKindOfClass:[NSURL class]], nil);
	return [NSString stringWithContentsOfURL:(NSURL*)templateId
									encoding:self.encoding
									   error:outError];
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	if (baseTemplateId) {
		NSAssert([baseTemplateId isKindOfClass:[NSURL class]], nil);
		if (self.extension.length == 0) {
			return [[NSURL URLWithString:name relativeToURL:(NSURL *)baseTemplateId] URLByStandardizingPath];
		}
		return [[NSURL URLWithString:[name stringByAppendingPathExtension:self.extension] relativeToURL:(NSURL *)baseTemplateId] URLByStandardizingPath];
	}
	if (self.extension.length == 0) {
		return [[url URLByAppendingPathComponent:name] URLByStandardizingPath];
	}
	return [[[url URLByAppendingPathComponent:name] URLByAppendingPathExtension:self.extension] URLByStandardizingPath];
}

// override of a private GRMustacheTemplateLoader
- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)templateURL error:(NSError **)outError {
	GRMustacheTemplate *template = [super parseContentsOfURL:templateURL error:outError];
	if (!template) {
		return nil;
	}
	[self setTemplate:template forTemplateId:templateURL];
	return template;
}

- (void)dealloc {
	[url release];
	[super dealloc];
}

@end
