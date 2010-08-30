//
//  GBCommentComponentsProviderTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010 Gentle Bytes. All rights reserved.
//

#import "GBCommentComponentsProvider.h"

@interface GBCommentComponentsProviderTesting : GHTestCase
@end

#pragma mark -

@implementation GBCommentComponentsProviderTesting

- (void)testStringContainsWarning_shouldDetectWarning {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesWarning:@"@warning Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesWarning:@"     @warning Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesWarning:@"\t\t@warning Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesWarning:@"   \t@warning Description"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesWarning:@"Text @warning Description"], equalToBool(NO));
}

- (void)testStringContainsBug_shouldDetectBug {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesBug:@"@bug Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesBug:@"     @bug Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesBug:@"\t\t@bug Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesBug:@"   \t@bug Description"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesBug:@"Text @bug Description"], equalToBool(NO));
}

- (void)testStringContainsParameter_shouldDetectParam {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesParameter:@"@param name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesParameter:@"     @param name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesParameter:@"\t\t@param name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesParameter:@"   \t@param name Description"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesParameter:@"Text @param name Description"], equalToBool(NO));
}

- (void)testStringContainsReturn_shouldDetectReturn {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesReturn:@"@return Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesReturn:@"     @return Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesReturn:@"\t\t@return Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesReturn:@"   \t@return Description"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesReturn:@"Text @return Description"], equalToBool(NO));
}

- (void)testStringContainsException_shouldDetectException {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesException:@"@exception name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesException:@"     @exception name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesException:@"\t\t@exception name Description"], equalToBool(YES));
	assertThatBool([provider stringDefinesException:@"   \t@exception name Description"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesException:@"Text @exception name Description"], equalToBool(NO));
}

- (void)testStringContainsCrossReference_shouldDetectSee {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesCrossReference:@"@see link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"     @see link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"\t\t@see link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"   \t@see link"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesCrossReference:@"Text @see link"], equalToBool(NO));
}

- (void)testStringContainsCrossReference_shouldDetectSa {
	// setup
	GBCommentComponentsProvider *provider = [GBCommentComponentsProvider provider];
	// execute & verify - should allow any prefix whitespace
	assertThatBool([provider stringDefinesCrossReference:@"@sa link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"     @sa link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"\t\t@sa link"], equalToBool(YES));
	assertThatBool([provider stringDefinesCrossReference:@"   \t@sa link"], equalToBool(YES));
	// execute & verify - should not detect if in the middle of string
	assertThatBool([provider stringDefinesCrossReference:@"Text @sa link"], equalToBool(NO));
}

@end
