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
@property (retain) GBTokenizer *tokenizer;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

@interface GBObjectiveCParser (ClassDefinitionParsing)

- (void)matchClassDefinition;
- (void)matchSuperclassForClass:(GBClassData *)class;
- (void)matchAdoptedProtocolForProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)matchIvarsForProvider:(GBIvarsProvider *)provider;

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
	self.tokenizer = [GBTokenizer tokenizerWithSource:[self tokenizerWithInputString:input]];
	while (![self.tokenizer eof]) {
		if (![self matchNextObject]) {
			[self.tokenizer consume:1];
		}
	}
}

- (PKTokenizer *)tokenizerWithInputString:(NSString *)input {
	PKTokenizer *result = [PKTokenizer tokenizerWithString:input];
	[result setTokenizerState:result.wordState from:'_' to:'_'];	// Allow words to start with _
	return result;
}

#pragma mark Properties

@synthesize tokenizer;
@synthesize settings;
@synthesize store;

@end

#pragma mark -

@implementation GBObjectiveCParser (ClassDefinitionParsing)

- (void)matchClassDefinition {
	// @interface CLASSNAME
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBClassData *class = [GBClassData classDataWithName:className];
	[self.store registerClass:class];
	[self.tokenizer consume:2];
	[self matchSuperclassForClass:class];
	[self matchAdoptedProtocolForProvider:class.adoptedProtocols];
	[self matchIvarsForProvider:class.ivars];
}

- (void)matchSuperclassForClass:(GBClassData *)class {
	if (![[self.tokenizer currentToken] matches:@":"]) return;
	class.superclassName = [[self.tokenizer lookahead:1] stringValue];
	[self.tokenizer consume:2];
}

- (void)matchAdoptedProtocolForProvider:(GBAdoptedProtocolsProvider *)provider {
	[self.tokenizer consumeFrom:@"<" to:@">" usingBlock:^(PKToken *token, BOOL *consume) {
		if ([token matches:@","]) return;
		GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:[token stringValue]];
		[provider registerProtocol:protocol];
	}];
}

- (void)matchIvarsForProvider:(GBIvarsProvider *)provider {
	[self.tokenizer consumeFrom:@"{" to:@"}" usingBlock:^(PKToken *token, BOOL *consume) {
		if ([token matches:@"@private"]) return;
		if ([token matches:@"@protected"]) return;
		if ([token matches:@"@public"]) return;
		
		NSMutableArray *components = [NSMutableArray array];
		[self.tokenizer consumeTo:@";" usingBlock:^(PKToken *ivarToken, BOOL *ivarConsume) {
			[components addObject:[ivarToken stringValue]];
		}];
		
		GBIvarData *ivar = [GBIvarData ivarDataWithComponents:components];
		[provider registerIvar:ivar];
		*consume = NO;
	}];
}

@end

#pragma mark -

@implementation GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject {
	// Get data needed for distinguishing between class, category and extension definition.
	BOOL isInterface = [[self.tokenizer currentToken] matches:@"@interface"];
//	BOOL isOpenParenthesis = [[self.tokenizer lookahead:2] matches:@"("];
//	BOOL isCloseParenthesis = [[self.tokenizer lookahead:3] matches:@")"];
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
//	BOOL isProtocol = [[self.tokenizer currentToken] matches:@"@protocol"];
//	BOOL isDirective = [[self.tokenizer lookahead:2] matches:@";"] || [[self.tokenizer lookahead:2] matches:@","];
//	
//	// Found protocol definition.
//	if (isProtocol && !isDirective) {
//		[self matchProtocolDefinition];
//		return YES;
//	}
	
	return NO;
}

@end

