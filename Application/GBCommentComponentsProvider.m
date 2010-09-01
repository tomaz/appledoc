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

- (NSString *)singleCaptureRegexForKeyword:(NSString *)keyword;
- (NSString *)doubleCaptureRegexForKeyword:(NSString *)keyword;

@end

#pragma mark -

@implementation GBCommentComponentsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[[self alloc] init] autorelease];
}

#pragma mark Public interface

- (NSString *)orderedListRegex {
	GBRETURN_ON_DEMAND(@"^\\s*[0-9]+\\.\\s+(.*)");
}

- (NSString *)unorderedListRegex {
	GBRETURN_ON_DEMAND(([NSString stringWithFormat:@"%@(.*)", self.unorderedListPrefixRegex]));
}

- (NSString *)unorderedListPrefixRegex {
	GBRETURN_ON_DEMAND(@"^\\s*[-+*o]\\s+");
}

- (NSString *)warningSectionRegex {
	GBRETURN_ON_DEMAND([self singleCaptureRegexForKeyword:@"warning"]);
}

- (NSString *)bugSectionRegex {
	GBRETURN_ON_DEMAND([self singleCaptureRegexForKeyword:@"bug"]);
}

- (NSString *)parameterDescriptionRegex {
	GBRETURN_ON_DEMAND([self doubleCaptureRegexForKeyword:@"param"]);
}

- (NSString *)returnDescriptionRegex {
	GBRETURN_ON_DEMAND([self singleCaptureRegexForKeyword:@"return"]);
}

- (NSString *)exceptionDescriptionRegex {
	GBRETURN_ON_DEMAND([self doubleCaptureRegexForKeyword:@"exception"]);
}

- (NSString *)crossReferenceRegex {
	GBRETURN_ON_DEMAND(@"^\\s*.(sa|see)\\s+(.*)");
}

#pragma mark Helper methods

- (NSString *)singleCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*.%@\\s+(.*)", keyword];
}

- (NSString *)doubleCaptureRegexForKeyword:(NSString *)keyword {
	return [NSString stringWithFormat:@"^\\s*.%@\\s+([^\\s]+)\\s+(.*)", keyword];
}

@end
