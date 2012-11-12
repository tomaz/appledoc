//
//  ProcessCommentComponentsTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "ProcessCommentComponentsTask.h"
#import "TestCaseBase.hh"

@implementation CommentComponentInfo (UnitTestingPrivateAPI)
- (BOOL)isEqual:(id)object {
	return [self.sourceString isEqualToString:[object sourceString]];
}
@end

@implementation CommentSectionInfo (UnitTestingPrivateAPI)
- (BOOL)isEqual:(id)object {
	NSArray *objectComponents = [object sectionComponents];
	if (objectComponents.count != self.sectionComponents.count) return NO;
	for (NSUInteger i=0; i<objectComponents.count; i++) {
		if (![objectComponents[i] isEqual:self.sectionComponents[i]]) return NO;
	}
	return YES;
}
@end

@implementation CommentNamedSectionInfo (UnitTestingPrivateAPI)
- (BOOL)isEqual:(id)object {
	if (![self.sectionName isEqualToString:[object sectionName]]) return NO;
	return [super isEqual:object];
}
@end

#pragma mark -

static void runWithTask(void(^handler)(ProcessCommentComponentsTask *task, id comment)) {
	// ProcessCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	ProcessCommentComponentsTask *task = [[ProcessCommentComponentsTask alloc] init];
	id mock = mock([CommentInfo class]);
	handler(task, mock);
	[task release];
}

static void setupComment(id comment, NSString *text) {
	[given([comment sourceString]) willReturn:text];
}

static CommentComponentInfo *component(NSString *first) {
	return [CommentComponentInfo componentWithSourceString:first];
}

static CommentSectionInfo *section(NSString *first, ...) {
	va_list args;
	va_start(args, first);
	CommentSectionInfo *result = [[CommentSectionInfo alloc] init];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		[result.sectionComponents addObject:[CommentComponentInfo componentWithSourceString:arg]];
	}
	va_end(args);
	return result;
}

static NSMutableArray *arguments(NSArray *first, ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *result = [@[] mutableCopy];
	for (NSArray *arg=first; arg!=nil; arg=va_arg(args, NSArray *)) {
		CommentNamedSectionInfo *section = [[CommentNamedSectionInfo alloc] init];
		section.sectionName = arg[0];
		for (NSUInteger i=1; i<arg.count; i++) {
			CommentComponentInfo *component = [CommentComponentInfo componentWithSourceString:arg[i]];
			[section.sectionComponents addObject:component];
		}
		[result addObject:section];
	}
	va_end(args);
	return result;
}

#pragma mark -

@interface ProcessCommentComponentsTask (UnitTestingPrivateAPI)
- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)parent;
@end

#pragma mark -

TEST_BEGIN(ProcessCommentComponentsTaskTests)

describe(@"abstract:", ^{
	it(@"should convert single line to abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"line");
			// execute
			//[task processComment:comment];
			[comment setCommentAbstract:[CommentComponentInfo componentWithSourceString:@"line"]];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"line")]);
		});
	});
	
	it(@"should convert single paragraph composed of multiple lines to abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"line one\nline two\nline three");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"line one\nline two\nline three")]);
		});
	});
});

describe(@"normal text:", ^{
	it(@"should convert second paragraph to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"first\n\nsecond");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"first")]);
			gbcatch([verify(comment) setCommentDiscussion:section(@"second", nil)]);
		});
	});
	
	it(@"should convert second and subsequent paragraphs to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"first\n\nsecond\n\nthird");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"first")]);
			gbcatch([verify(comment) setCommentDiscussion:section(@"second\n\nthird", nil)]);
		});
	});
	
	it(@"should handle multiple paragraphs with mutliple lines", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"first\n\nline one\nline two\nline three\n\nthird paragraph\nand line two");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"first")]);
			gbcatch([verify(comment) setCommentDiscussion:section(@"line one\nline two\nline three\n\nthird paragraph\nand line two", nil)]);
		});
	});
});

describe(@"warnings and bugs:", ^{
	describe(@"as part of abstract:", ^{
		sharedExamplesFor(@"example1", ^(NSDictionary *info) {
			it(@"should take as part of abstract if not delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n%@ text", identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component([NSString gb_format:@"abstract\n%@ text", identifier])]);
				});
			});
		});
				
		sharedExamplesFor(@"example2", ^(NSDictionary *info) {
			it(@"should take as part of abstract and take next paragraph as discussion if not delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n%@ text\n\nparagraph", identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component([NSString gb_format:@"abstract\n%@ text", identifier])]);
					gbcatch([verify(comment) setCommentDiscussion:section(@"paragraph", nil)]);
				});
			});
		});

		describe(@"@warning:", ^{
			beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@warning"; });
			itShouldBehaveLike(@"example1");
			itShouldBehaveLike(@"example2");
		});
		
		describe(@"@bug:", ^{
			beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@bug"; });
			itShouldBehaveLike(@"example1");
			itShouldBehaveLike(@"example2");
		});
	});
	
	describe(@"as part of discussion:", ^{
		sharedExamplesFor(@"example1", ^(NSDictionary *info) {
			it(@"should take as part of discussion if found as first paragraph after abstract", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n\n%@ text", identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
					gbcatch([verify(comment) setCommentDiscussion:section([NSString gb_format:@"%@ text", identifier], nil)]);
				});
			});
		});
		
		sharedExamplesFor(@"example2", ^(NSDictionary *info) {
			it(@"should start new paragraph if delimited by empty line", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n\nparagraph\n\n%@ text", identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
					gbcatch([verify(comment) setCommentDiscussion:section(@"paragraph", [NSString gb_format:@"%@ text", identifier], nil)]);
				});
			});
		});
		
		sharedExamplesFor(@"example3", ^(NSDictionary *info) {
			it(@"should take all subsequent paragraphs as part of section", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n\nparagraph\n\n%@ text\n\nnext paragraph", identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
					gbcatch([verify(comment) setCommentDiscussion:section(@"paragraph", [NSString gb_format:@"%@ text\n\nnext paragraph", identifier], nil)]);
				});
			});
		});
		
		sharedExamplesFor(@"example4", ^(NSDictionary *info) {
			it(@"should start new paragraph with next section directive", ^{
				runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
					// setup
					NSString *identifier = info[@"id"];
					setupComment(comment, [NSString gb_format:@"abstract\n\n%@ first\n\n%@ second", identifier, identifier]);
					// execute
					[task processComment:comment];
					// verify
					gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
					gbcatch([verify(comment) setCommentDiscussion:section([NSString gb_format:@"%@ first", identifier], [NSString gb_format:@"%@ second", identifier], nil)]);
				});
			});
		});
		
		describe(@"@warning:", ^{
			beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@warning"; });
			itShouldBehaveLike(@"example1");
			itShouldBehaveLike(@"example2");
			itShouldBehaveLike(@"example3");
			itShouldBehaveLike(@"example4");
		});
		
		describe(@"@bug:", ^{
			beforeEach(^{ [[SpecHelper specHelper] sharedExampleContext][@"id"] = @"@bug"; });
			itShouldBehaveLike(@"example1");
			itShouldBehaveLike(@"example2");
			itShouldBehaveLike(@"example3");
			itShouldBehaveLike(@"example4");
		});
	});
});

describe(@"method parameters:", ^{
	it(@"should register single parameter:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name description");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentParameters:arguments(@[@"name", @"description"], nil)]);
		});
	});
	
	it(@"should register multiple parameters:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description 1\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentParameters:arguments(@[@"name1", @"description 1"], @[@"name2", @"description 2"], nil)]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@param name1 description1\nin multiple\n\nlines and paragraphs\n\n@param name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentParameters:arguments(@[@"name1", @"description1\nin multiple\n\nlines and paragraphs"], @[@"name2", @"description 2"], nil)]);
		});
	});
});

describe(@"method exceptions:", ^{
	it(@"should register single exception:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name description");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentExceptions:arguments(@[@"name", @"description"], nil)]);
		});
	});
	
	it(@"should register multiple exceptions:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description 1\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentExceptions:arguments(@[@"name1", @"description 1"], @[@"name2", @"description 2"], nil)]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@exception name1 description1\nin multiple\n\nlines and paragraphs\n\n@exception name2 description 2");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentExceptions:arguments(@[@"name1", @"description1\nin multiple\n\nlines and paragraphs"], @[@"name2", @"description 2"], nil)]);
		});
	});
});

describe(@"method return:", ^{
	it(@"should register single return:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentReturn:section(@"description", nil)]);
		});
	});
	
	it(@"should use last return if multiple found:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description 1\n@return description 2");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentReturn:section(@"description 2", nil)]);
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupComment(comment, @"abstract\n\n@return description\nin multiple\n\nlines and paragraphs");
			// execute
			[task processComment:comment];
			// verify
			gbcatch([verify(comment) setCommentAbstract:component(@"abstract")]);
			gbcatch([verify(comment) setCommentReturn:section(@"description\nin multiple\n\nlines and paragraphs", nil)]);
		});
	});
});

TEST_END