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

@interface ParserRegistratorMock : NSObject
- (id)initWithParser:(CommentParser *)parser;
@property (nonatomic, copy) NSString *groupComment;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, assign) BOOL isCommentInline;
@end

@implementation ParserRegistratorMock
@synthesize groupComment, comment, isCommentInline;
- (id)initWithParser:(CommentParser *)parser {
	self = [super init];
	if (self) {
		__weak ParserRegistratorMock *blockSelf = self;
		parser.groupRegistrator = ^(CommentParser *parser, NSString *group) {
			blockSelf.groupComment = group;
		};
		parser.commentRegistrator = ^(CommentParser *parser, NSString *comment, BOOL isInline) {
			blockSelf.comment = comment;
			blockSelf.isCommentInline = isInline;
		};
	}
	return self;
}
@end

#pragma mark -

static void runWithParser(void(^handler)(CommentParser *parser)) {
	CommentParser *parser = [[CommentParser alloc] init];
	handler(parser);
	[parser release];
}

static void runWithRegistrator(void(^handler)(CommentParser *parser, ParserRegistratorMock *registrator)) {
	runWithParser(^(CommentParser *parser) {
		ParserRegistratorMock *registrator = [[ParserRegistratorMock alloc] initWithParser:parser];
		handler(parser, registrator);
		[registrator release];
	});
}

#pragma mark - 

TEST_BEGIN(CommentParserTests)

describe(@"detecting appledoc comments:", ^{
	describe(@"single line:", ^{
		it(@"should accept triple slash prefixed string", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/// text"] should be_truthy();
			});
		});
		
		it(@"should reject double slash prefixed line", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"// text"] should_not be_truthy();
			});
		});
	});

	describe(@"multi line:", ^{
		it(@"should accept slash double asterisk prefixed string", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/** text"] should be_truthy();
			});
		});
		
		it(@"should reject slash single asterisk prefixed string", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@"/* text"] should_not be_truthy();
			});
		});
	});
	
	describe(@"edge cases:", ^{
		it(@"should reject single line prefixed with whitespace", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@" /// text"] should_not be_truthy();
			});
		});

		it(@"should reject multi line prefixed with whitespace", ^{
			runWithParser(^(CommentParser *parser) {
				// execute & verify
				[parser isAppledocComment:@" /** text"] should_not be_truthy();
			});
		});
	});
});

describe(@"parsing method groups:", ^{
	describe(@"simple cases:", ^{
		it(@"should detect group in single liner", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/// @name name" line:1];
				// verify
				registrator.groupComment should equal(@"name");
				registrator.comment should be_nil();
			});
		});

		it(@"should detect group in multi liner", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** @name name */" line:1];
				// verify
				registrator.groupComment should equal(@"name");
				registrator.comment should be_nil();
			});
		});
	});
	
	describe(@"trimming:", ^{
		it(@"should detect multi word group name", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/// @name word1 word2" line:1];
				// verify
				registrator.groupComment should equal(@"word1 word2");
				registrator.comment should be_nil();
			});
		});
		
		it(@"should trim whitespace inside group name", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/// @name word1  word2 \t word3" line:1];
				// verify
				registrator.groupComment should equal(@"word1 word2 word3");
				registrator.comment should be_nil();
			});
		});
	});
	
	describe(@"mixing group with comment:", ^{
		it(@"should take any text after group line as comment", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** @name name\nhello*/" line:1];
				// verify
				registrator.groupComment should equal(@"name");
				registrator.comment should equal(@"hello");
			});
		});

		it(@"should take as comment if @name is found after some text", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**hello @name name*/" line:1];
				// verify
				registrator.groupComment should be_nil;
				registrator.comment should equal(@"hello @name name");
			});
		});
	});
});

describe(@"parsing comments:", ^{
	describe(@"single line:", ^{
		it(@"should detect one line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///text" line:1];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"text");
			});
		});
		
		it(@"should append multiple lines", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///line2" line:2];
				[parser parseComment:@"///line3" line:3];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should keep in between empty lines", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///" line:2];
				[parser parseComment:@"///line3" line:3];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\n\nline3");
			});
		});
		
		it(@"should notifyAndReset if delimited by at least one non comment line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///line1" line:1];
				[parser parseComment:@"///line2" line:2];
				[parser parseComment:@"///line3" line:4];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line3");
			});
		});
	});
	
	describe(@"multiple lines:", ^{
		it(@"should detect one line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**text*/" line:1];
				// verify
				registrator.comment should equal(@"text");
			});
		});

		it(@"should detect multiple lines", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**line1\nline2\nline3*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2\nline3");
			});
		});
	});
});

describe(@"trimming:", ^{
	describe(@"single line:", ^{
		it(@"should handle no prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**text*/" line:1];
				// verify
				registrator.comment should equal(@"text");
			});
		});
		
		it(@"should trim space prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** text*/" line:1];
				// verify
				registrator.comment should equal(@"text");
			});
		});
		
		it(@"should trim only single space prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**   text*/" line:1];
				// verify
				registrator.comment should equal(@"  text");
			});
		});
		
		it(@"should keep tab prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**\ttext*/" line:1];
				// verify
				registrator.comment should equal(@"\ttext");
			});
		});
		
		it(@"should keep tab prefix but remove single space prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**  \ttext*/" line:1];
				// verify
				registrator.comment should equal(@" \ttext");
			});
		});
	});
		
	describe(@"multiple lines:", ^{
		it(@"should trim space prefix", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** line1\n line2\n line3*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should trim only single space prefix from each line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**   line1\n line2\n  line3*/" line:1];
				// verify
				registrator.comment should equal(@"  line1\nline2\n line3");
			});
		});
		
		it(@"should keep in between new line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**line1\n\nline2\nline3*/" line:1];
				// verify
				registrator.comment should equal(@"line1\n\nline2\nline3");
			});
		});
		
		it(@"should ignore prefix new line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**\nline1\nline2\nline3*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2\nline3");
			});
		});
		
		it(@"should ignore trailing new line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**line1\nline2\nline3\n*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2\nline3");
			});
		});
	});
});

describe(@"inline comments:", ^{
	describe(@"single liners:", ^{
		it(@"should detect with one line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///< comment" line:1];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"comment");
				registrator.isCommentInline should be_truthy();
			});
		});

		it(@"should detect multi line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///< line1" line:1];
				[parser parseComment:@"///< line2" line:2];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should be_truthy();
			});
		});
		
		it(@"should detect multi line with marker in only first line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"///< line1" line:1];
				[parser parseComment:@"/// line2" line:2];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should be_truthy();
			});
		});
		
		it(@"should ignore if marker not in first line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/// line1" line:1];
				[parser parseComment:@"///< line2" line:2];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\n< line2");
				registrator.isCommentInline should_not be_truthy();
			});
		});
		
		it(@"should ignore if no marker", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/// line1" line:1];
				[parser parseComment:@"/// line2" line:2];
				[parser notifyAndReset];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should_not be_truthy();
			});
		});
	});
	
	describe(@"multi liners:", ^{
		it(@"should detect with one line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**< comment*/" line:1];
				// verify
				registrator.comment should equal(@"comment");
				registrator.isCommentInline should be_truthy();
			});
		});

		it(@"should detect multi line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**< line1\n< line2*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should be_truthy();
			});
		});
		
		it(@"should detect with multi line with marker only in first line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**< line1\n line2*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should be_truthy();
			});
		});
		
		it(@"should ignore if marker not in first line", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** line1\n< line2*/" line:1];
				// verify
				registrator.comment should equal(@"line1\n< line2");
				registrator.isCommentInline should_not be_truthy();
			});
		});
		
		it(@"should ignore if marker missing", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** line1\n line2*/" line:1];
				// verify
				registrator.comment should equal(@"line1\nline2");
				registrator.isCommentInline should_not be_truthy();
			});
		});
	});
	
	describe(@"edge cases:", ^{
		it(@"should ignore group", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/**< @name name*/" line:1];
				// verify
				registrator.groupComment should be_nil();
				registrator.comment should equal(@"@name name");
				registrator.isCommentInline should be_truthy();
			});
		});

		it(@"should detect group and inline", ^{
			runWithRegistrator(^(CommentParser *parser, ParserRegistratorMock *registrator) {
				// execute
				[parser parseComment:@"/** @name name\n< comment*/" line:1];
				// verify
				registrator.groupComment should equal(@"name");
				registrator.comment should equal(@"comment");
				registrator.isCommentInline should be_truthy();
			});
		});
	});
});

TEST_END
