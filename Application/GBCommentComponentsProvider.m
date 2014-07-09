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

- (NSString *)crossReferenceRegexForRegex:(NSString *)regex;
- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword;
- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword;

@end

#pragma mark -

@implementation GBCommentComponentsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[self alloc] init];
}

- (id)init {
	self = [super init];
	if (self) {
		self.crossReferenceMarkersTemplate = @"<?%@>?";
	}
	return self;
}

#pragma mark Sections detection

- (NSString *)abstractRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(abstract|brief)"]);
}

- (NSString *)discussionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(discussion|details)"]);
}

- (NSString *)noteSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"note"]);
}

- (NSString *)warningSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"warning"]);
}

- (NSString *)bugSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"bug"]);
}

- (NSString *)deprecatedSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"deprecated"]);
}

#pragma mark Method specific detection

- (NSString *)methodGroupRegex {
	GBRETURN_ON_DEMAND(@"(?m:^\\s*\\Sname\\s+(.*))");
}

- (NSString *)parameterDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"param"]);
}

- (NSString *)returnDescriptionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(?:return|returns|result)"]);
}

- (NSString *)exceptionDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"exception"]);
}

- (NSString *)relatedSymbolRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(?:sa|see)"]);
}

- (NSString *)availabilityRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(?:available|since)"]);
}

#pragma mark Markdown detection

- (NSString *)markdownInlineLinkRegex {
	GBRETURN_ON_DEMAND(@"(?:\\[((?:[^]]+)|(?:\\[[^]]+\\]))\\]\\(([^\\s]+)(?:\\s*\"([^\"]+)\")?\\))");
}

- (NSString *)markdownReferenceLinkRegex {
	GBRETURN_ON_DEMAND(@"(?s:\\[([^]]+)\\]:\\s*([^\\s]+)(?:\\s*\"([^\"]+)\")?\\s*$)");
}

#pragma mark Cross references detection

- (NSString *)remoteMemberCrossReferenceRegex:(BOOL)templated {
	// +[Class member] or -[Class member] or simply [Class member].
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self remoteMemberCrossReferenceRegex:NO]]);
	} else {
        GBRETURN_ON_DEMAND(@"\\[([^\\]]+)\\]\\([<]?[+-]?\\[([^]\\s]+)\\s+([^]\\s]+)\\][>]?\\)|[<]?([+-]?)\\[([^]\\s]+)\\s+([^]\\s]+)\\][>]?");
	}
}

- (NSString *)localMemberCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self localMemberCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"([+-]?)([^>,.;!?()\\s]+)");
	}
}

- (NSString *)categoryCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self categoryCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"([^(][^>,.:;!?)\\s]+\\))");
	}
}

- (NSString *)objectCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self objectCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"([^>,.:;!?()\\s]+)");
	}
}

- (NSString *)documentCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self objectCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"([^>,.:;!?()\\s]+)");
	}
}

- (NSString *)urlCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self urlCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"(\\b(?:mailto\\:|(?:https?|ftps?|news|rss|file)\\://)[a-zA-Z0-9@:\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?)");
	}
}

#pragma mark Common detection

- (NSString *)newLineRegex {
	GBRETURN_ON_DEMAND([NSString stringWithUTF8String:"\\r\\n|[\\n\\v\\f\\r\302\205\\p{Zl}\\p{Zp}]+"]);
}

#pragma mark Helper methods

- (NSString *)crossReferenceRegexForRegex:(NSString *)regex {
	return [NSString stringWithFormat:self.crossReferenceMarkersTemplate, regex];
}

- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*(\\S%@\\s+)(?s:(.*))", keyword];
}

- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*(\\S%@\\s+)(\\S+)\\s+(?s:(.*))", keyword];
}

#pragma mark Custom markers

- (NSString *)codeSpanStartMarker {
	return @"~!@";
}

- (NSString *)codeSpanEndMarker {
	return @"@!~";
}

- (NSString *)appledocBoldStartMarker {
	return @"~!$";
}

- (NSString *)appledocBoldEndMarker {
	return @"$!~";
}

#pragma Properties

@synthesize crossReferenceMarkersTemplate;

@end
