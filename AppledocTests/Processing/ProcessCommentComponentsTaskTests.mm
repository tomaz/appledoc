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

static void runWithTask(void(^handler)(ProcessCommentComponentsTask *task, id comment)) {
	// ProcessCommentComponentsTask doesn't need store/settings/object/context, so we can get away with only giving it the comment.
	ProcessCommentComponentsTask *task = [[ProcessCommentComponentsTask alloc] init];
	id mock = [OCMockObject niceMockForClass:[CommentInfo class]];
	handler(task, mock);
	[task release];
}

static void setupCommentText(id comment, NSString *text) {
	[[[comment stub] andReturn:text] sourceString];
}

static BOOL matchComponentArray(NSArray *actual, NSString *first, ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *expected = [@[] mutableCopy];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		[expected addObject:arg];
	}
	va_end(args);
	
	if (actual.count != expected.count) return NO;
	for (NSUInteger i=0; i<actual.count; i++) {
		NSString *actualString = [actual[i] sourceString];
		NSString *expectedString = expected[i];
		if (![actualString isEqualToString:expectedString]) return NO;
	}
	return YES;
}

static BOOL matchNamedArray(NSArray *actual, NSDictionary *first, ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *expected = [@[] mutableCopy];
	for (NSDictionary *arg=first; arg!=nil; arg=va_arg(args, NSDictionary *)) {
		[expected addObject:arg];
	}
	va_end(args);
	
	if (actual.count != expected.count) return NO;
	for (NSUInteger i=0; i<actual.count; i++) {
		CommentNamedSectionInfo *actualItem = actual[i];
		NSDictionary *expectedItem = expected[i];
		
		// If there's no name key in the dictionary, fail.
		NSString *expectedString = [expectedItem objectForKey:actualItem.sectionName];
		if (!expectedString) return NO;
		
		// Compose all components into a single string delimited by empty lines.
		NSMutableString *actualString = [@"" mutableCopy];
		[actualItem.sectionComponents enumerateObjectsUsingBlock:^(CommentComponentInfo *component, NSUInteger idx, BOOL *stop) {
			if (actualString.length > 0) [actualString appendString:@"\n\n"];
			[actualString appendString:component.sourceString];
		}];
		
		// If the two strings don't match, exit.
		if (![actualString isEqualToString:expectedString]) return NO;
	}
	return YES;
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
			setupCommentText(comment, @"line");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"line"];
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should convert single paragraph composed of multiple lines to abstract", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"line one\nline two\nline three");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"line one\nline two\nline three"];
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
});
	
describe(@"discussion:", ^{
	it(@"should convert second paragraph to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"first\n\nsecond");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"first"];
			}]];
			[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchComponentArray(array, @"second", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});

	it(@"should convert second and subsequent paragraphs to discussion", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"first\n\nsecond\n\nthird");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"first"];
			}]];
			[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchComponentArray(array, @"second", @"third", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});

	it(@"should handle multiple paragraphs with mutliple lines", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"first\n\nline one\nline two\nline three\n\nthird paragraph\nand line two");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"first"];
			}]];
			[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchComponentArray(array, @"line one\nline two\nline three", @"third paragraph\nand line two", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
});
	
describe(@"@warning:", ^{
	describe(@"as part of abstract:", ^{
		it(@"should take as part of abstract if not delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n@warning text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract\n@warning text"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should take as part of abstract and take next paragraph as discussion if not delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n@warning text\n\nparagraph");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract\n@warning text"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
	
	describe(@"as part of discussion:", ^{
		it(@"should take as part of discussion if found as first paragraph after abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\n@warning text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"@warning text", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph if delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\nparagraph\n\n@warning text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", @"@warning text", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph after next empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\nparagraph\n\n@warning text\n\nnext paragraph");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", @"@warning text", @"next paragraph", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph with next @warning directive", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\n@warning first\n\n@warning second");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"@warning first", @"@warning second", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
});

describe(@"@bug:", ^{
	describe(@"as part of abstract:", ^{
		it(@"should take as part of abstract if not delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n@bug text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract\n@bug text"];
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should take as part of abstract and take next paragraph as discussion", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n@bug text\n\nparagraph");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract\n@bug text"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
	
	describe(@"as part of discussion:", ^{
		it(@"should take as part of discussion if found as first paragraph after abstract", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\n@bug text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"@bug text", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph if delimited by empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\nparagraph\n\n@bug text");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", @"@bug text", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph after next empty line", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\nparagraph\n\n@bug text\n\nnext paragraph");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"paragraph", @"@bug text", @"next paragraph", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
		
		it(@"should start new paragraph with next @bug directive", ^{
			runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
				// setup
				setupCommentText(comment, @"abstract\n\n@bug first\n\n@bug second");
				[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
					return [info.sourceString isEqualToString:@"abstract"];
				}]];
				[[comment expect] setCommentDiscussion:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
					return matchComponentArray(array, @"@bug first", @"@bug second", nil);
				}]];
				// execute
				[task processComment:comment];
				// verify
				^{ [comment verify]; } should_not raise_exception();
			});
		});
	});
});


describe(@"@param:", ^{
	it(@"should register single parameter:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@param name description");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentParameters:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name": @"description"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should register multiple parameters:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@param name1 description 1\n@param name2 description 2");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentParameters:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name1": @"description 1"}, @{@"name2": @"description 2"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@param name1 description1\nin multiple\n\nlines and paragraphs\n\n@param name2 description 2");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentParameters:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name1": @"description1\nin multiple\n\nlines and paragraphs"}, @{@"name2": @"description 2"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
});

describe(@"@exception:", ^{
	it(@"should register single exception:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@exception name description");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentExceptions:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name": @"description"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should register multiple exceptions:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@exception name1 description 1\n@exception name2 description 2");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentExceptions:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name1": @"description 1"}, @{@"name2": @"description 2"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@exception name1 description1\nin multiple\n\nlines and paragraphs\n\n@exception name2 description 2");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentExceptions:[OCMArg checkWithBlock:^BOOL(NSMutableArray *array) {
				return matchNamedArray(array, @{@"name1": @"description1\nin multiple\n\nlines and paragraphs"}, @{@"name2": @"description 2"}, nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
});

describe(@"@return:", ^{
	it(@"should register single return:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@return description");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentReturn:[OCMArg checkWithBlock:^BOOL(CommentSectionInfo *info) {
				return matchComponentArray(info.sectionComponents, @"description", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should use last return if multiple found:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@return description 1\n@return description 2");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentReturn:[OCMArg checkWithBlock:^BOOL(CommentSectionInfo *info) {
				return matchComponentArray(info.sectionComponents, @"description 2", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
	
	it(@"should take all paragraphs following directive as part of directive:", ^{
		runWithTask(^(ProcessCommentComponentsTask *task, id comment) {
			// setup
			setupCommentText(comment, @"abstract\n\n@return description\nin multiple\n\nlines and paragraphs");
			[[comment expect] setCommentAbstract:[OCMArg checkWithBlock:^BOOL(CommentComponentInfo *info) {
				return [info.sourceString isEqualToString:@"abstract"];
			}]];
			[[comment expect] setCommentReturn:[OCMArg checkWithBlock:^BOOL(CommentSectionInfo *info) {
				return matchComponentArray(info.sectionComponents, @"description\nin multiple", @"lines and paragraphs", nil);
			}]];
			// execute
			[task processComment:comment];
			// verify
			^{ [comment verify]; } should_not raise_exception();
		});
	});
});

TEST_END