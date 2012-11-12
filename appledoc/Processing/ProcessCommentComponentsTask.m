//
//  ProcessCommentComponentsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "CommentComponentInfo.h"
#import "CommentNamedSectionInfo.h"
#import "ProcessCommentComponentsTask.h"

@interface ProcessComponentsData : NSObject
@property (nonatomic, strong) NSMutableString *builder;
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation ProcessComponentsData @end

#pragma mark -

@implementation ProcessCommentComponentsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogProInfo(@"Processing comment '%@' for components...", [comment.sourceString gb_description]);
	
	// Prepare internal data.
	ProcessComponentsData *data = [[ProcessComponentsData alloc] init];
	data.builder = [@"" mutableCopy];
	data.sections = [@[] mutableCopy];
	
	// Parse comment string into sections.
	[self parseSectionsFromComment:comment toData:data];
	[self parseAbstractFromData:data];
	if (data.sections.count == 0) return GBResultOk;
	
	// Process sections into comment components.
	[self registerAbstractFromData:data toComment:comment];
	[self registerDiscussionFromData:data toComment:comment];
	[self registerMethodFromData:data toComment:comment];
}

- (void)parseSectionsFromComment:(CommentInfo *)comment toData:(ProcessComponentsData *)data {
	LogProDebug(@"Parsing comment string into sections...");
	[self.markdownParser parseString:comment.sourceString context:data];
	[self processAndRegisterString:data.builder toData:data append:NO];
}

- (void)parseAbstractFromData:(ProcessComponentsData *)data {
	// Find first empty line in first section.
	if (data.sections.count == 0) return;
	LogProDebug(@"Parsing abstract from sections...");
	NSString *firstSection = data.sections[0];
	NSRegularExpression *expression = [NSRegularExpression gb_emptyLineMatchingExpression];
	NSTextCheckingResult *match = [expression gb_firstMatchIn:firstSection];
	if (!match) return;
	
	// Split first section into two - delimited by first empty line.
	NSUInteger firstSectionEndIndex = match.range.location;
	NSUInteger subsequentSectionsStartIndex = firstSectionEndIndex + match.range.length;
	NSString *abstractSection = [firstSection substringToIndex:firstSectionEndIndex];
	NSString *discussionSection = [firstSection substringFromIndex:subsequentSectionsStartIndex];
	[data.sections removeObjectAtIndex:0];
	[data.sections insertObject:abstractSection atIndex:0];
	[data.sections insertObject:discussionSection atIndex:1];
}

- (void)registerAbstractFromData:(ProcessComponentsData *)data toComment:(CommentInfo *)comment {
	LogProDebug(@"Registering abstract...");
	CommentComponentInfo *component = [CommentComponentInfo componentWithSourceString:data.sections[0]];
	[comment setCommentAbstract:component];
	[data.sections removeObjectAtIndex:0];
}

- (void)registerDiscussionFromData:(ProcessComponentsData *)data toComment:(CommentInfo *)comment {
	// Register all discussion sections - up until first parameter related section.
	NSRegularExpression *expression = [NSRegularExpression gb_methodSectionDelimiterMatchingExpression];
	CommentSectionInfo *discussion = nil;
	while (data.sections.count > 0) {
		NSString *sectionString = data.sections[0];
		NSTextCheckingResult *match = [expression gb_firstMatchIn:sectionString];
		if (match && match.range.location == 0) break;
		if (!discussion) discussion = [[CommentSectionInfo alloc] init];
		CommentComponentInfo *component = [CommentComponentInfo componentWithSourceString:sectionString];
		[discussion.sectionComponents addObject:component];
		[data.sections removeObjectAtIndex:0];
	}
	if (discussion) [comment setCommentDiscussion:discussion];
}

- (void)registerMethodFromData:(ProcessComponentsData *)data toComment:(CommentInfo *)comment {
	NSMutableArray *parameters = nil;
	NSMutableArray *exceptions = nil;
	CommentSectionInfo *result = nil;
	CommentSectionInfo *lastSection = nil;
	while (data.sections.count > 0) {
		NSString *sectionString = data.sections[0];
		if ([self matchParameterSectionFromString:sectionString sections:data.sections toArray:&parameters]) continue;
		if ([self matchExceptionSectionFromString:sectionString sections:data.sections toArray:&exceptions]) continue;
		if ([self matchReturnSectionFromString:sectionString sections:data.sections toInfo:&result]) continue;
		break;
	}
	if (parameters) [comment setCommentParameters:parameters];
	if (exceptions) [comment setCommentExceptions:exceptions];
	if (result) [comment setCommentReturn:result];
}

#pragma mark - Matching method directives

- (BOOL)matchParameterSectionFromString:(NSString *)string sections:(NSMutableArray *)sections toArray:(NSMutableArray **)array {
	NSRegularExpression *expression = [NSRegularExpression gb_paramMatchingExpression];
	return [self matchNamedMethodSectionFromString:string expression:expression sections:sections toArray:array];
}

- (BOOL)matchExceptionSectionFromString:(NSString *)string sections:(NSMutableArray *)sections toArray:(NSMutableArray **)array {
	NSRegularExpression *expression = [NSRegularExpression gb_exceptionMatchingExpression];
	return [self matchNamedMethodSectionFromString:string expression:expression sections:sections toArray:array];
}

- (BOOL)matchReturnSectionFromString:(NSString *)string sections:(NSMutableArray *)sections toInfo:(CommentSectionInfo **)dest {
	NSRegularExpression *expression = [NSRegularExpression gb_returnMatchingExpression];
	return [self matchSimpleSectionFromString:string expression:expression sections:sections toInfo:dest];
}

- (BOOL)matchNamedMethodSectionFromString:(NSString *)string expression:(NSRegularExpression *)expression sections:(NSMutableArray *)sections toArray:(NSMutableArray **)array {
	NSTextCheckingResult *match = [expression gb_firstMatchIn:string];
	if (!match) return NO;
	NSString *description = [match gb_remainingStringIn:string];
	CommentComponentInfo *component = [CommentComponentInfo componentWithSourceString:description];
	CommentNamedSectionInfo *info = [[CommentNamedSectionInfo alloc] init];
	[info setSectionName:[match gb_stringAtIndex:2 in:string]];
	[info.sectionComponents addObject:component];
	if (!*array) *array = [@[] mutableCopy];
	[*array addObject:info];
	[sections removeObjectAtIndex:0];
	return YES;
}

- (BOOL)matchSimpleSectionFromString:(NSString *)string expression:(NSRegularExpression *)expression sections:(NSMutableArray *)sections toInfo:(CommentSectionInfo **)dest {
	NSTextCheckingResult *match = [expression gb_firstMatchIn:string];
	if (!match) return NO;
	NSString *description = [match gb_remainingStringIn:string];
	CommentComponentInfo *component = [CommentComponentInfo componentWithSourceString:description];
	CommentSectionInfo *info = [[CommentSectionInfo alloc] init];
	[info.sectionComponents addObject:component];
	*dest = info;
	[sections removeObjectAtIndex:0];
	return YES;
}

#pragma mark - Comment components handling

- (void)processAndRegisterString:(NSString *)string toData:(ProcessComponentsData *)data append:(BOOL)append {
	// Process @ directive section if matched at the start of the string.
	if (string.length == 0) return;
	LogProDebug(@"Processing and registering '%@'...", [string gb_description]);
	NSRegularExpression *expression = [NSRegularExpression gb_sectionDelimiterMatchingExpression];
	NSArray *matches = [expression gb_allMatchesIn:string];
	if (matches.count > 0 && [matches[0] range].location == 0) {
		// Register existing section if needed.
		if (data.builder.length > 0) {
			LogProDebug(@"Detected section '%@'.", data.builder);
			[data.sections addObject:data.builder];
			data.builder = [@"" mutableCopy];
		}

		// Process directives.
		__block NSUInteger lastMatchLocation = 0;
		[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
			if (idx == 0) return;
			NSUInteger previousMatchLocation = [matches[idx-1] range].location;
			NSUInteger currentMatchLocation = match.range.location;
			NSRange sectionRange = NSMakeRange(previousMatchLocation, currentMatchLocation - previousMatchLocation);
			NSString *sectionString = [[string substringWithRange:sectionRange] gb_stringByTrimmingNewLines];
			LogProDebug(@"Detected section '%@'.", sectionString);
			[data.sections addObject:sectionString];
			lastMatchLocation = currentMatchLocation;
		}];
		
		// Finish the last directive. Note that this time we only copy it to builder so we can append additional paragraphs in next shot.
		data.builder = [[[string substringFromIndex:lastMatchLocation] gb_stringByTrimmingNewLines] mutableCopy];
		LogProDebug(@"Detected section '%@'.", data.builder);
		return;
	}
	
	// Append all other text to current section builder if append is allowed.
	if (append) {
		LogParDebug(@"Appending string '%@'...", [string gb_description]);
		if (data.builder.length > 0) [data.builder appendString:@"\n\n"];
		[data.builder appendString:[string gb_stringByTrimmingNewLines]];
		return;
	}
	
	// Register remaining paragraph.
	[data.sections addObject:string];
}

#pragma mark - Low level string parsing

- (CommentComponentInfo *)componentInfoFromString:(NSString *)string {
	LogProDebug(@"Creating component for %@...", string);
	CommentComponentInfo *result = [[CommentComponentInfo alloc] init];
	result.sourceString = string;
	return result;
}

@end

#pragma mark -

@implementation ProcessCommentComponentsTask (MarkdownParserDelegateImplementation)

- (void)markdownParser:(MarkdownParser *)parser parseBlockCode:(const struct buf *)text language:(const struct buf *)language output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing block code '%@'...", [[parser stringFromBuffer:text] gb_description]);
	
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockQuote:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing block quote '%@'...", [[parser stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockHTML:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing block HTML '%@'...", [[parser stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHeader:(const struct buf *)text level:(NSInteger)level output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing header '%@'...", [[parser stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHRule:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing hrule...");
}

- (void)markdownParser:(MarkdownParser *)parser parseList:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing list '%@'...", [[parser stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseListItem:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing list item '%@'...", [[parser stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseParagraph:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	NSString *paragraph = [parser stringFromBuffer:text];
	LogProDebug(@"Detected paragraph '%@'.", [paragraph gb_description]);
	[self processAndRegisterString:paragraph toData:data append:YES];
}

- (void)markdownParser:(MarkdownParser *)parser parseTableHeader:(const struct buf *)header body:(const struct buf *)body output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableRow:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableCell:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

@end