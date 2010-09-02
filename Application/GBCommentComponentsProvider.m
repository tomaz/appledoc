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

#pragma mark Public interface

- (NSString *)orderedListRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"^%@(.*)", self.orderedListPrefixRegex]));
}

- (NSString *)orderedListPrefixRegex {
	GBRETURN_ON_DEMAND(@"\\s*[0-9]+\\.\\s+");
}

- (NSString *)unorderedListRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"^%@(.*)", self.unorderedListPrefixRegex]));
}

- (NSString *)unorderedListPrefixRegex {
	GBRETURN_ON_DEMAND(@"\\s*[-+*]\\s+");
}

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
	GBRETURN_ON_DEMAND(@"^[ ]*\\t(.*)");
}

- (NSString *)parameterDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"param"]);
}

- (NSString *)returnDescriptionRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"return"]);
}

- (NSString *)exceptionDescriptionRegex {
	GBRETURN_ON_DEMAND([self nameDescriptionCaptureRegexForKeyword:@"exception"]);
}

- (NSString *)crossReferenceRegex {
	GBRETURN_ON_DEMAND([self descriptionCaptureRegexForKeyword:@"(sa|see)"]);
}

#pragma mark Helper methods

- (NSString *)descriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*.%@\\s+(?s:(.*))", keyword];
}

- (NSString *)nameDescriptionCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*.%@\\s+([^\\s]+)\\s+(?s:(.*))", keyword];
}

@end
