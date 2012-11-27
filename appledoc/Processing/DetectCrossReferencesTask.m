//
//  DetectCrossReferencesTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 24.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "DetectCrossReferencesTask.h"

@implementation DetectCrossReferencesTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	[self processCommentComponent:comment.commentAbstract];
	[self processCommentSection:comment.commentDiscussion];
	[self processCommentSections:comment.commentParameters];
	[self processCommentSections:comment.commentExceptions];
	[self processCommentSection:comment.commentReturn];
	return GBResultOk;
}

#pragma mark - Comment components handling

- (void)processCommentSections:(NSArray *)sections {
	__weak DetectCrossReferencesTask *bself = self;
	[sections enumerateObjectsUsingBlock:^(CommentSectionInfo *section, NSUInteger idx, BOOL *stop) {
		[bself processCommentSection:section];
	}];
}

- (void)processCommentSection:(CommentSectionInfo *)section {
	__weak DetectCrossReferencesTask *bself = self;
	[section.sectionComponents enumerateObjectsUsingBlock:^(CommentComponentInfo *component, NSUInteger idx, BOOL *stop) {
		[bself processCommentComponent:component];
	}];
}

- (void)processCommentComponent:(CommentComponentInfo *)component {
	if ([component isKindOfClass:[CommentCodeBlockComponentInfo class]]) {
		component.componentMarkdown = component.sourceString;
		return;
	}
	NSMutableString *builder = [@"" mutableCopy];
	[self processCrossRefsInString:component.sourceString toBuilder:builder];
	component.componentMarkdown = builder;
}

#pragma mark - References handlers

- (void)processCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder {
	// Finds all regular Markdown links. For each, it processes preceeding string for appledoc cross refs, then checks if given Markdown link also contains path to one of known objects and parses it accordingly (note that in case no markdown link is found, the rest of the given string is processed). It then repeats until the end of string.
	__weak DetectCrossReferencesTask *bself = self;
	[self enumerateMatchesOf:nil in:string prefix:^(NSString *prefix) {
		[bself processAppledocCrossRefsInString:prefix toBuilder:builder];
	} match:^(NSTextCheckingResult *match) {
		[builder appendString:[match gb_stringAtIndex:0 in:string]];
	}];
}

- (void)processAppledocCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder {
	// Finds all appledoc cross references in given string. If works by splitting the work into first finding remote member cross refs, and finding inline cross refs in remaining string.
	__weak DetectCrossReferencesTask *bself = self;
	[self enumerateMatchesOf:nil in:string prefix:^(NSString *prefix) {
		[bself processInlineCrossRefsInString:prefix toBuilder:builder];
	} match:^(NSTextCheckingResult *match) {
		[builder appendString:[match gb_stringAtIndex:0 in:string]];		
	}];
}

- (void)processInlineCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder {
	[builder appendString:string];
}

#pragma mark - Helper methods

- (void)enumerateMatchesOf:(NSRegularExpression *)expression in:(NSString *)string prefix:(void(^)(NSString *prefix))prefixBlock match:(GBRegexMatchBlock)matchBlock {
	// Enumerates all matches of the given regular expression in given string. For each match, it calls prefix block passing it the string between the last match and current one, then calls match block passing it the match itself. For last segment (i.e. after the last match), or in case no match is found at all, only prefix block is called with remaining (or whole of the given) string, but match block isn't.
	__block NSRange searchRange = NSMakeRange(0, string.length);
	[expression gb_allMatchesIn:string match:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		NSString *prefixString = [match gb_prefixFromIndex:searchRange.location in:string];
		prefixBlock(prefixString);
		matchBlock(match);
		searchRange = [match gb_remainingRangeIn:string];
	}];
	if (searchRange.location < string.length - 1) {
		NSString *remainingString = [string substringWithRange:searchRange];
		prefixBlock(remainingString);
	}
}

@end
