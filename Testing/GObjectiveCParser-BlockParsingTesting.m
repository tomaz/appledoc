//
//  GObjectiveCParser-BlockParsingTesting.m
//  appledoc
//
//  Created by Stéphane Prohaszka on 06/03/2015.
//  Copyright (c) 2015 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

// Note that we use class for invoking parsing of methods. Probably not the best option - i.e. we could isolate method parsing code altogether and only parse relevant stuff here, but it seemed not much would be gained by doing this. Separating unit tests does avoid repetition in top-level objects testing code - we only need to test specific data there.

@interface GObjectiveCParserBlockParsingTesting : GBObjectsAssertor

@end

@implementation GObjectiveCParserBlockParsingTesting

- (void)testParseObjectsFromString_shouldRegisterSimpleBlockComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1*/\ntypedef void(^anyBlock)(BOOL boolean);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    assertThat([blockData.comment stringValue], is(@"Comment 1"));
    assertThat(blockData.parameters, notNilValue());
    assertThatInteger(blockData.parameters.count, equalToInteger(1));
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    assertThat(blockArgument.className, equalTo(@"BOOL"));
    assertThat(blockArgument.name, equalTo(@"boolean"));
}

- (void)testParseObjectsFromString_shouldRegisterBlockComment {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1 */\ntypedef void(^anyBlock)(BOOL boolean, NSString *string);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    assertThat([blockData.comment stringValue], is(@"Comment 1"));
    assertThat(blockData.parameters, notNilValue());
    assertThatInteger(blockData.parameters.count, equalToInteger(2));
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    assertThat(blockArgument.className, equalTo(@"BOOL"));
    assertThat(blockArgument.name, equalTo(@"boolean"));
    blockArgument = [blockData parameters][1];
    assertThat(blockArgument.className, equalTo(@"NSString"));
    assertThat(blockArgument.name, equalTo(@"*string"));
}

- (void)testParseObjectsFromString_shouldRegisterBlockCommentWithNoArgName {
    // setup
    GBObjectiveCParser *parser = [GBObjectiveCParser parserWithSettingsProvider:[GBTestObjectsRegistry mockSettingsProvider]];
    GBStore *store = [[GBStore alloc] init];
    
    // execute
    [parser parseObjectsFromString:@"/// copyright\n/** Comment 1*/\ntypedef void(^anyBlock)(BOOL, NSString *);" sourceFile:@"filename.h" toStore:store];
    
    // verify
    GBTypedefBlockData *blockData = [store typedefBlockWithName:@"anyBlock"];
    
    assertThat([[blockData comment] stringValue], is(@"Comment 1"));
    assertThat([blockData parameters], notNilValue());
    assertThatInteger([blockData parameters].count, equalToInteger(2));
    GBTypedefBlockArgument *blockArgument = [[blockData parameters] firstObject];
    assertThat(blockArgument.className, equalTo(@"BOOL"));
    assertThat(blockArgument.name, equalTo(@""));
    blockArgument = [blockData parameters][1];
    assertThat(blockArgument.className, equalTo(@"NSString"));
    assertThat(blockArgument.name, equalTo(@"*"));
}

@end
