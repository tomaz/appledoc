//
//  SplitCommentToSectionsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "CommentComponentInfo.h"
#import "CommentNamedSectionInfo.h"
#import "SplitCommentToSectionsTask.h"

@interface SplitCommentToSectionsTask ()
@property (nonatomic, strong) CommentInfo *comment;
@property (nonatomic, strong) NSMutableString *builder;
@property (nonatomic, strong) NSString *lastRegisteredSection;
@end

#pragma mark -

@implementation SplitCommentToSectionsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogVerbose(@"Splitting '%@' to sections...", [comment.sourceString gb_description]);
	self.comment = comment;
	self.comment.sourceSections = [@[] mutableCopy];
	[self resetBuilder];
	[self parseSectionsFromBuilder];
	[self registerSectionFromBuilderAndStartNew:NO];
	return GBResultOk;
}

#pragma mark - Splitting source string to sections

- (void)parseSectionsFromBuilder {
	LogDebug(@"Parsing comment string into sections...");
	NSRegularExpression *expression = [NSRegularExpression gb_emptyLineMatchingExpression];
	NSString *sourceString = self.comment.sourceString;
	__weak SplitCommentToSectionsTask *bself = self;
	__block NSUInteger index = 0;
	[expression gb_allMatchesIn:sourceString match:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		NSRange range = NSMakeRange(index, match.range.location - index);
		NSString *section = [sourceString substringWithRange:range];
		[bself parseSectionsToBuilderFromString:section];
		index = match.range.location + match.range.length;
	}];
	NSString *remainingString = [sourceString substringFromIndex:index];
	[self parseSectionsToBuilderFromString:remainingString];
}

- (void)parseSectionsToBuilderFromString:(NSString *)sectionString {
	if (sectionString.length == 0) return;
	if ([self parseCodeBlockToBuilderFromString:sectionString]) return;
	if ([self parseStyledSectionToBuilderFromString:sectionString]) return;
	if ([self parseMethodSectionToBuilderFromString:sectionString]) return;
	
	// If this is the first paragraph to be registered, take it as abstract and create single section out of it.
	if (self.comment.sourceSections.count == 0) {
		LogDebug(@"Detected abstract '%@'...", [sectionString gb_description]);
		[self appendStringToBuilder:sectionString];
		[self registerSectionFromBuilderAndStartNew:YES];
		return;
	}
	
	// Otherwise append "normal" paragraph to current section builder to be registered later on.
	LogDebug(@"Appending paragraph '%@'...", [sectionString gb_description]);
	if (self.builder.length > 0) [self appendStringToBuilder:@"\n\n"];
	[self appendStringToBuilder:[sectionString gb_stringByTrimmingNewLines]];
}

- (BOOL)parseCodeBlockToBuilderFromString:(NSString *)sectionString {
	// If current section represents code block, tread whole section as code block. Note that this doesn't work for empty strings!
	if (![self isStringCodeBlock:sectionString]) return NO;
	[self registerSectionFromBuilderIfNeededAndStartNew:YES];
	[self appendStringToBuilder:sectionString];
	[self registerSectionFromBuilderAndStartNew:YES];
	return YES;
}

- (BOOL)parseStyledSectionToBuilderFromString:(NSString *)sectionString {
	// If current section represents @warning and @bug, treat whole section string as styled section.
	NSTextCheckingResult *styledSectionMatch = [[NSRegularExpression gb_styledSectionDelimiterMatchingExpression] gb_firstMatchIn:sectionString];
	if (![styledSectionMatch gb_isMatchedAtStart]) return NO;
	[self registerSectionFromBuilderIfNeededAndStartNew:YES];
	[self appendStringToBuilder:sectionString];
	[self registerSectionFromBuilderAndStartNew:NO];
	return YES;
}

- (BOOL)parseMethodSectionToBuilderFromString:(NSString *)sectionString {
	// If current "paragraph" starts with method section directive, we must split the whole string into individual sections, each directive starting new section.
	NSRegularExpression *expression = [NSRegularExpression gb_methodSectionDelimiterMatchingExpression];
	NSArray *sectionMatches = [expression gb_allMatchesIn:sectionString];
	if (sectionMatches.count == 0 || ![sectionMatches[0] gb_isMatchedAtStart]) return NO;
	
	__weak SplitCommentToSectionsTask *bself = self;
	__block NSUInteger lastMatchLocation = 0;
	[self registerSectionFromBuilderIfNeededAndStartNew:YES];
	[sectionMatches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		if (idx == 0) return;
		NSString *currentSectionString = [[match gb_prefixFromIndex:lastMatchLocation in:sectionString] gb_stringByTrimmingNewLines];
		[bself appendStringToBuilder:currentSectionString];
		[bself registerSectionFromBuilderAndStartNew:YES];
		lastMatchLocation = match.range.location;
	}];
	
	// Register remaining section, but keep the string so we can append subsequent paragraphs to it.
	NSString *remainingSectionString = [[sectionString substringFromIndex:lastMatchLocation] gb_stringByTrimmingNewLines];
	[bself appendStringToBuilder:remainingSectionString];
	[self registerSectionFromBuilderAndStartNew:NO];
	return YES;
}

- (BOOL)registerSectionFromBuilderIfNeededAndStartNew:(BOOL)startNew {
	// Returns YES if section was registered, NO otherwise.
 	if (self.builder.length == 0) return NO;
	[self registerSectionFromBuilderAndStartNew:startNew];
	return YES;
}

- (void)registerSectionFromBuilderAndStartNew:(BOOL)startNew {
	// Note that we need to handle special case where current builder string is the same pointer as last object; in such case we can ignore it, but we do need to clear the string!
	if (self.builder.length == 0) return;
	if (self.builder == self.lastRegisteredSection) { [self resetBuilder]; return; }
	LogDebug(@"Registering section '%@'...", [self.builder gb_description]);
	[self.comment.sourceSections addObject:self.builder];
	self.lastRegisteredSection = self.builder;
	if (startNew) [self resetBuilder];
}

- (void)appendStringToBuilder:(NSString *)string {
	[self.builder appendString:string];
}

- (void)resetBuilder {
	self.builder = [@"" mutableCopy];
}

@end
