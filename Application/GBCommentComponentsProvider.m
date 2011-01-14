//
//  GBCommentKeywordsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "GBCommentComponentsProvider.h"

#define GBRETURN_ON_DEMAND(regex) \
	static NSString *result = nil; \
	if (!result) result = regex; \
	return result

#pragma mark -

@interface GBCommentComponentsProvider ()

- (NSString *)argumentsCommonRegex;
- (NSString *)exampleRegexWithoutFlags;
- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword;
- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword;

@end

#pragma mark -

@implementation GBCommentComponentsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[[self alloc] init] autorelease];
}

#pragma mark Lists detection

- (NSString *)orderedListRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?m:%@(.*))", self.orderedListMatchRegex]));
}

- (NSString *)unorderedListRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?m:%@(.*))", self.unorderedListMatchRegex]));
}

- (NSString *)orderedListMatchRegex {
	GBRETURN_ON_DEMAND(@"^([ \\t]*)[0-9]+\\.\\s+");
}

- (NSString *)unorderedListMatchRegex {
	GBRETURN_ON_DEMAND(@"^([ \\t]*)[-+*]\\s+");
}

#pragma mark Sections detection

- (NSString *)warningSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"warning"]);
}

- (NSString *)bugSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"bug"]);
}

- (NSString *)exampleSectionRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?s:%@)", [self exampleRegexWithoutFlags]]));
}

- (NSString *)exampleLinesRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?m:%@)", [self exampleRegexWithoutFlags]]));
}

- (NSString *)exampleRegexWithoutFlags {
	GBRETURN_ON_DEMAND(@"^(?: ?\\t| {2,})(.*))");
	//GBRETURN_ON_DEMAND(@"^[ ]*\\t(.*)");
}

#pragma mark Method specific detection

- (NSString *)methodGroupRegex {
	GBRETURN_ON_DEMAND(@"(?s:\\Sname\\s+(.*))");
}

- (NSString *)argumentsCommonRegex {
	GBRETURN_ON_DEMAND(@"\\s*\\S(param|exception|return|returns|see|sa)\\s+");
}

- (NSString *)argumentsMatchingRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?:^%@)", [self argumentsCommonRegex]]));
}

- (NSString *)nextArgumentRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"(?m:^%@)", [self argumentsCommonRegex]]));
}

- (NSString *)parameterDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"param"]);
}

- (NSString *)returnDescriptionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(?:return|returns)"]);
}

- (NSString *)exceptionDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"exception"]);
}

- (NSString *)crossReferenceRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(?:sa|see)"]);
}

#pragma mark Cross references detection

- (NSString *)remoteMemberCrossReferenceRegex {
	// +[Class member] or -[Class member] or simply [Class member].
	return @"^<?[+-]?\\[(\\S+)\\s+(\\S+)\\]>?";
}

- (NSString *)localMemberCrossReferenceRegex {
	return @"^<?([^>,.;!?()\\s]+)>?";
}

- (NSString *)categoryCrossReferenceRegex {
	return @"^<?([^(][^>,.:;!?)\\s]+\\))>?";
}

- (NSString *)objectCrossReferenceRegex {
	return @"^<?([^>,.:;!?()\\s]+)>?";
}

- (NSString *)urlCrossReferenceRegex {
	return @"^<?(\\b(?:mailto\\:|(?:https?|ftps?|news|rss|file)\\://)[a-zA-Z0-9@:\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?)>?";
}

#pragma mark Common detection

- (NSString *)newLineRegex {
	GBRETURN_ON_DEMAND([NSString stringWithUTF8String:"\\r\\n|[\\n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}]+"]);
}

#pragma mark Helper methods

- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*\\S%@\\s+(?s:(.*))", keyword];
}

- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*\\S%@\\s+([^\\s]+)\\s+(?s:(.*))", keyword];
}

@end
