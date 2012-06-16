//
//  ObjectiveCParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCFileState.h"
#import "ObjectiveCInterfaceState.h"
#import "ObjectiveCPropertyState.h"
#import "ObjectiveCMethodState.h"
#import "ObjectiveCPragmaMarkState.h"
#import "ObjectiveCEnumState.h"
#import "ObjectiveCStructState.h"
#import "ObjectiveCConstantState.h"
#import "ObjectiveCParser.h"
#import "CommentParser.h"
#import "TestCaseBase.hh"

@interface ObjectiveCParser (UnitTestingPrivateAPI)
@property (nonatomic, strong, readwrite) Store *store;
@property (nonatomic, strong, readwrite) GBSettings *settings;
@property (nonatomic, strong, readwrite) NSString *filename;
@property (nonatomic, strong) CommentParser *commentParser;
@end

#pragma mark -

static void runWithParser(void(^handler)(ObjectiveCParser *parser)) {
	ObjectiveCParser *parser = [[ObjectiveCParser alloc] init];
	handler(parser);
	[parser release];
}

static void runWithStrictParser(void(^handler)(ObjectiveCParser *parser, id store, id settings)) {
	runWithParser(^(ObjectiveCParser *parser) {
		parser.filename = @"file.h";
		parser.store = [OCMockObject mockForClass:[Store class]];
		parser.settings = [OCMockObject mockForClass:[GBSettings class]];
		handler(parser, parser.store, parser.settings);
	});
}

#pragma mark -

TEST_BEGIN(ObjectiveCParserTests)

describe(@"lazy accessors:", ^{
	it(@"should initialize objects", ^{
		runWithParser(^(ObjectiveCParser *parser) {
			// execute & verify
			parser.fileState should be_instance_of([ObjectiveCFileState class]);
			parser.interfaceState should be_instance_of([ObjectiveCInterfaceState class]);
			parser.propertyState should be_instance_of([ObjectiveCPropertyState class]);
			parser.methodState should be_instance_of([ObjectiveCMethodState class]);
			parser.pragmaMarkState should be_instance_of([ObjectiveCPragmaMarkState class]);
			parser.enumState should be_instance_of([ObjectiveCEnumState class]);
			parser.structState should be_instance_of([ObjectiveCStructState class]);
			parser.constantState should be_instance_of([ObjectiveCConstantState class]);
			parser.tokenizer should be_instance_of([PKTokenizer class]);
			parser.commentParser should be_instance_of([CommentParser class]);
		});
	});
});

describe(@"comments parsing:", ^{
	describe(@"method groups:", ^{
		it(@"should append method group from single line comment", ^{
			runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
				// setup
				[[store expect] appendMethodGroupWithDescription:@"name of group"];
				// execute
				[parser parseString:@"/// @name name of group"];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});

		it(@"should append method group from multi line comment", ^{
			runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
				// setup
				[[store expect] appendMethodGroupWithDescription:@"name of group"];
				// execute
				[parser parseString:@"/** @name name of group */"];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
	
	describe(@"commend before objects:", ^{
		describe(@"single line comments:", ^{
			it(@"should ignore standard comments", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// execute - this will raise exception if anything gets registered to store due to using strict mock!
					[parser parseString:@"// comment"];
				});
			});
			
			it(@"should register one line comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"comment"];
					// execute
					[parser parseString:@"/// comment"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});

			it(@"should group successive lines together", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"line1\nline2\nline3"];
					// execute
					[parser parseString:@"/// line1\n/// line2\n/// line3"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
			
			it(@"should register successive comments", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"line1\nline2"];
					[[store expect] appendCommentToCurrentObject:@"line3\nline4"];
					// execute
					[parser parseString:@"/// line1\n/// line2\n\n/// line3\n/// line4"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
		});
		
		describe(@"multi line comments:", ^{
			it(@"should ignore standard comments", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// execute - this will raise exception if anything is registered to store due to using strict mock!
					[parser parseString:@"/* comment */"];
				});
			});
			
			it(@"should register single comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"comment"];
					// execute
					[parser parseString:@"/** comment*/"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
			
			it(@"should register successive comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"line1\nline2"];
					[[store expect] appendCommentToCurrentObject:@"line3\nline4"];
					// execute
					[parser parseString:@"/** line1\n line2*/\n/** line3\n line4*/"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
		});
	});
	
	describe(@"inline comments:", ^{
		describe(@"single line comments:", ^{
			it(@"should ignore standard comment", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// execute - this will raise exception if anything is registered to store due to using strict mock!
					[parser parseString:@"//< comment"];
				});
			});
			
			it(@"should register one line comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToPreviousObject:@"comment"];
					// execute
					[parser parseString:@"///< comment"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
			
			it(@"should group successive lines together", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToCurrentObject:@"line1\nline2\nline3"];
					// execute
					[parser parseString:@"/// line1\n/// line2\n/// line3"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
			
			it(@"should register successive comments", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToPreviousObject:@"line1\nline2"];
					[[store expect] appendCommentToPreviousObject:@"line3\nline4"];
					// execute
					[parser parseString:@"///< line1\n/// line2\n\n///< line3\n/// line4"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
		});
		
		describe(@"multi line comments:", ^{
			it(@"should ignore standard comments", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// execute - this will raise exception if anything is registered to store due to using strict mock!
					[parser parseString:@"/*< comment */"];
				});
			});
			
			it(@"should register single comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToPreviousObject:@"comment"];
					// execute
					[parser parseString:@"/**< comment*/"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
			
			it(@"should register successive comment to store", ^{
				runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
					// setup
					[[store expect] appendCommentToPreviousObject:@"line1\nline2"];
					[[store expect] appendCommentToPreviousObject:@"line3\nline4"];
					// execute
					[parser parseString:@"/**< line1\n line2*/\n/**< line3\n line4*/"];
					// verify
					^{ [store verify]; } should_not raise_exception();
				});
			});
		});
	});
	
	describe(@"mixed cases", ^{
		it(@"should register previous and next single line comment", ^{
			runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
				// setup
				[[store expect] appendCommentToPreviousObject:@"line1\nline2"];
				[[store expect] appendCommentToCurrentObject:@"line3\nline4"];
				// execute
				[parser parseString:@"///< line1\n/// line2\n\n/// line3\n/// line4"];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});

		it(@"should register previous and next multi line comment", ^{
			runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
				// setup
				[[store expect] appendCommentToPreviousObject:@"line1\nline2"];
				[[store expect] appendCommentToCurrentObject:@"line3\nline4"];
				// execute
				[parser parseString:@"/**< line1\nline2*/\n/** line3\nline4*/"];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
		
		it(@"should handle probably the most common case", ^{
			runWithStrictParser(^(ObjectiveCParser *parser, id store, id settings) {
				// setup
				[[store expect] appendCommentToPreviousObject:@"line1\nline2"];
				[[store expect] appendCommentToCurrentObject:@"line3\nline4"];
				// execute
				[parser parseString:@"///< line1\n/// line2\n\n/** line3\n line4*/"];
				// verify
				^{ [store verify]; } should_not raise_exception();
			});
		});
	});
});

TEST_END
