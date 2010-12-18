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

#import "GRMustacheTokenizer_private.h"
#import "GRMustacheError.h"


@interface GRMustacheTokenizer()
@property (nonatomic, retain) NSString *otag;
@property (nonatomic, retain) NSString *ctag;
- (BOOL)shouldContinueParsingAfterReadingToken:(GRMustacheToken *)token;
- (void)didStart;
- (void)didFinish;
- (void)didFinishWithParseErrorAtLine:(NSInteger)line description:(NSString *)description;
- (NSRange)rangeOfString:(NSString *)string inTemplateString:(NSString *)templateString startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines;
@end

@implementation GRMustacheTokenizer
@synthesize otag;
@synthesize ctag;

- (id)init {
	if ((self = [super init])) {
		otag = [@"{{" retain];
		ctag = [@"}}" retain];
	}
	return self;
}

- (void)dealloc {
	[otag release];
	[ctag release];
	[super dealloc];
}

- (void)parseTemplateString:(NSString *)templateString forTokenConsumer:(id<GRMustacheTokenConsumer>)theTokenConsumer {
	NSUInteger p = 0;
	NSUInteger line = 1;
	NSUInteger consumedLines = 0;
	NSRange orange;
	NSRange crange;
	NSString *tag;
	unichar tagUnichar;
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	tokenConsumer = theTokenConsumer;
	[self didStart];
	
	while (YES) {
		// look for otag
		orange = [self rangeOfString:otag inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
		
		// otag was not found
		if (orange.location == NSNotFound) {
			if (p < templateString.length) {
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
															   content:[templateString substringFromIndex:p]
																  line:line
																 range:NSMakeRange(p, templateString.length-p)]]) {
					return;
				}
			}
			[self didFinish];
			return;
		}
		
		if (orange.location > p) {
			NSRange range = NSMakeRange(p, orange.location-p);
			if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
														   content:[templateString substringWithRange:range]
															  line:line
															 range:range]]) {
				return;
			}
		}
		
		// update our cursors
		p = orange.location + orange.length;
		line += consumedLines;
		
		// look for close tag
		if (p < templateString.length && [templateString characterAtIndex:p] == '{') {
			crange = [self rangeOfString:[@"}" stringByAppendingString:ctag] inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
		} else {
			crange = [self rangeOfString:ctag inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
		}
		
		// ctag was not found
		if (crange.location == NSNotFound) {
			[self didFinishWithParseErrorAtLine:line description:@"Unmatched opening tag"];
			return;
		}
		
		// extract tag
		tag = [templateString substringWithRange:NSMakeRange(orange.location + orange.length, crange.location - orange.location - orange.length)];
		
		// empty tag is not allowed
        if (tag.length == 0) {
			[self didFinishWithParseErrorAtLine:line description:@"Empty tag"];
			return;
        }
		
		// tag must not contain otag
		if ([tag rangeOfString:otag].location != NSNotFound) {
			[self didFinishWithParseErrorAtLine:line description:@"Unmatched opening tag"];
			return;
		}
		
		// interpret tag
		tagUnichar = [tag characterAtIndex:0];
		switch (tagUnichar) {
			case '!':
				tag = [tag substringFromIndex:1];
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeComment
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '#':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty section opening tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeSectionOpening
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '^':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty inverted section opening tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeInvertedSectionOpening
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '/':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty section closing tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeSectionClosing
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '>':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty partial tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypePartial
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '=':
				if ([tag characterAtIndex:tag.length-1] != '=') {
					[self didFinishWithParseErrorAtLine:line description:@"Invalid set delimiter tag"];
					return;
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
					[self didFinishWithParseErrorAtLine:line description:@"Invalid set delimiter tag"];
					return;
				}
				
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeSetDelimiter
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '{':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty unescaped variable tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeUnescapedVariable
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			case '&':
				tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty unescaped variable tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeUnescapedVariable
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
				
			default:
				tag = [tag stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if (tag.length == 0) {
					[self didFinishWithParseErrorAtLine:line description:@"Empty variable tag"];
					return;
				}
				if (![self shouldContinueParsingAfterReadingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeEscapedVariable
															   content:tag
																  line:line
																 range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
					return;
				}
				break;
		}
		
		// update our cursors
		p = crange.location + crange.length;
		line += consumedLines;
	}
}

- (BOOL)shouldContinueParsingAfterReadingToken:(GRMustacheToken *)token {
	if (tokenConsumer) {
		return [tokenConsumer tokenProducer:self shouldContinueParsingAfterReadingToken:token];
	}
	return YES;
}

- (void)didStart {
	if (tokenConsumer) {
		[tokenConsumer tokenProducerDidStart:self];
	}
}

- (void)didFinish {
	if (tokenConsumer) {
		[tokenConsumer tokenProducerDidFinish:self withError:nil];
	}
}

- (void)didFinishWithParseErrorAtLine:(NSInteger)line description:(NSString *)description {
	if (tokenConsumer) {
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
		[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d: %@", line, description]
					 forKey:NSLocalizedDescriptionKey];
		[userInfo setObject:[NSNumber numberWithInteger:line]
					 forKey:GRMustacheErrorLine];
		[tokenConsumer tokenProducerDidFinish:self withError:[NSError errorWithDomain:GRMustacheErrorDomain
																					 code:GRMustacheErrorCodeParseError
																				 userInfo:userInfo]];
	}
}

- (NSRange)rangeOfString:(NSString *)string inTemplateString:(NSString *)templateString startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines {
	NSUInteger stringLength = string.length;
	NSUInteger templateStringLength = templateString.length;
	unichar firstStringChar = [string characterAtIndex:0];
	unichar templateChar;
	
	assert(outLines);
	*outLines = 0;
	
    while (p + stringLength <= templateStringLength) {
		templateChar = [templateString characterAtIndex:p];
		if (templateChar == '\n') {
            (*outLines)++;
        } else if (templateChar == firstStringChar && [[templateString substringWithRange:NSMakeRange(p, string.length)] isEqualToString:string]) {
			return NSMakeRange(p, string.length);
        }
		p++;
    }
	
    return NSMakeRange(NSNotFound, 0);
}

@end
