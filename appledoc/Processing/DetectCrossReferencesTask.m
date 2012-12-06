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
@property (nonatomic, strong) NSRegularExpression *remoteMemberCrossRefMatchingExpression;
@property (nonatomic, strong) NSRegularExpression *inlineCrossRefMatchingExpression;
@property (nonatomic, strong) NSString *inlineCrossRefOutputFormat;
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
	NSRegularExpression *expression = self.remoteMemberCrossRefMatchingExpression;
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
			NSString *crossref = [bself stringForCrossRefToObject:interface member:object description:description format:nil options:options];
			[builder appendString:crossref];
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
	NSRegularExpression *expression = self.inlineCrossRefMatchingExpression;
	NSString *inlineOutputFormat = self.inlineCrossRefOutputFormat;
	[self enumerateMatchesOf:expression in:string prefix:^(NSString *delimiter) {
		LogDebug(@"Appending '%@'...", [delimiter gb_description]);
		[builder appendString:delimiter];
	} match:^(NSTextCheckingResult *match) {
		LogDebug(@"Testing '%@' for cross ref to known objects...", [match gb_stringAtIndex:0 in:string]);
		
		// Find cross referenced object.
		NSString *word = [match gb_stringAtIndex:1 in:string];
		ObjectInfoBase *object = topLevelObjectsCache[word];
		if (!object) object = [bself memberWithKey:word fromCache:localMembersCache];
		
		// If found, convert it to cross reference.
		if (object) {
			LogVerbose(@"Matched cross reference '%@'.", object.uniqueObjectID);
			NSString *crossref = [bself stringForCrossRefToObject:nil member:object description:word format:inlineOutputFormat options:options];
			[builder appendString:crossref];
			return;
		}
		
		// If not found, just append the word plain as it is.
		[builder appendString:word];
	}];
}

#pragma mark - Detection regex and parameters handling

- (NSRegularExpression *)remoteMemberCrossRefMatchingExpression {
	if (_remoteMemberCrossRefMatchingExpression) return _remoteMemberCrossRefMatchingExpression;
	LogDebug(@"Initializing remote member cross reference matching regex due to first access...");
	NSRegularExpression *expression = [NSRegularExpression gb_remoteMemberMatchingExpression];
	_remoteMemberCrossRefMatchingExpression = [self crossRefExpressionFromSource:expression outputFormat:^(NSString *format) { }];
	return _remoteMemberCrossRefMatchingExpression;
}

- (NSRegularExpression *)inlineCrossRefMatchingExpression {
	if (_inlineCrossRefMatchingExpression) return _inlineCrossRefMatchingExpression;
	LogDebug(@"Initializing inline cross reference matching regex due to first access...");
	__weak DetectCrossReferencesTask *bself = self;
	NSRegularExpression *expression = [NSRegularExpression gb_wordMatchingExpression];
	_inlineCrossRefMatchingExpression = [self crossRefExpressionFromSource:expression outputFormat:^(NSString *format) {
		bself.inlineCrossRefOutputFormat = format;
	}];
	return _inlineCrossRefMatchingExpression;
}

- (NSRegularExpression *)crossRefExpressionFromSource:(NSRegularExpression *)source outputFormat:(void(^)(NSString *format))outputFormat {
	// Prepare cross references format from settings. Note that in case of custom format, we simply use the given string. If the user doesn't include `%@` inside the format, we assume it's plain format and use default one.
	NSString *format = self.settings.crossRefsFormat;
	if ([self.settings.crossRefsFormat isEqualToString:@"explicit"])
		format = @"<%@>:/[$](%)/";
	else if ([self.settings.crossRefsFormat isEqualToString:@"codespan"])
		format = @"`%@`:/[`$`](%)/";
	else if (![self.settings.crossRefsFormat gb_contains:@"%@"])
		format = nil;
	
	// If format is not given, just use default regex.
	if (!format) return source;
	
	// We only need the pattern, ignore output format here, but do report it to the given block.
	__block NSString *matcherFormat = nil;
	[self crossRefFormatFrom:format matcher:^(NSString *format) {
		matcherFormat = format;
	} output:^(NSString *format) {
		outputFormat(format);
	}];

	// If format is given, extract the pattern and options out of the given source regex and create new one with derived pattern and same options. If new regex creation fails (i.e. invalid pattern given by user), log the error and revert to source regex.
	NSError *error = nil;
	NSString *pattern = [NSString stringWithFormat:matcherFormat, source.pattern];
	NSRegularExpressionOptions options = source.options;
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
	if (!expression) {
		LogNSError(error, @"Invalid cross reference pattern '%@' (derived from format '%@')!", pattern, format);
		return source;
	}
	
	// We now have valid derived regex, so use it.
	return expression;
}

- (void)crossRefFormatFrom:(NSString *)string matcher:(void(^)(NSString *format))matcherBlock output:(void(^)(NSString *format))outputBlock {
	LogDebug(@"Initializing cross reference regex from format '%@'...", string);
	
	// Find output format in the given string. If not found, report the whole string as the matcher.
	NSRegularExpression *formatRegex = [NSRegularExpression gb_crossRefOutputFormatMatchingExpression];
	NSArray *matches = [formatRegex gb_allMatchesIn:string];
	if (matches.count == 0) {
		matcherBlock(string);
		return;
	}

	// If multiple matches are found, take the last one. If it starts at the beginning of the string, assume it's just the format user wants and report it as such.
	NSTextCheckingResult *match = [matches lastObject];
	if (match.range.location == 0) {
		matcherBlock(string);
		return;
	}

	// So we have both, the matcher and output formats. Validate output for required placeholders; if either is missing, report error and take the whole string as format.
	NSString *outputFormat = [match gb_stringAtIndex:1 in:string];
	if (![outputFormat gb_contains:@"$"] && ![outputFormat gb_contains:@"%"]) {
		LogError(@"Missing $ or % placeholder in output format '%@' (specified through cross ref format '%@')!", outputFormat, string);
		matcherBlock(string);
		return;
	}
	
	// Both formats are valid, report both.
	matcherBlock([string substringToIndex:match.range.location]);
	outputBlock(outputFormat);
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

- (NSString *)stringForCrossRefToObject:(ObjectInfoBase *)object member:(ObjectInfoBase *)member description:(NSString *)description format:(NSString *)format options:(GBCrossRefOptions)options {
	// Prepares Markdown link to the given member of the given object (optional) using the given description and link format.
	NSString *link = member.objectCrossRefPathTemplate;
	if (object) link = [NSString stringWithFormat:@"%@%@", object.objectCrossRefPathTemplate, link];
	if ((options & GBCrossRefOptionInsideMarkdownLink) > 0) return link;
	if (!format) format = @"[$](%)";
	return [format gb_stringByReplacing:@{ @"$":description, @"%":link }];
}

@end
