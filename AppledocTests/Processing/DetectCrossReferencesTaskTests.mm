//
//  DetectCrossReferencesTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 24/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "DetectCrossReferencesTask.h"
#import "TestCaseBase.hh"

@interface DetectCrossReferencesTask (UnitTestingPrivateAPI)
- (void)processCrossRefsInString:(NSString *)string toBuilder:(NSMutableString *)builder;
@end

#pragma mark -

static void runWithTask(void(^handler)(DetectCrossReferencesTask *task, id comment)) {
	DetectCrossReferencesTask *task = [[DetectCrossReferencesTask alloc] init];
	CommentInfo *comment = [[CommentInfo alloc] init];
	handler(task, comment);
	[task release];
}

static void runWithBuilder(void(^handler)(DetectCrossReferencesTask *task, id builder)) {
	DetectCrossReferencesTask *task = [[DetectCrossReferencesTask alloc] init];
	NSMutableString *builder = [@"" mutableCopy];
	handler(task, builder);
	[task release];
}

static id setupComponent(id component, NSString *string) {
	if ([component isKindOfClass:[CommentComponentInfo class]])
		[component setSourceString:string];
	else
		[given([component sourceString]) willReturn:string];
	return component;
}

static id setupSection(id section, NSString *first ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *components = [@[] mutableCopy];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		id component = mock([CommentComponentInfo class]);
		setupComponent(component, arg);
		[components addObject:component];
	}
	va_end(args);
	if ([section isKindOfClass:[CommentSectionInfo class]])
		[section setSectionComponents:components];
	else
		[given([section sectionComponents]) willReturn:components];
	return section;
}

#pragma mark -

TEST_BEGIN(DetectCrossReferencesTaskTests)

describe(@"comment components processing:", ^{
	it(@"should process all components", ^{
		runWithTask(^(DetectCrossReferencesTask *task, CommentInfo *comment) {
			// setup
			comment.commentAbstract = setupComponent(mock([CommentComponentInfo class]), @"");
			comment.commentDiscussion = setupSection(mock([CommentSectionInfo class]), @"", nil);
			comment.commentParameters = mock([NSMutableArray class]);
			comment.commentExceptions = mock([NSMutableArray class]);
			comment.commentReturn = setupSection(mock([CommentSectionInfo class]), @"", nil);
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment.commentAbstract) sourceString]);
			gbcatch([verify(comment.commentDiscussion) sectionComponents]);
			gbcatch([verify(comment.commentParameters) enumerateObjectsUsingBlock:(id)anything()]);
			gbcatch([verify(comment.commentExceptions) enumerateObjectsUsingBlock:(id)anything()]);
			gbcatch([verify(comment.commentReturn) sectionComponents]);
		});
	});
});

describe(@"markdown links:", ^{
	it(@"should handle simple link only string", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"[text](path)" toBuilder:builder];
			// verify
			builder should equal(@"[text](path)");
		});
	});

	it(@"should handle simple link only string", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"[text](path \"title\")" toBuilder:builder];
			// verify
			builder should equal(@"[text](path \"title\")");
		});
	});
	
	it(@"should keep prefix", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"prefix [text](path)" toBuilder:builder];
			// verify
			builder should equal(@"prefix [text](path)");
		});
	});
	
	it(@"should keep prefix and suffix", ^{
		runWithBuilder(^(DetectCrossReferencesTask *task, id builder) {
			// execute
			[task processCrossRefsInString:@"prefix [text](path) suffix" toBuilder:builder];
			// verify
			builder should equal(@"prefix [text](path) suffix");
		});
	});
});

TEST_END
