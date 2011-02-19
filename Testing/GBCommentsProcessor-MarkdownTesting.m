//
//  GBCommentsProcessor-MarkdownTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 19.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessorMarkdownTesting : GBObjectsAssertor

- (GBCommentsProcessor *)defaultProcessor;
- (GBStore *)defaultStore;
- (void)assertComment:(GBComment *)comment matchesLongDescMarkdown:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

@end

#pragma mark -

@implementation GBCommentsProcessorMarkdownTesting

#pragma mark Text blocks handling

- (void)testProcessCommentWithContextStore_markdown_shouldHandleSimpleText {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\nAnother paragraph"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text\n\nAnother paragraph", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertWarning {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@warning Another paragraph\n\nAnd another"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text", @"> %warning%\n> Another paragraph\n> \n> And another", nil];
}

- (void)testProcessCommentWithContextStore_markdown_shouldConvertBug {
	// setup
	GBStore *store = [self defaultStore];
	GBCommentsProcessor *processor = [self defaultProcessor];
	GBComment *comment = [GBComment commentWithStringValue:@"Some text\n\n@bug Another paragraph\n\nAnd another"];
	// execute
	[processor processComment:comment withContext:nil store:store];
	// verify
	[self assertComment:comment matchesLongDescMarkdown:@"Some text", @"> %bug%\n> Another paragraph\n> \n> And another", nil];
}

#pragma mark Creation methods

- (GBCommentsProcessor *)defaultProcessor {
	return [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
}

- (GBStore *)defaultStore {
	return [GBTestObjectsRegistry store];
}

#pragma mark Assertion methods

- (void)assertComment:(GBComment *)comment matchesLongDescMarkdown:(NSString *)first, ... {
	NSMutableArray *expectations = [NSMutableArray array];
	va_list args;
	va_start(args, first);
	for (NSString *arg=first; arg != nil; arg=va_arg(args, NSString*)) {
		[expectations addObject:arg];
	}
	va_end(args);
	
	assertThatInteger([comment.longDescription.components count], equalToInteger([expectations count]));
	for (NSUInteger i=0; i<[expectations count]; i++) {
		GBCommentComponent *component = [comment.longDescription.components objectAtIndex:i];
		NSString *expected = [expectations objectAtIndex:i];
		assertThat(component.markdownValue, is(expected));
	}
}

@end
