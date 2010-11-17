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
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSectionElement_private.h"


@interface GRMustacheTemplate()
@property (nonatomic, retain) GRMustacheTemplateLoader *templateLoader;
@property (nonatomic, retain) NSString *templateString;
@property (nonatomic, retain) NSString *otag;
@property (nonatomic, retain) NSString *ctag;
@property (nonatomic) NSInteger p;
@property (nonatomic) NSInteger curline;
@property (nonatomic, retain) NSMutableArray *elems;
- (id)initWithString:(NSString *)templateString templateId:(id)templateId templateLoader:(GRMustacheTemplateLoader *)templateLoader;
- (GRMustacheSectionElement *)parseSectionWithName:(NSString *)name inverted:(BOOL)inverted startline:(NSInteger)line error:(NSError **)outError;
- (NSString *)readString:(NSString *)s eof:(BOOL *)eof;
- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description;
@end


@implementation GRMustacheTemplate
@synthesize templateId;
@synthesize templateLoader;
@synthesize templateString;
@synthesize otag;
@synthesize ctag;
@synthesize p;
@synthesize curline;
@synthesize elems;


+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError {
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError {
    GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfURL:url error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name bundle:bundle error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (id)parseString:(NSString *)templateString error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:[NSBundle mainBundle]]
			parseString:templateString
			error:outError];
}

+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBaseURL:[url URLByDeletingLastPathComponent] extension:[url pathExtension]]
			parseContentsOfURL:url
			error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle]
			parseTemplateNamed:name
			error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle extension:ext]
			parseTemplateNamed:name
			error:outError];
}

- (void)dealloc {
	[templateId release];
	[templateLoader release];
	[templateString release];
	[otag release];
	[ctag release];
	[elems release];
	[super dealloc];
}

- (NSString *)render {
	return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object {
	return [self renderContext:[GRMustacheContext contextWithObject:object]];
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	NSMutableString *buffer = [NSMutableString stringWithCapacity:templateString.length];
	for (GRMustacheElement *elem in elems) {
		[buffer appendString:[elem renderContext:context]];
	}
	return buffer;
}


+ (id)templateWithString:(NSString *)templateString templateId:(id)templateId templateLoader:(GRMustacheTemplateLoader *)templateLoader {
	return [[[self alloc] initWithString:templateString templateId:templateId templateLoader:templateLoader] autorelease];
}

- (id)initWithString:(NSString *)theTemplateString templateId:(id)theTemplateId templateLoader:(GRMustacheTemplateLoader *)theTemplateLoader {
	NSAssert(theTemplateLoader, @"Can't init GRMustacheTemplate with nil template loader");
	NSAssert(theTemplateString, @"Can't init GRMustacheTemplate with nil template string");
	if (self == [self init]) {
		self.templateId = theTemplateId;
		self.templateLoader = theTemplateLoader;
		self.templateString = theTemplateString;
		self.otag = @"{{";
		self.ctag = @"}}";
		self.p = 0;
		self.curline = 1;
		self.elems = [NSMutableArray arrayWithCapacity:4];
	}
	return self;
}

- (BOOL)parseAndReturnError:(NSError **)outError {
	BOOL eof;
	NSString *text;
	NSString *tag;
	NSString *name;
	unichar tagUnichar;
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	GRMustacheElement *element;
	NSInteger lastOTagLine;
	
	while (YES) {
		text = [self readString:otag eof:&eof];
		lastOTagLine = curline;
		
		if (eof) {
            //put the remaining text in a block
			[elems addObject:[GRMustacheTextElement textElementWithString:text]];
            return YES;
        }
		
		// put text into an item
		text = [text substringToIndex:text.length - otag.length];
		[elems addObject:[GRMustacheTextElement textElementWithString:text]];
        
		// look for close tag
        if (p < templateString.length && [[templateString substringWithRange:NSMakeRange(p, 1)] isEqualToString:@"{"]) {
			text = [self readString:[@"}" stringByAppendingString:ctag] eof:&eof];
        } else {
			text = [self readString:ctag eof:&eof];
        }
		
		if (eof) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:lastOTagLine description:[NSString stringWithFormat:@"Unmatched open tag %@", otag, nil]];
			}
			return NO;
        }
		
		//trim the close tag off the text
		tag = [[text substringToIndex:text.length - ctag.length] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if (tag.length == 0) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Empty tag %@%@", otag, ctag, nil]];
			}
			return NO;
        }
		
		NSRange ctagRange = [tag rangeOfString:otag];
		if (ctagRange.location != NSNotFound) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:lastOTagLine description:[NSString stringWithFormat:@"Unmatched open tag %@", otag, nil]];
			}
			return NO;
		}
		
		tagUnichar = [tag characterAtIndex:0];
		
		switch (tagUnichar) {
			case '!':
				// ignore comment
				break;
				
			case '#':
			case '^':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				element = [self parseSectionWithName:name
											inverted:(tagUnichar == '^')
										   startline:curline
											   error:outError];
				if (!element) {
					return NO;
				}
				[elems addObject:element];
				break;
				
			case '/':
				if (outError != NULL) {
					name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
					*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Unmatched section closing tag %@/%@%@", otag, name, ctag, nil]];
				}
				return NO;
				break;
				
			case '>':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				element = [templateLoader parseTemplateNamed:name relativeToTemplate:self error:outError];
				if (!element) {
					return NO;
				}
				[elems addObject:element];
				break;
				
			case '=':
				if ([tag characterAtIndex:tag.length-1] != '=') {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid meta tag %@%@%@", otag, tag, ctag, nil]];
					}
					return NO;
				}
				tag = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				NSArray *newTags = [tag componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
				NSIndexSet *indexes = [newTags indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
					return (BOOL)(((NSString*)obj).length > 0);
				}];
				
				if (indexes.count == 2) {
					NSUInteger index1 = [indexes firstIndex];
					NSUInteger index2 = [indexes lastIndex];
					if (index1 < index2) {
						self.otag = [newTags objectAtIndex:index1];
						self.ctag = [newTags objectAtIndex:index2];
					} else {
						self.otag = [newTags objectAtIndex:index2];
						self.ctag = [newTags objectAtIndex:index1];
					}
				} else {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid meta tag %@=%@=%@", otag, tag, ctag, nil]];
					}
					return NO;
				}
				break;
				
			case '{':
				if ([tag characterAtIndex:tag.length-1] == '}') {
					name = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
					[elems addObject:[GRMustacheVariableElement variableElementWithName:name raw:YES]];
				} else {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid unescaped tag %@%@%@", otag, tag, ctag, nil]];
					}
					return NO;
				}
				break;
				
			case '&':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				[elems addObject:[GRMustacheVariableElement variableElementWithName:name raw:YES]];
				break;
				
			default:
				[elems addObject:[GRMustacheVariableElement variableElementWithName:tag raw:NO]];
				break;
		}
		
	};
	
	return YES;
}
- (GRMustacheSectionElement *)parseSectionWithName:(NSString *)sectionName inverted:(BOOL)inverted startline:(NSInteger)startline error:(NSError **)outError {
	BOOL eof;
	NSString *text;
	NSString *tag;
	NSString *name;
	unichar tagUnichar;
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	GRMustacheElement *element;
	NSMutableArray *sectionElems = [NSMutableArray arrayWithCapacity:4];
	NSInteger sectionStart = p;
	NSInteger lastOTagStart;
	NSInteger lastOTagLine;
	
	while (YES) {
		text = [self readString:otag eof:&eof];
		lastOTagStart = p - otag.length;
		lastOTagLine = curline;
		
		if (eof) {
			if (outError != NULL) {
				if (inverted) {
					*outError = [self parseErrorAtLine:startline description:[NSString stringWithFormat:@"Unmatched section opening tag %@^%@%@", otag, sectionName, ctag, nil]];
				} else {
					*outError = [self parseErrorAtLine:startline description:[NSString stringWithFormat:@"Unmatched section opening tag %@#%@%@", otag, sectionName, ctag, nil]];
				}
			}
			return nil;
		}
		
		// put text into an item
		text = [text substringToIndex:text.length - otag.length];
		[sectionElems addObject:[GRMustacheTextElement textElementWithString:text]];
        
		// look for close tag
        if (p < templateString.length && [[templateString substringWithRange:NSMakeRange(p, 1)] isEqualToString:@"{"]) {
			text = [self readString:[@"}" stringByAppendingString:ctag] eof:&eof];
        } else {
			text = [self readString:ctag eof:&eof];
        }
		
		if (eof) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:lastOTagLine description:[NSString stringWithFormat:@"Unmatched open tag %@", otag, nil]];
			}
			return nil;
        }
		
		//trim the close tag off the text
		tag = [[text substringToIndex:text.length - ctag.length] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if (tag.length == 0) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Empty tag %@%@", otag, ctag, nil]];
			}
			return NO;
        }
		
		NSRange ctagRange = [tag rangeOfString:otag];
		if (ctagRange.location != NSNotFound) {
			if (outError != NULL) {
				*outError = [self parseErrorAtLine:lastOTagLine description:[NSString stringWithFormat:@"Unmatched open tag %@", otag, nil]];
			}
			return NO;
		}
		
		tagUnichar = [tag characterAtIndex:0];
		
		switch (tagUnichar) {
			case '!':
				// ignore comment
				break;
				
			case '#':
			case '^':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				element = [self parseSectionWithName:name
											inverted:(tagUnichar == '^')
										   startline:curline
											   error:outError];
				if (!element) {
					return nil;
				}
				[sectionElems addObject:element];
				break;
				
			case '/':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				
				if ([name isEqualToString:sectionName]) {
					return [GRMustacheSectionElement sectionElementWithName:sectionName
																	string:[templateString substringWithRange:NSMakeRange(sectionStart, lastOTagStart-sectionStart)]
															templateLoader:templateLoader
																  inverted:inverted
																  elements:sectionElems];
				} else {
					if (outError != NULL) {
						if (inverted) {
							*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Unexpected section closing tag %@/%@%@ in section %@^%@%@", otag, name, ctag, otag, sectionName, ctag, nil]];
						} else {
							*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Unexpected section closing tag %@/%@%@ in section %@#%@%@", otag, name, ctag, otag, sectionName, ctag, nil]];
						}
					}
					return nil;
				}
				break;
				
			case '>':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				element = [templateLoader parseTemplateNamed:name relativeToTemplate:self error:outError];
				if (!element) {
					return nil;
				}
				[sectionElems addObject:element];
				break;
				
			case '=':
				if ([tag characterAtIndex:tag.length-1] != '=') {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid meta tag %@%@%@", otag, tag, ctag, nil]];
					}
					return nil;
				}
				tag = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				NSArray *newTags = [tag componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
				NSIndexSet *indexes = [newTags indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
					return (BOOL)(((NSString*)obj).length > 0);
				}];
				
				if (indexes.count == 2) {
					NSUInteger index1 = [indexes firstIndex];
					NSUInteger index2 = [indexes lastIndex];
					if (index1 < index2) {
						self.otag = [newTags objectAtIndex:index1];
						self.ctag = [newTags objectAtIndex:index2];
					} else {
						self.otag = [newTags objectAtIndex:index2];
						self.ctag = [newTags objectAtIndex:index1];
					}
				} else {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid meta tag %@=%@=%@", otag, tag, ctag, nil]];
					}
					return nil;
				}
				break;
				
			case '{':
				if ([tag characterAtIndex:tag.length-1] == '}') {
					name = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
					[sectionElems addObject:[GRMustacheVariableElement variableElementWithName:name raw:YES]];
				} else {
					if (outError != NULL) {
						*outError = [self parseErrorAtLine:curline description:[NSString stringWithFormat:@"Invalid unescaped tag %@%@%@", otag, tag, ctag, nil]];
					}
					return NO;
				}
				break;
				
			case '&':
				name = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				[sectionElems addObject:[GRMustacheVariableElement variableElementWithName:name raw:YES]];
				break;
				
			default:
				[sectionElems addObject:[GRMustacheVariableElement variableElementWithName:tag raw:NO]];
				break;
		}
		
	};
	
    //should never be here
	NSAssert(NO, nil);
	return nil;
}

- (NSString *)readString:(NSString *)s eof:(BOOL *)eof {
	NSInteger i = p;
    NSInteger newlines = 0;
	NSString *templateChunk;
	NSInteger e;
	unichar templateUnichar;
	*eof = NO;
    while (YES) {
		e = i + s.length;
		
        //are we at the end of the string?
		if (e > templateString.length) {
			*eof = YES;
			return [templateString substringFromIndex:p];
        }
		
		templateChunk = [templateString substringWithRange:NSMakeRange(i, s.length)];
		templateUnichar = [templateChunk characterAtIndex:0];
		
		if (templateUnichar == '\n') {
            newlines++;
        }
		
        if ([templateChunk isEqualToString:s]) {
			NSString *text = [templateString substringWithRange:NSMakeRange(p, e-p)];
			p = e;
            curline += newlines;
            return text;
        } else {
            i++;
        }
    }
	
    //should never be here
	NSAssert(NO, nil);
    return nil;
}

- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	
	if (templateId) {
//		[userInfo setObject:url
//					 forKey:GRMustacheErrorURL];
//		NSURL *mainBundleURL = [[NSBundle mainBundle].bundleURL URLByStandardizingPath];
//		NSURL *templateURL = url;
//		NSURL *directoryURL = nil;
//		while (YES) {
//			directoryURL = [[templateURL URLByDeletingLastPathComponent] URLByStandardizingPath];
//			if ([directoryURL isEqual:templateURL]) {
//				[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d of %@: %@", line, url, description]
//							 forKey:NSLocalizedDescriptionKey];
//				break;
//			}
//			if ([directoryURL isEqual:mainBundleURL]) {
//				[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d of %@: %@", line, [[[url URLByStandardizingPath] absoluteString] stringByReplacingOccurrencesOfString:[directoryURL absoluteString] withString:@""], description]
//							 forKey:NSLocalizedDescriptionKey];
//				break;
//			}
//			templateURL = directoryURL;
//		}
		[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d of %@: %@", line, templateId, description]
					 forKey:NSLocalizedDescriptionKey];
	} else {
		[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d: %@", line, description]
					 forKey:NSLocalizedDescriptionKey];
	}
	[userInfo setObject:[NSNumber numberWithInteger:line]
				 forKey:GRMustacheErrorLine];
	
	return [NSError errorWithDomain:GRMustacheErrorDomain
							   code:GRMustacheErrorCodeParseError
						   userInfo:userInfo];
}

@end
