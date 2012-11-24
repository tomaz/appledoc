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
@end

#pragma mark -

@implementation SplitCommentToSectionsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogVerbose(@"Processing comment '%@' for components...", [comment.sourceString gb_description]);
	NSMutableString *builder = [@"" mutableCopy];
	self.comment = comment;
	self.comment.sourceSections = [@[] mutableCopy];
	[self parseSectionsWithBuilder:builder];
	[self registerSectionFromBuilder:builder startNewSection:NO];
	return GBResultOk;
}

#pragma mark - Splitting source string to sections

- (void)parseSectionsWithBuilder:(NSMutableString *)builder {
	LogDebug(@"Parsing comment string into sections...");
	NSRegularExpression *expression = [NSRegularExpression gb_emptyLineMatchingExpression];
	NSString *sourceString = self.comment.sourceString;
	__weak SplitCommentToSectionsTask *bself = self;
	__block NSUInteger index = 0;
	[expression gb_allMatchesIn:sourceString match:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		NSRange range = NSMakeRange(index, match.range.location - index);
		NSString *section = [sourceString substringWithRange:range];
		[bself parseSectionsFromString:section toBuilder:builder];
		index = match.range.location + match.range.length;
	}];
	NSString *remainingString = [sourceString substringFromIndex:index];
	[self parseSectionsFromString:remainingString toBuilder:builder];
}

- (void)parseSectionsFromString:(NSString *)sectionString toBuilder:(NSMutableString *)builder {
	if (sectionString.length == 0) return;
	if ([self parseCodeBlockFromString:sectionString toBuilder:builder]) return;
	if ([self parseStyledSectionFromString:sectionString toBuilder:builder]) return;
	if ([self parseMethodSectionFromString:sectionString toBuilder:builder]) return;
	
	// If this is the first paragraph to be registered, take it as abstract and create single section out of it.
	if (self.comment.sourceSections.count == 0) {
		LogDebug(@"Detected abstract '%@'...", [sectionString gb_description]);
		[builder appendString:sectionString];
		[self registerSectionFromBuilder:builder startNewSection:YES];
		return;
	}
	
	// Otherwise append "normal" paragraph to current section builder to be registered later on.
	LogDebug(@"Appending paragraph '%@'...", [sectionString gb_description]);
	if (builder.length > 0) [builder appendString:@"\n\n"];
	[builder appendString:[sectionString gb_stringByTrimmingNewLines]];
}

- (BOOL)parseCodeBlockFromString:(NSString *)sectionString toBuilder:(NSMutableString *)builder {
	// If current section represents code block, tread whole section as code block. Note that this doesn't work for empty strings!
	if (![self isStringCodeBlock:sectionString]) return NO;
	[self registerSectionFromBuilderIfNeeded:builder startNewSection:YES];
	[builder appendString:sectionString];
	[self registerSectionFromBuilder:builder startNewSection:YES];
	return YES;
}

- (BOOL)parseStyledSectionFromString:(NSString *)sectionString toBuilder:(NSMutableString *)builder {
	// If current section represents @warning and @bug, treat whole section string as styled section.
	NSTextCheckingResult *styledSectionMatch = [[NSRegularExpression gb_styledSectionDelimiterMatchingExpression] gb_firstMatchIn:sectionString];
	if (![styledSectionMatch gb_isMatchedAtStart]) return NO;
	[self registerSectionFromBuilderIfNeeded:builder startNewSection:YES];
	[builder appendString:sectionString];
	[self registerSectionFromBuilder:builder startNewSection:NO];
	return YES;
}

- (BOOL)parseMethodSectionFromString:(NSString *)sectionString toBuilder:(NSMutableString *)builder {
	// If current "paragraph" starts with method section directive, we must split the whole string into individual sections, each directive starting new section.
	NSRegularExpression *expression = [NSRegularExpression gb_methodSectionDelimiterMatchingExpression];
	NSArray *sectionMatches = [expression gb_allMatchesIn:sectionString];
	if (sectionMatches.count == 0 || ![sectionMatches[0] gb_isMatchedAtStart]) return NO;
	
	__weak SplitCommentToSectionsTask *bself = self;
	__block NSUInteger lastMatchLocation = 0;
	[self registerSectionFromBuilderIfNeeded:builder startNewSection:YES];
	[sectionMatches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		if (idx == 0) return;
		NSString *currentSectionString = [[match gb_prefixFromIndex:lastMatchLocation in:sectionString] gb_stringByTrimmingNewLines];
		[builder appendString:currentSectionString];
		[bself registerSectionFromBuilder:builder startNewSection:YES];
		lastMatchLocation = match.range.location;
	}];
	
	// Register remaining section, but keep the string so we can append subsequent paragraphs to it.
	NSString *remainingSectionString = [[sectionString substringFromIndex:lastMatchLocation] gb_stringByTrimmingNewLines];
	[builder appendString:remainingSectionString];
	[self registerSectionFromBuilder:builder startNewSection:NO];
	return YES;
}

- (BOOL)registerSectionFromBuilderIfNeeded:(NSMutableString *)builder startNewSection:(BOOL)startNew {
	// Returns YES if section was registered, NO otherwise.
 	if (builder.length == 0) return NO;
	[self registerSectionFromBuilder:builder startNewSection:startNew];
	return YES;
}

- (void)registerSectionFromBuilder:(NSMutableString *)builder startNewSection:(BOOL)startNew {
	// Note that we need to handle special case where current builder string is the same pointer as last object; in such case we can ignore it, but we do need to clear the string!
	if (builder.length == 0) return;
	if (builder == self.comment.sourceSections.lastObject) { [builder setString:@""]; return; }
	LogDebug(@"Registering section '%@'...", [builder gb_description]);
	[self.comment.sourceSections addObject:[builder copy]];
	if (startNew) [builder setString:@""];
}

@end
