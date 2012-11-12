//
//  ParserTests.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/04/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParseData.h"
#import "ObjectiveCStateTestsHelpers.h"
#import "TestCaseBase.hh"

static void runWithData(void(^handler)(ObjectiveCParseData *data)) {
	runWithString(@"", ^(id parser, id tokens) {
		id store = mock([Store class]);
		ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:tokens parser:parser store:store];
		handler(data);
	});
}

#pragma mark - 

TEST_BEGIN(ObjectiveCParseDataTests)

describe(@"descriptors handling:", ^{
	it(@"should match double underscore tokens", ^{
		runWithData(^(ObjectiveCParseData *data) {
			// execute & verify
			[data doesStringLookLikeDescriptor:@"__a"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__a_"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__a__"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__a_and_b"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__a_and_b_"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__a_and_b__"] should equal(YES);
		});
	});
	
	it(@"should match uppercase words", ^{
		runWithData(^(ObjectiveCParseData *data) {
			// execute & verify
			[data doesStringLookLikeDescriptor:@"A"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"A_AND_B"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"__A_AND_B"] should equal(YES);
		});
	});
	
	it(@"should match uppercase words, digits and underscores", ^{
		runWithData(^(ObjectiveCParseData *data) {
			// execute & verify
			[data doesStringLookLikeDescriptor:@"A1234567890"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"A_1"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"A_B_"] should equal(YES);
			[data doesStringLookLikeDescriptor:@"A__"] should equal(YES);
		});
	});
	
	it(@"should reject words starting with digit", ^{
		runWithData(^(ObjectiveCParseData *data) {
			// execute & verify
			[data doesStringLookLikeDescriptor:@"1234567890"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"1_A"] should equal(NO);
		});
	});
	
	it(@"should reject other words", ^{
		runWithData(^(ObjectiveCParseData *data) {
			// execute & verify
			[data doesStringLookLikeDescriptor:@"a"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"ab"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"aB"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"Ab"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"_a__"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"_aB__"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"_A_AND_b__"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"1234567890"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"1_A"] should equal(NO);
			[data doesStringLookLikeDescriptor:@"*"] should equal(NO);
		});
	});
});

TEST_END
