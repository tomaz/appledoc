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

#import "GRMustacheCompiler_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRBoolean.h"
#import "GRMustacheError.h"

@interface GRMustacheCompiler()
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) GRMustacheToken *currentSectionOpeningToken;
- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description;
@end

@implementation GRMustacheCompiler
@synthesize error;
@synthesize currentSectionOpeningToken;

- (NSArray *)parseString:(NSString *)theTemplateString withTokenProducer:(id<GRMustacheTokenProducer>)tokenProducer templateLoader:(GRMustacheTemplateLoader *)theTemplateLoader templateId:(id)theTemplateId error:(NSError **)outError {
	templateString = theTemplateString;
	templateId = theTemplateId;
	templateLoader = theTemplateLoader;
	
	currentElements = [NSMutableArray arrayWithCapacity:20];
	elementsStack = [[NSMutableArray alloc] initWithCapacity:20];
	[elementsStack addObject:currentElements];
	sectionOpeningTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
	
	[tokenProducer parseTemplateString:templateString forTokenConsumer:self];
	
	if (error == nil && currentSectionOpeningToken) {
		self.error = [self parseErrorAtLine:currentSectionOpeningToken.line
								description:[NSString stringWithFormat:@"Unclosed `%@` section", currentSectionOpeningToken.content]];
	}
	
	if (error) {
		if (outError != NULL) {
			*outError = error;
		}
		return nil;
	}
	
	[currentElements retain];
	[elementsStack release];
	[sectionOpeningTokenStack release];
	return [currentElements autorelease];
}

- (void)dealloc {
	[error release];
	[currentSectionOpeningToken release];
	[super dealloc];
}

#pragma mark GRMustacheTokenConsumer

- (BOOL)tokenProducer:(id<GRMustacheTokenProducer>)tokenProducer shouldContinueParsingAfterReadingToken:(GRMustacheToken *)token {
	switch (token.type) {
		case GRMustacheTokenTypeText:
			[currentElements addObject:[GRMustacheTextElement textElementWithString:token.content]];
			break;
			
		case GRMustacheTokenTypeComment:
			break;
			
		case GRMustacheTokenTypeEscapedVariable:
			[currentElements addObject:[GRMustacheVariableElement variableElementWithName:token.content raw:NO]];
			break;
			
		case GRMustacheTokenTypeUnescapedVariable:
			[currentElements addObject:[GRMustacheVariableElement variableElementWithName:token.content raw:YES]];
			break;
			
		case GRMustacheTokenTypeSectionOpening:
		case GRMustacheTokenTypeInvertedSectionOpening:
			self.currentSectionOpeningToken = token;
			[sectionOpeningTokenStack addObject:token];
			
			currentElements = [NSMutableArray array];
			[elementsStack addObject:currentElements];
			break;
			
		case GRMustacheTokenTypeSectionClosing:
			if ([token.content isEqualToString:currentSectionOpeningToken.content]) {
				NSRange currentSectionOpeningTokenRange = currentSectionOpeningToken.range;
				GRMustacheSectionElement *section = [GRMustacheSectionElement sectionElementWithName:currentSectionOpeningToken.content
																							  string:[templateString substringWithRange:NSMakeRange(currentSectionOpeningTokenRange.location + currentSectionOpeningTokenRange.length, token.range.location - currentSectionOpeningTokenRange.location - currentSectionOpeningTokenRange.length)]
																							inverted:currentSectionOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening
																							elements:currentElements];
				[sectionOpeningTokenStack removeLastObject];
				self.currentSectionOpeningToken = [sectionOpeningTokenStack lastObject];
				
				[elementsStack removeLastObject];
				currentElements = [elementsStack lastObject];
				
				[currentElements addObject:section];
			} else {
				self.error = [self parseErrorAtLine:token.line description:[NSString stringWithFormat:@"Unexpected `%@` section closing tag", token.content]];
				return NO;
			}
			break;
			
		case GRMustacheTokenTypePartial: {
			NSError *partialError;
			GRMustacheTemplate *partialTemplate = [templateLoader parseTemplateNamed:token.content
																relativeToTemplateId:templateId
																			   error:&partialError];
			if (partialTemplate == nil) {
				self.error = partialError;
				return NO;
			} else {
				[currentElements addObject:partialTemplate];
			}
		} break;
			
		case GRMustacheTokenTypeSetDelimiter:
			// ignore
			break;
			
		default:
			NSAssert(NO, nil);
			break;
			
	}
	return YES;
}

- (void)tokenProducerDidStart:(id<GRMustacheTokenProducer>)tokenProducer {
}

- (void)tokenProducerDidFinish:(id<GRMustacheTokenProducer>)tokenProducer withError:(NSError *)theError {
	self.error = theError;
}

#pragma mark Private

- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d: %@", line, description]
					 forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:[NSNumber numberWithInteger:line]
				 forKey:GRMustacheErrorLine];
	return [NSError errorWithDomain:GRMustacheErrorDomain
							   code:GRMustacheErrorCodeParseError
						   userInfo:userInfo];
}

@end
