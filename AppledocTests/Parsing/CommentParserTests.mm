//
//  CommentParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 6/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Extensions.h"
#import "CommentParser.h"
#import "TestCaseBase.hh"

static void runWithCommentParser(void(^handler)(CommentParser *parser)) {
	CommentParser *parser = [[CommentParser alloc] init];
	handler(parser);
	[parser release];
}

#pragma mark - 

TEST_BEGIN(CommentParserTests)

describe(@"detecting appledoc comments:", ^{
	describe(@"single line:", ^{
		it(@"should accept triple slash prefixed string", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/// text"] should be_truthy();
			});
		});
		
		it(@"should reject double slash prefixed line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"// text"] should_not be_truthy();
			});
		});
	});

	describe(@"multi line:", ^{
		it(@"should accept slash double asterisk prefixed string", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/** text"] should be_truthy();
			});
		});
		
		it(@"should reject slash single asterisk prefixed string", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/* text"] should_not be_truthy();
			});
		});
	});
	
	describe(@"edge cases:", ^{
		it(@"should reject single line prefixed with whitespace", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@" /// text"] should_not be_truthy();
			});
		});

		it(@"should reject multi line prefixed with whitespace", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@" /** text"] should_not be_truthy();
			});
		});
	});
});

describe(@"parsing method groups:", ^{
	describe(@"simple cases:", ^{
		it(@"should detect group in single liner", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/// @name name" line:1];
				// verify
				parser.groupComment should equal(@"name");
				parser.comment should be_nil();
			});
		});

		it(@"should detect group in multi liner", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** @name name */" line:1];
				// verify
				parser.groupComment should equal(@"name");
				parser.comment should be_nil();
			});
		});
	});
	
	describe(@"trimming:", ^{
		it(@"should detect multi word group name", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/// @name word1 word2" line:1];
				// verify
				parser.groupComment should equal(@"word1 word2");
				parser.comment should be_nil();
			});
		});
		
		it(@"should trim whitespace inside group name", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/// @name word1  word2 \t word3" line:1];
				// verify
				parser.groupComment should equal(@"word1 word2 word3");
				parser.comment should be_nil();
			});
		});
	});
	
	describe(@"mixing group with comment:", ^{
		it(@"should take any text after group line as comment", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** @name name\nhello*/" line:1];
				// verify
				parser.groupComment should equal(@"name");
				parser.comment should equal(@"hello");
			});
		});

		it(@"should take as comment if @name is found after some text", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**hello @name name*/" line:1];
				// verify
				parser.groupComment should be_nil;
				parser.comment should equal(@"hello @name name");
			});
		});
	});
});

describe(@"parsing comments:", ^{
	describe(@"single line:", ^{
		it(@"should detect one line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///text" line:1];
				// verify
				parser.comment should equal(@"text");
			});
		});
		
		it(@"should append multiple lines", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///line2" line:2];
				[parser parseComment:@"///line3" line:3];
				// verify
				parser.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should keep in between empty lines", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///" line:2];
				[parser parseComment:@"///line3" line:3];
				// verify
				parser.comment should equal(@"line1\n\nline3");
			});
		});
		
		it(@"should reset if delimited by at least one non comment line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///line2" line:2];
				[parser parseComment:@"///line3" line:4];
				// verify
				parser.comment should equal(@"line3");
			});
		});
	});
	
	describe(@"multiple lines:", ^{
		it(@"should detect one line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**text*/" line:1];
				// verify
				parser.comment should equal(@"text");
			});
		});

		it(@"should detect multiple lines", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**line1\nline2\nline3*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2\nline3");
			});
		});
	});
});

describe(@"trimming:", ^{
	describe(@"single line:", ^{
		it(@"should handle no prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**text*/" line:1];
				// verify
				parser.comment should equal(@"text");
			});
		});
		
		it(@"should trim space prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** text*/" line:1];
				// verify
				parser.comment should equal(@"text");
			});
		});
		
		it(@"should trim only single space prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**   text*/" line:1];
				// verify
				parser.comment should equal(@"  text");
			});
		});
		
		it(@"should keep tab prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**\ttext*/" line:1];
				// verify
				parser.comment should equal(@"\ttext");
			});
		});
		
		it(@"should keep tab prefix but remove single space prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**  \ttext*/" line:1];
				// verify
				parser.comment should equal(@" \ttext");
			});
		});
	});
		
	describe(@"multiple lines:", ^{
		it(@"should trim space prefix", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** line1\n line2\n line3*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should trim only single space prefix from each line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**   line1\n line2\n  line3*/" line:1];
				// verify
				parser.comment should equal(@"  line1\nline2\n line3");
			});
		});
		
		it(@"should keep in between new line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**line1\n\nline2\nline3*/" line:1];
				// verify
				parser.comment should equal(@"line1\n\nline2\nline3");
			});
		});
		
		it(@"should ignore prefix new line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**\nline1\nline2\nline3*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should ignore trailing new line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**line1\nline2\nline3\n*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2\nline3");
			});
		});
	});
});

describe(@"inline comments:", ^{
	describe(@"single liners:", ^{
		it(@"should detect with one line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///< comment" line:1];
				// verify
				parser.comment should equal(@"comment");
				parser.isCommentInline should be_truthy();
			});
		});

		it(@"should detect multi line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///< line1" line:1];
				[parser parseComment:@"///< line2" line:2];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should be_truthy();
			});
		});
		
		it(@"should detect multi line with marker in only first line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"///< line1" line:1];
				[parser parseComment:@"/// line2" line:2];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should be_truthy();
			});
		});
		
		it(@"should ignore if marker not in first line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/// line1" line:1];
				[parser parseComment:@"///< line2" line:2];
				// verify
				parser.comment should equal(@"line1\n< line2");
				parser.isCommentInline should_not be_truthy();
			});
		});
		
		it(@"should ignore if no marker", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/// line1" line:1];
				[parser parseComment:@"/// line2" line:2];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should_not be_truthy();
			});
		});
	});
	
	describe(@"multi liners:", ^{
		it(@"should detect with one line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**< comment*/" line:1];
				// verify
				parser.comment should equal(@"comment");
				parser.isCommentInline should be_truthy();
			});
		});

		it(@"should detect multi line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**< line1\n< line2*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should be_truthy();
			});
		});
		
		it(@"should detect with multi line with marker only in first line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**< line1\n line2*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should be_truthy();
			});
		});
		
		it(@"should ignore if marker not in first line", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** line1\n< line2*/" line:1];
				// verify
				parser.comment should equal(@"line1\n< line2");
				parser.isCommentInline should_not be_truthy();
			});
		});
		
		it(@"should ignore if marker missing", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** line1\n line2*/" line:1];
				// verify
				parser.comment should equal(@"line1\nline2");
				parser.isCommentInline should_not be_truthy();
			});
		});
	});
	
	describe(@"edge cases:", ^{
		it(@"should ignore group", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/**< @name name*/" line:1];
				// verify
				parser.groupComment should be_nil();
				parser.comment should equal(@"@name name");
				parser.isCommentInline should be_truthy();
			});
		});

		it(@"should detect group and inline", ^{
			runWithCommentParser(^(CommentParser *parser) {
				// execute
				[parser parseComment:@"/** @name name\n< comment*/" line:1];
				// verify
				parser.groupComment should equal(@"name");
				parser.comment should equal(@"comment");
				parser.isCommentInline should be_truthy();
			});
		});
	});
});

describe(@"resetting:", ^{
	it(@"should set everything to nil", ^{
		runWithCommentParser(^(CommentParser *parser) {
			// setup
			[parser parseComment:@"/** @name name\n< comment */" line:1];
			// execute
			[parser reset];
			// verify
			parser.groupComment should be_nil();
			parser.comment should be_nil();
			parser.isCommentInline should_not be_truthy();
		});
	});
});

TEST_END
