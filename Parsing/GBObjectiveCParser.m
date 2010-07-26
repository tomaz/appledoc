//
//  GBObjectiveCParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "ParseKit.h"
#import "PKToken+GBToken.h"
#import "GBTokenizer.h"
#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParser ()

- (PKTokenizer *)tokenizerWithInputString:(NSString *)input;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

@interface GBObjectiveCParser (ClassDefinitionParsing)

- (void)matchClassDefinition;

@end

@interface GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject;

@end

#pragma mark -

@implementation GBObjectiveCParser

#pragma mark ￼Initialization & disposal

+ (id)parserWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Parsing handling

- (void)parseObjectsFromString:(NSString *)input toStore:(id)store {
	NSParameterAssert(input != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Parsing objective-c objects to store %@...", store);
	self.store = store;
	_tokenizer = [GBTokenizer tokenizerWithSource:[self tokenizerWithInputString:input]];
	while (![_tokenizer eof]) {
		if (![self matchNextObject]) {
			[_tokenizer consume:1];
		}
	}
}

- (PKTokenizer *)tokenizerWithInputString:(NSString *)input {
	return [PKTokenizer tokenizerWithString:input];
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end

#pragma mark -

@implementation GBObjectiveCParser (ClassDefinitionParsing)

- (void)matchClassDefinition {
	// @interface CLASSNAME
	NSString *className = [[_tokenizer lookahead:1] stringValue];
	GBClassData *class = [[GBClassData alloc] initWithName:className];
	[self.store registerClass:class];
	[_tokenizer consume:2];
}

@end

#pragma mark -

@implementation GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject {
	// Get data needed for distinguishing between class, category and extension definition.
	BOOL isInterface = [[_tokenizer currentToken] matches:@"@interface"];
//	BOOL isOpenParenthesis = [[_tokenizer lookahead:2] matches:@"("];
//	BOOL isCloseParenthesis = [[_tokenizer lookahead:3] matches:@")"];
//	
//	// Found class extension definition.
//	if (isInterface && isOpenParenthesis && isCloseParenthesis) {
//		GBLogDebug(@"Detected class extension definition at %i...");
//		[self matchExtensionDefinition];
//		return YES;
//	}
//	
//	// Found category definition.
//	if (isInterface && isOpenParenthesis) {
//		[self matchCategoryDefinition];
//		return YES;
//	}
//	
	// Found class definition.
	if (isInterface) {
		[self matchClassDefinition];
		return YES;
	}
	
//	// Get data needed for distinguishing between protocol definition and directive.
//	BOOL isProtocol = [[_tokenizer currentToken] matches:@"@protocol"];
//	BOOL isDirective = [[_tokenizer lookahead:2] matches:@";"] || [[_tokenizer lookahead:2] matches:@","];
//	
//	// Found protocol definition.
//	if (isProtocol && !isDirective) {
//		[self matchProtocolDefinition];
//		return YES;
//	}
	
	return NO;
}

@end

