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
#import "ProcessCommentComponentsTask.h"

@interface ProcessCommentComponentsTask ()
@property (nonatomic, strong) NSMutableString *currentComponentBuilder;
@property (nonatomic, strong) NSMutableArray *currentDiscussion;
@end

#pragma mark -

@implementation ProcessCommentComponentsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogProInfo(@"Processing comment '%@' for components...", [comment.sourceString gb_description]);
	self.currentDiscussion = [@[] mutableCopy];
	[self.markdownParser parseString:comment.sourceString];
	[self registerCommentComponentFromString:self.currentComponentBuilder];
	if (self.currentDiscussion.count > 0) {
		LogProDebug(@"Registering abstract and discussion...");
		CommentComponentInfo *abstract = self.currentDiscussion[0];
		[self.currentDiscussion removeObject:abstract];
		[comment setCommentAbstract:abstract];
		[comment setCommentDiscussion:self.currentDiscussion];
	}
	return GBResultOk;
}

#pragma mark - Comment components handling

- (void)registerCommentComponentFromString:(NSString *)string {
	if (string.length == 0) return;
	LogProDebug(@"Registering comment component from '%@'...", [string gb_description]);
	CommentComponentInfo *component = [self componentInfoFromString:string];
	[self.currentDiscussion addObject:component];
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

- (void)markdownParser:(MarkdownParser *)parser parseBlockCode:(const struct buf *)text language:(const struct buf *)language output:(struct buf *)buffer {
	LogProDebug(@"Processing block code '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockQuote:(const struct buf *)text output:(struct buf *)buffer {
	LogProDebug(@"Processing block quote '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseBlockHTML:(const struct buf *)text output:(struct buf *)buffer {
	LogProDebug(@"Processing block HTML '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHeader:(const struct buf *)text level:(NSInteger)level output:(struct buf *)buffer {
	LogProDebug(@"Processing header '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseHRule:(struct buf *)buffer {
	LogProDebug(@"Processing hrule...");
}

- (void)markdownParser:(MarkdownParser *)parser parseList:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer {
	LogProDebug(@"Processing list '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseListItem:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer {
	LogProDebug(@"Processing list item '%@'...", [[self stringFromBuffer:text] gb_description]);
}

- (void)markdownParser:(MarkdownParser *)parser parseParagraph:(const struct buf *)text output:(struct buf *)buffer {
	NSString *paragraph = [self stringFromBuffer:text];
	LogProDebug(@"Detected paragraph '%@'.", [paragraph gb_description]);
	if (self.currentComponentBuilder) [self registerCommentComponentFromString:self.currentComponentBuilder];
	self.currentComponentBuilder = [paragraph mutableCopy];
}

- (void)markdownParser:(MarkdownParser *)parser parseTableHeader:(const struct buf *)header body:(const struct buf *)body output:(struct buf *)buffer {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableRow:(const struct buf *)text output:(struct buf *)buffer {
}

- (void)markdownParser:(MarkdownParser *)parser parseTableCell:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer {
}

@end