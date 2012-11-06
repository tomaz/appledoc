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
@property (nonatomic, strong) NSMutableString *componentBuilder;
@property (nonatomic, strong) NSMutableArray *discussion;
@end

@implementation ProcessComponentsData @end

#pragma mark -

@implementation ProcessCommentComponentsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogProInfo(@"Processing comment '%@' for components...", [comment.sourceString gb_description]);
	
	// Parse the comment string.
	ProcessComponentsData *data = [[ProcessComponentsData alloc] init];
	data.discussion = [@[] mutableCopy];
	[self.markdownParser parseString:comment.sourceString context:data];
	[self registerCommentComponentsFromData:data]; // append any remaining data
	if (data.discussion.count == 0) return GBResultOk;
	
	// Always take first paragraph as abstract. The rest are either discussion or parameters/exceptions etc.
	LogProDebug(@"Registering abstract and discussion...");
	CommentComponentInfo *abstract = data.discussion[0];
	[data.discussion removeObject:abstract];
	
	// Scan through the components and prepare various sections. Note that once we step into arguments, we take all subsequent components as part of the argument!
	NSMutableArray *discussioSections = [@[] mutableCopy];
	NSMutableArray *parameterSections = [@[] mutableCopy];
	NSMutableArray *exceptionSections = [@[] mutableCopy];
	__block CommentSectionInfo *returnSection;
	__block NSMutableArray *currentSectionComponents = nil;
	__weak ProcessCommentComponentsTask *bself = self;
	[data.discussion enumerateObjectsUsingBlock:^(CommentComponentInfo *component, NSUInteger idx, BOOL *stop) {
		// Match one of the known directives.
		if ([bself matchParamSectionFromComponent:component commentSections:parameterSections sectionComponents:&currentSectionComponents]) return;
		if ([bself matchExceptionSectionFromComponent:component commentSections:exceptionSections sectionComponents:&currentSectionComponents]) return;
		if ([bself matchReturnSectionFromComponent:component commentSection:&returnSection components:&currentSectionComponents]) return;
					
		// Append component to current section array if one available.
		NSString *string = component.sourceString;
		if (currentSectionComponents) {
			LogProDebug(@"Appending %@ to current section...", [string gb_description]);
			[currentSectionComponents addObject:component];
			return;
		}
		
		// Append component to discussion otherwise.
		LogProDebug(@"Appending %@ to discussion...", [string gb_description]);
		[discussioSections addObject:component];
	}];
	
	// Register all components.
	[comment setCommentAbstract:abstract];
	if (discussioSections.count > 0) [comment setCommentDiscussion:discussioSections];
	if (parameterSections.count > 0) [comment setCommentParameters:parameterSections];
	if (exceptionSections.count > 0) [comment setCommentExceptions:exceptionSections];
	if (returnSection) [comment setCommentReturn:returnSection];
	return GBResultOk;
}

- (BOOL)matchParamSectionFromComponent:(CommentComponentInfo *)source commentSections:(NSMutableArray *)sections sectionComponents:(NSMutableArray **)components {
	NSRegularExpression *expression = [NSRegularExpression gb_paramMatchingExpression];
	return [self matchNamedDirectiveSectionFromComponent:source expression:expression commentSections:sections sectionComponents:components];
}

- (BOOL)matchExceptionSectionFromComponent:(CommentComponentInfo *)source commentSections:(NSMutableArray *)sections sectionComponents:(NSMutableArray **)components {
	NSRegularExpression *expression = [NSRegularExpression gb_exceptionMatchingExpression];
	return [self matchNamedDirectiveSectionFromComponent:source expression:expression commentSections:sections sectionComponents:components];
}

- (BOOL)matchReturnSectionFromComponent:(CommentComponentInfo *)source commentSection:(CommentSectionInfo **)section components:(NSMutableArray **)components {
	NSRegularExpression *expression = [NSRegularExpression gb_returnMatchingExpression];
	return [self matchSimpleDirectiveSectionFromComponent:source expression:expression commentSection:section components:components];
}

#pragma mark - Matching helper methods

- (BOOL)matchNamedDirectiveSectionFromComponent:(CommentComponentInfo *)source expression:(NSRegularExpression *)expression commentSections:(NSMutableArray *)sections sectionComponents:(NSMutableArray **)components {
	NSString *string = source.sourceString;
	return [expression gb_firstMatchIn:string match:^(NSTextCheckingResult *match) {
		// Get directive identifier (@param etc.) and name.
		NSString *type = [match gb_stringAtIndex:1 in:string];
		NSString *name = [match gb_stringAtIndex:2 in:string];
		LogProDebug(@"Matched %@ %@...", type, name);
		
		// Delete directive identifier and name from source string.
		source.sourceString = [match gb_remainingStringIn:string];
		
		// Create named section info and set the data.
		CommentNamedSectionInfo *section = [[CommentNamedSectionInfo alloc] init];
		[section setSectionName:name];
		[section.sectionComponents addObject:source];
		
		// Add the argument to the sections array, so we later add it to comment.
		[sections addObject:section];
		
		// Update parent section components array with our newly created section so that we can later append additional components (aka paragraphs).
		*components = section.sectionComponents;
	}];
}

- (BOOL)matchSimpleDirectiveSectionFromComponent:(CommentComponentInfo *)source expression:(NSRegularExpression *)expression commentSection:(CommentSectionInfo **)section components:(NSMutableArray **)components {
	NSString *string = source.sourceString;
	return [expression gb_firstMatchIn:string match:^(NSTextCheckingResult *match) {
		// Get directive identifier (@return etc.).
		NSString *type = [match gb_stringAtIndex:1 in:string];
		LogProDebug(@"Matched %@...", type);
		
		// Delete directive identifier from source string.
		source.sourceString = [match gb_remainingStringIn:string];
	
		// Create section info and set the data. Note that we update parent section so we can address the object and register it to comment later on.
		CommentSectionInfo *newSection = [[CommentSectionInfo alloc] init];
		[[newSection sectionComponents] addObject:source];
		*section = newSection;
				
		// Update parent section components array with our newly created section so that we can later append additional components (aka paragraphs).
		*components = newSection.sectionComponents;
	}];
}

#pragma mark - Comment components handling

- (void)registerCommentComponentsFromData:(ProcessComponentsData *)data {
	// Split multiple named arguments (@param, @exception etc.) into separate components. If single or none found, just use the whole string.
	NSString *string = data.componentBuilder;
	if (string.length == 0) return;
	LogProDebug(@"Registering comment component from '%@'...", [string gb_description]);
	NSArray *matches = [[NSRegularExpression gb_argumentMatchingExpression] gb_allMatchesIn:string];
	if (matches.count > 1 && [matches[0] range].location == 0) {
		__block NSUInteger lastMatchLocation;
		[matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
			if (idx == 0) return;
			NSUInteger previousMatchLocation = [matches[idx-1] range].location;
			lastMatchLocation = match.range.location;
			NSRange range = NSMakeRange(previousMatchLocation, lastMatchLocation - previousMatchLocation);
			NSString *componentString = [[string substringWithRange:range] gb_stringByTrimmingWhitespaceAndNewLine];
			CommentComponentInfo *component = [self componentInfoFromString:componentString];
			[data.discussion addObject:component];
		}];
		NSString *lastString = [string substringFromIndex:lastMatchLocation];
		CommentComponentInfo *component = [self componentInfoFromString:lastString];
		[data.discussion addObject:component];
	} else {
		CommentComponentInfo *component = [self componentInfoFromString:string];
		[data.discussion addObject:component];
	}
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
	LogProDebug(@"Processing block code '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockQuote:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing block quote '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockHTML:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing block HTML '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHeader:(const struct buf *)text level:(NSInteger)level output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing header '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHRule:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing hrule...");
}

- (void)markdownParser:(MarkdownParser *)parser parseList:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing list '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseListItem:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	LogProDebug(@"Processing list item '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseParagraph:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
	NSString *paragraph = [self stringFromBuffer:text];
	LogProDebug(@"Detected paragraph '%@'.", [paragraph gb_description]);
	if (data.componentBuilder) [self registerCommentComponentsFromData:data];
	data.componentBuilder = [paragraph mutableCopy];
}

- (void)markdownParser:(MarkdownParser *)parser parseTableHeader:(const struct buf *)header body:(const struct buf *)body output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableRow:(const struct buf *)text output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableCell:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(ProcessComponentsData *)data {
}

@end