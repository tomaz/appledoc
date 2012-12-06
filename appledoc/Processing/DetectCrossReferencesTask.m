//
//  DetectCrossReferencesTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 24.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "ObjectsCacher.h"
#import "DetectCrossReferencesTask.h"

typedef NS_OPTIONS(NSUInteger, GBCrossRefOptions) {
	GBCrossRefOptionInsideMarkdownLink = 1 << 0,
};

#pragma mark -

@interface DetectCrossReferencesTask ()
@property (nonatomic, strong) NSMutableDictionary *localMembersCache;
@end

#pragma mark -

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

#pragma mark - Properties

- (void)setProcessingContext:(ObjectInfoBase *)value {
	// When context changes, we should reset local members cache.
	if (value != self.processingContext) {
		LogDebug(@"Processing context changed, resetting local members cache...");
		self.localMembersCache = nil;
	}
	[super setProcessingContext:value];
}

- (NSMutableDictionary *)localMembersCache {
	if (_localMembersCache) return _localMembersCache;
	NSDictionary *cache = [ObjectsCacher cacheMembersFromInterface:self.processingContext classMethod:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		return [NSString stringWithFormat:@"+%@", obj.uniqueObjectID];
	} instanceMethod:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		return [NSString stringWithFormat:@"-%@", obj.uniqueObjectID];
	} property:^id(InterfaceInfoBase *interface, ObjectInfoBase *obj) {
		PropertyInfo *property = (PropertyInfo *)obj;
		return @[
			property.uniqueObjectID,
			[NSString stringWithFormat:@"-%@", property.propertyGetterSelector],
			[NSString stringWithFormat:@"-%@", property.propertySetterSelector],
		];
	}];
	_localMembersCache = [cache mutableCopy];
	return _localMembersCache;
}

#pragma mark - Comment components handling

- (void)processCommentSections:(NSArray *)sections {
	__weak DetectCrossReferencesTask *bself = self;
	LogDebug(@"Processing %lu sections...", sections.count);
	[sections enumerateObjectsUsingBlock:^(CommentSectionInfo *section, NSUInteger idx, BOOL *stop) {
		[bself processCommentSection:section];
	}];
}

- (void)processCommentSection:(CommentSectionInfo *)section {
	__weak DetectCrossReferencesTask *bself = self;
	LogDebug(@"Processing section %@...", section);
	[section.sectionComponents enumerateObjectsUsingBlock:^(CommentComponentInfo *component, NSUInteger idx, BOOL *stop) {
		[bself processCommentComponent:component];
	}];
}

- (void)processCommentComponent:(CommentComponentInfo *)component {
	if ([component isKindOfClass:[CommentCodeBlockComponentInfo class]]) {
		LogDebug(@"Skipping component %@...", component);
		component.componentMarkdown = component.sourceString;
		return;
	}
	LogDebug(@"Processing component %@...", component);
	NSMutableString *builder = [@"" mutableCopy];
	[self processCrossRefsInString:component.sourceString toBuilder:builder];
	component.componentMarkdown = builder;
}

#pragma mark - References handlers

- (void)processCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder {
	// Finds all regular Markdown links. For each, it processes preceeding string for appledoc cross refs, then checks if given Markdown link also contains path to one of known objects and parses it accordingly (note that in case no markdown link is found, the rest of the given string is processed). It then repeats until the end of string.
	__weak DetectCrossReferencesTask *bself = self;
	NSRegularExpression *expression = [NSRegularExpression gb_markdownLinkMatchingExpression];
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *prefix) {
		LogDebug(@"Appending '%@'...", [prefix gb_description]);
		[bself processAppledocCrossRefsInString:prefix toBuilder:builder options:0];
	} match:^(NSTextCheckingResult *match) {
		NSString *markdown = [match gb_stringAtIndex:0 in:string];
		NSString *link = [match gb_stringAtIndex:1 in:string];
		NSRange markdownRange = [match rangeAtIndex:0];
		NSRange linkRange = [match rangeAtIndex:1];
		NSRange prefixRange = NSMakeRange(markdownRange.location, linkRange.location - markdownRange.location);
		NSRange suffixRange = NSMakeRange(linkRange.location + linkRange.length, markdownRange.length - linkRange.length - prefixRange.length);
		LogDebug(@"Matched Markdown link '%@'...", markdown);
		[builder appendString:[string substringWithRange:prefixRange]];
		[bself processAppledocCrossRefsInString:link toBuilder:builder options:GBCrossRefOptionInsideMarkdownLink];
		[builder appendString:[string substringWithRange:suffixRange]];
	}];
}

- (void)processAppledocCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder options:(GBCrossRefOptions)options {
	// Finds all appledoc cross references in given string. It works by splitting the work into first finding remote member cross refs, and finding inline cross refs in remaining string.
	__weak DetectCrossReferencesTask *bself = self;
	NSDictionary *topLevelObjectsCache = self.store.topLevelObjectsCache;
	NSDictionary *remoteMembersCache = self.store.memberObjectsCache;
	NSRegularExpression *expression = [NSRegularExpression gb_remoteMemberMatchingExpression];
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *prefix) {
		LogDebug(@"Appending '%@'...", [prefix gb_description]);
		[bself processInlineCrossRefsInString:prefix toBuilder:builder options:options];
	} match:^(NSTextCheckingResult *match) {
		// Get match data.
		NSString *description = [match gb_stringAtIndex:0 in:string];
		NSString *prefix = [match gb_stringAtIndex:1 in:string];
		NSString *objectName = [match gb_stringAtIndex:2 in:string];
		NSString *memberName = [match gb_stringAtIndex:3 in:string];
		LogDebug(@"Matched possible appledoc cross ref '%@'...", description);
		
		// Find remote member cross reference in cache. If no prefix is given also try class and instance method variants. Give class precedence...
		NSString *key = [NSString stringWithFormat:@"%@[%@ %@]", prefix, objectName, memberName];
		ObjectInfoBase *object = [bself memberWithKey:key fromCache:remoteMembersCache];
		
		// If found, convert it to cross reference.
		if (object) {
			LogVerbose(@"Matched cross reference '%@'.", description);
			InterfaceInfoBase *interface = topLevelObjectsCache[objectName];
			NSString *format = [NSString stringWithFormat:@"%@%%@", interface.objectCrossRefPathTemplate];
			[builder appendString:[bself stringForCrossRefTo:object description:description options:options format:format]];
			return;
		}
		
		// If not found, just append the given match.
		[builder appendString:description];
	}];
}

- (void)processInlineCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder options:(GBCrossRefOptions)options {
	// Small optimization; if there's no registered object, no need to scan the string, just append it to builder and exit.
	NSDictionary *topLevelObjectsCache = self.store.topLevelObjectsCache;
	NSDictionary *localMembersCache = self.localMembersCache;
	if (topLevelObjectsCache.count == 0 || localMembersCache.count == 0) {
		LogDebug(@"Appending '%@'...", [string gb_description]);
		[builder appendString:string];
		return;
	}

	__weak DetectCrossReferencesTask *bself = self;
	NSRegularExpression *expression = [NSRegularExpression gb_wordMatchingExpression];
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *word) {
		[builder appendString:word];
		LogDebug(@"Appending '%@'...", [delimiter gb_description]);
	} match:^(NSTextCheckingResult *match) {
		LogDebug(@"Testing '%@' for cross ref to known objects...", [match gb_stringAtIndex:0 in:string]);
		// Find cross referenced object.
		NSString *word = [match gb_stringAtIndex:0 in:string];
		ObjectInfoBase *object = topLevelObjectsCache[word];
		if (!object) object = [bself memberWithKey:word fromCache:localMembersCache];
		
		// If found, convert it to cross reference.
		if (object) {
			[builder appendString:[bself stringForCrossRefTo:object description:word options:options format:@"%@"]];
			LogVerbose(@"Matched cross reference '%@'.", object.uniqueObjectID);
			return;
		}
		
		// If not found, just append the word plain as it is.
		[builder appendString:word];
	}];
}

#pragma mark - Helper methods

- (void)enumerateMatchesOf:(NSRegularExpression *)expression in:(NSString *)string prefix:(void(^)(NSString *prefix))prefixBlock match:(GBRegexMatchBlock)matchBlock {
	// Enumerates all matches of the given regular expression in given string. For each match, it calls prefix block passing it the string between the last match and current one, then calls match block passing it the match itself. For last segment (i.e. after the last match), or in case no match is found at all, only prefix block is called with remaining (or whole of the given) string, but match block isn't.
	__block NSRange searchRange = NSMakeRange(0, string.length);
	[expression gb_allMatchesIn:string match:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
		NSString *prefixString = [match gb_prefixFromIndex:searchRange.location in:string];
		if (prefixString.length > 0) prefixBlock(prefixString);
		matchBlock(match);
		searchRange = [match gb_remainingRangeIn:string];
	}];
	if (searchRange.location < string.length) {
		NSString *remainingString = [string substringWithRange:searchRange];
		prefixBlock(remainingString);
	}
}

- (ObjectInfoBase *)memberWithKey:(NSString *)key fromCache:(NSDictionary *)cache {
	// Searches the given cache for a member with the given key. This automatically tries class/instance method prefix if given key is not prefixes.
	ObjectInfoBase *object = cache[key];
	if (object) return object;

	// If given key is not found, check if the key is prefixed with +/-. If yes, we can assume member doesn't exist (cache uses prefixed keys!)
	if ([key hasPrefix:@"+"] || [key hasPrefix:@"-"]) return nil;
	
	// So, the key is not prefixed, try with class variation first.
	NSString *classKey = [NSString stringWithFormat:@"+%@", key];
	ObjectInfoBase *classMember = cache[classKey];
	if (classMember) return classMember;
	
	// If class method wasn't found, try instance method or return nil if not found.
	NSString *instanceKey = [NSString stringWithFormat:@"-%@", key];
	return cache[instanceKey];
}

- (NSString *)stringForCrossRefTo:(ObjectInfoBase *)object description:(NSString *)description options:(GBCrossRefOptions)options format:(NSString *)format {
	// Prepares Markdown link to the given object using the given description and link format.
	NSString *link = [NSString stringWithFormat:format, object.objectCrossRefPathTemplate];
	if ((options & GBCrossRefOptionInsideMarkdownLink) > 0) return link;
	return [NSString stringWithFormat:@"[%@](%@)", description, link];
}

@end
