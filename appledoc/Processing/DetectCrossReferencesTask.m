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
	// Finds all appledoc cross references in given string. It works by splitting the work into first finding remote member cross refs, and finding inline cross refs in remaining string.
	__weak DetectCrossReferencesTask *bself = self;
	NSDictionary *remoteMembersCache = self.store.memberObjectsCache;
	NSRegularExpression *expression = [NSRegularExpression gb_remoteMemberMatchingExpression];
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *prefix) {
		[bself processInlineCrossRefsInString:prefix toBuilder:builder];
	} match:^(NSTextCheckingResult *match) {
		// Get match data.
		NSString *description = [match gb_stringAtIndex:0 in:string];
		NSString *prefix = [match gb_stringAtIndex:1 in:string];
		NSString *objectName = [match gb_stringAtIndex:2 in:string];
		NSString *memberName = [match gb_stringAtIndex:3 in:string];
		
		// Find remote member cross reference in cache. If no prefix is given also try class and instance method variants. Give class precedence...
		NSString *key = [NSString stringWithFormat:@"%@[%@ %@]", prefix, objectName, memberName];
		ObjectInfoBase *object = remoteMembersCache[key];
		if (!object && prefix.length == 0) {
			key = [NSString stringWithFormat:@"+[%@ %@]", objectName, memberName];
			object = remoteMembersCache[key];
			if (!object) {
				key = [NSString stringWithFormat:@"-[%@ %@]", objectName, memberName];
				object = remoteMembersCache[key];
			}
		}
		
		// If found, convert it to cross reference.
		if (object) {
			[builder appendString:[bself stringForCrossRefTo:object description:description]];
			return;
		}
		
		// If not found, just append the given match.
		[builder appendString:description];
	}];
}

- (void)processInlineCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder {
	// Small optimization; if there's no registered object, no need to scan the string, just append it to builder and exit.
	NSDictionary *topLevelObjectsCache = self.store.topLevelObjectsCache;
	if (topLevelObjectsCache.count == 0) {
		[builder appendString:string];
		return;
	}

	__weak DetectCrossReferencesTask *bself = self;
	NSRegularExpression *expression = [NSRegularExpression gb_wordMatchingExpression];
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *word) {
		// Find cross referenced object.
		ObjectInfoBase *object = topLevelObjectsCache[word];
		
		// If found, convert it to cross reference.
		if (object) {
			[builder appendString:[bself stringForCrossRefTo:object description:word]];
			return;
		}
		
		// If not found, just append the word plain as it is.
		[builder appendString:word];
	} match:^(NSTextCheckingResult *match) {
		// Append matched whitespace.
		[builder appendString:[match gb_stringAtIndex:0 in:string]];
	}];
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

- (NSString *)stringForCrossRefTo:(ObjectInfoBase *)object description:(NSString *)description {
	return [NSString stringWithFormat:@"[%@](%@)", description, object.objectCrossRefPathTemplate];
}

@end
