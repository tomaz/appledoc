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
- (NSString *)crossReferenceRegexForRegex:(NSString *)regex;
- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword;
- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword;

@end

#pragma mark -

@implementation GBCommentComponentsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		self.crossReferenceMarkersTemplate = @"<?%@>?";
	}
	return self;
}

#pragma mark Lists detection

- (NSString *)orderedListRegex {
	GBRETURN_ON_DEMAND(@"^([ \\t]*)[0-9]+\\.\\s+(?s:(.*))");
}

- (NSString *)unorderedListRegex {
	GBRETURN_ON_DEMAND(@"^([ \\t]*)[-+*]\\s+(?s:(.*))");
}

#pragma mark Sections detection

- (NSString *)warningSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"warning"]);
}

- (NSString *)bugSectionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"bug"]);
}

- (NSString *)exampleSectionRegex {
	GBRETURN_ON_DEMAND(@"^( ?\\t|    )(.*)$");
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

- (NSString *)remoteMemberCrossReferenceRegex:(BOOL)templated {
	// +[Class member] or -[Class member] or simply [Class member].
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self remoteMemberCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"[+-]?\\[(\\S+)\\s+(\\S+)\\]");
	}
}

- (NSString *)localMemberCrossReferenceRegex:(BOOL)templated {
	if (templated) {
		GBRETURN_ON_DEMAND([self crossReferenceRegexForRegex:[self localMemberCrossReferenceRegex:NO]]);
	} else {
		GBRETURN_ON_DEMAND(@"([^>,.;!?()\\s]+)");
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
	return [NSString stringWithFormat:@"^\\s*\\S%@\\s+(?s:(.*))", keyword];
}

- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*\\S%@\\s+(\\S+)\\s+(?s:(.*))", keyword];
}

#pragma Properties

@synthesize crossReferenceMarkersTemplate;

@end
