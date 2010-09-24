//
//  GBObjectiveCParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "ParseKit.h"
#import "PKToken+GBToken.h"
#import "GBTokenizer.h"
#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParser ()

- (PKTokenizer *)tokenizerWithInputString:(NSString *)input;
@property (retain) GBTokenizer *tokenizer;
@property (retain) NSString *filename;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

@interface GBObjectiveCParser (DefinitionParsing)

- (void)matchClassDefinition;
- (void)matchCategoryDefinition;
- (void)matchExtensionDefinition;
- (void)matchProtocolDefinition;
- (void)matchSuperclassForClass:(GBClassData *)class;
- (void)matchAdoptedProtocolForProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)matchIvarsForProvider:(GBIvarsProvider *)provider;
- (void)matchMethodDefinitionsForProvider:(GBMethodsProvider *)provider;
- (BOOL)matchMethodDefinitionForProvider:(GBMethodsProvider *)provider;
- (BOOL)matchPropertyDefinitionForProvider:(GBMethodsProvider *)provider;

@end

@interface GBObjectiveCParser (DeclarationsParsing)

- (void)matchClassDeclaration;
- (void)matchCategoryDeclaration;
- (void)matchMethodDeclarationsForProvider:(GBMethodsProvider *)provider;
- (BOOL)matchMethodDeclarationForProvider:(GBMethodsProvider *)provider;
- (void)consumeMethodBody;

@end

@interface GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject;
- (BOOL)matchObjectDefinition;
- (BOOL)matchObjectDeclaration;
- (BOOL)matchMethodDataForProvider:(GBMethodsProvider *)provider from:(NSString *)start to:(NSString *)end;
- (void)registerLastCommentToObject:(GBModelBase *)object;
- (void)registerDeclaredDataFromCurrentTokenToObject:(GBModelBase *)object;
- (NSString *)sectionNameFromCommentString:(NSString *)string;

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
	GBLogDebug(@"Initializing objective-c parser with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Parsing handling

- (void)parseObjectsFromString:(NSString *)input sourceFile:(NSString *)filename toStore:(id)store {
	NSParameterAssert(input != nil);
	NSParameterAssert(filename != nil);
	NSParameterAssert(store != nil);
	NSParameterAssert([store conformsToProtocol:@protocol(GBStoreProviding)]);
	GBLogDebug(@"Parsing objective-c objects to store %@...", store);
	self.filename = [filename lastPathComponent];
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
	[result.symbolState add:@"..."];	// Allow ... as single token
	return result;
}

#pragma mark Properties

@synthesize tokenizer;
@synthesize filename;
@synthesize settings;
@synthesize store;

@end

#pragma mark -

@implementation GBObjectiveCParser (DefinitionParsing)

- (void)matchClassDefinition {
	// @interface CLASSNAME
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBClassData *class = [GBClassData classDataWithName:className];
	GBLogVerbose(@"Matched %@ class definition.", className);
	[self registerDeclaredDataFromCurrentTokenToObject:class];
	[self registerLastCommentToObject:class];
	[self.tokenizer consume:2];
	[self matchSuperclassForClass:class];
	[self matchAdoptedProtocolForProvider:class.adoptedProtocols];
	[self matchIvarsForProvider:class.ivars];
	[self matchMethodDefinitionsForProvider:class.methods];
	[self.store registerClass:class];
}

- (void)matchCategoryDefinition {
	// @interface CLASSNAME ( CATEGORYNAME )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	NSString *categoryName = [[self.tokenizer lookahead:3] stringValue];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:categoryName className:className];
	GBLogVerbose(@"Matched %@(%@) category definition...", className, categoryName);
	[self registerDeclaredDataFromCurrentTokenToObject:category];
	[self registerLastCommentToObject:category];
	[self.tokenizer consume:5];
	[self matchAdoptedProtocolForProvider:category.adoptedProtocols];
	[self matchMethodDefinitionsForProvider:category.methods];
	[self.store registerCategory:category];
}

- (void)matchExtensionDefinition {
	// @interface CLASSNAME ( )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:className];
	GBLogVerbose(@"Matched %@() extension definition.", className);
	[self registerDeclaredDataFromCurrentTokenToObject:extension];
	[self registerLastCommentToObject:extension];
	[self.tokenizer consume:4];
	[self matchAdoptedProtocolForProvider:extension.adoptedProtocols];
	[self matchMethodDefinitionsForProvider:extension.methods];
	[self.store registerCategory:extension];
}

- (void)matchProtocolDefinition {
	// @protocol PROTOCOLNAME
	NSString *protocolName = [[self.tokenizer lookahead:1] stringValue];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:protocolName];
	GBLogVerbose(@"Matched %@ protocol definition.", protocolName);
	[self registerDeclaredDataFromCurrentTokenToObject:protocol];
	[self registerLastCommentToObject:protocol];
	[self.tokenizer consume:2];
	[self matchAdoptedProtocolForProvider:protocol.adoptedProtocols];
	[self matchMethodDefinitionsForProvider:protocol.methods];
	[self.store registerProtocol:protocol];
}

- (void)matchSuperclassForClass:(GBClassData *)class {
	if (![[self.tokenizer currentToken] matches:@":"]) return;
	class.nameOfSuperclass = [[self.tokenizer lookahead:1] stringValue];
	GBLogDebug(@"Matched superclass %@.", class.nameOfSuperclass);
	[self.tokenizer consume:2];
}

- (void)matchAdoptedProtocolForProvider:(GBAdoptedProtocolsProvider *)provider {
	[self.tokenizer consumeFrom:@"<" to:@">" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([token matches:@","]) return;
		GBProtocolData *protocol = [[GBProtocolData alloc] initWithName:[token stringValue]];
		GBLogDebug(@"Matched adopted protocol %@.", protocol);
		[provider registerProtocol:protocol];
	}];
}

- (void)matchIvarsForProvider:(GBIvarsProvider *)provider {
	[self.tokenizer consumeFrom:@"{" to:@"}" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		return; // Ignore all ivars, no need to document these(?)
	}];
}

- (void)matchMethodDefinitionsForProvider:(GBMethodsProvider *)provider {
	[self.tokenizer consumeTo:@"@end" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([self matchMethodDefinitionForProvider:provider] || [self matchPropertyDefinitionForProvider:provider]) {
			*consume = NO;
		}
	}];
}

- (BOOL)matchMethodDefinitionForProvider:(GBMethodsProvider *)provider {
	if ([self matchMethodDataForProvider:provider from:@"+" to:@";"]) return YES;
	if ([self matchMethodDataForProvider:provider from:@"-" to:@";"]) return YES;
	return NO;
}

- (BOOL)matchPropertyDefinitionForProvider:(GBMethodsProvider *)provider {
	NSString *comment = [[self.tokenizer lastCommentString] copy];
	NSString *sectionComment = [[self.tokenizer previousCommentString] copy];
	NSString *sectionName = [self sectionNameFromCommentString:sectionComment];
	__block BOOL result = NO;
	__block GBSourceInfo *filedata = nil;
	[self.tokenizer consumeFrom:@"@property" to:@";" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if (!filedata) filedata = [self.tokenizer fileDataForToken:token filename:self.filename];
		
		// Get attributes.
		NSMutableArray *propertyAttributes = [NSMutableArray array];
		[self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			if ([token matches:@","]) return;
			[propertyAttributes addObject:[token stringValue]];
		}];
		
		// Get property types and name. Handle block types properly!
		NSMutableArray *propertyComponents = [NSMutableArray array];
		__block BOOL parseBlockName = NO;
		__block NSString *blockName = nil;
		[self.tokenizer consumeTo:@";" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			[propertyComponents addObject:[token stringValue]];
			if (parseBlockName) {
				blockName = [token stringValue];
				parseBlockName = NO;
			}
			if ([token matches:@"^"]) parseBlockName = YES;
		}];
		if (blockName) [propertyComponents addObject:blockName];
		
		// Register property.
		GBMethodData *propertyData = [GBMethodData propertyDataWithAttributes:propertyAttributes components:propertyComponents];
		GBLogDebug(@"Matched property definition %@.", propertyData);
		[propertyData registerSourceInfo:filedata];
		[propertyData registerCommentString:comment];
		[provider registerSectionIfNameIsValid:sectionName];
		[provider registerMethod:propertyData];
		*consume = NO;
		*stop = YES;
		result = YES;
	}];
	return result;
}
	 
@end

#pragma mark -

@implementation GBObjectiveCParser (DeclarationsParsing)

- (void)matchClassDeclaration {
	// @implementation CLASSNAME
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBClassData *class = [GBClassData classDataWithName:className];
	GBLogVerbose(@"Matched %@ class declaration.", className);
	[self registerDeclaredDataFromCurrentTokenToObject:class];
	[self registerLastCommentToObject:class];
	[self.tokenizer consume:2];
	[self matchMethodDeclarationsForProvider:class.methods];
	[self.store registerClass:class];
}

- (void)matchCategoryDeclaration {
	// @implementation CLASSNAME ( CATEGORYNAME )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	NSString *categoryName = [[self.tokenizer lookahead:3] stringValue];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:categoryName className:className];
	GBLogVerbose(@"Matched %@(%@) category declaration.", className, categoryName);
	[self registerDeclaredDataFromCurrentTokenToObject:category];
	[self registerLastCommentToObject:category];
	[self.tokenizer consume:5];
	[self matchMethodDeclarationsForProvider:category.methods];
	[self.store registerCategory:category];
}

- (void)matchMethodDeclarationsForProvider:(GBMethodsProvider *)provider {
	[self.tokenizer consumeTo:@"@end" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([self matchMethodDeclarationForProvider:provider]) {
			*consume = NO;
		}
	}];
}

- (BOOL)matchMethodDeclarationForProvider:(GBMethodsProvider *)provider {
	if ([self matchMethodDataForProvider:provider from:@"+" to:@"{"]) {
		[self consumeMethodBody];
		return YES;
	}
	if ([self matchMethodDataForProvider:provider from:@"-" to:@"{"]) {
		[self consumeMethodBody];
		return YES;
	}
	return NO;
}

- (void)consumeMethodBody {
	// This method assumes we're currently pointing to the first token after method's opening brace!
	__block NSUInteger braceLevel = 1;
	[self.tokenizer consumeTo:@"@end" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([token matches:@"{"]) {
			braceLevel++;
			return;
		}
		if ([token matches:@"}"]) {
			if (--braceLevel == 0) {
				*consume = NO;
				*stop = YES;
			}
			return;
		}
	}];
}

@end

#pragma mark -

@implementation GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject {
	if ([self matchObjectDefinition]) return YES;
	if ([self matchObjectDeclaration]) return YES;
	return NO;
}

- (BOOL)matchObjectDefinition {
	// Get data needed for distinguishing between class, category and extension definition.
	BOOL isInterface = [[self.tokenizer currentToken] matches:@"@interface"];
	BOOL isOpenParenthesis = [[self.tokenizer lookahead:2] matches:@"("];
	BOOL isCloseParenthesis = [[self.tokenizer lookahead:3] matches:@")"];
	
	// Found class extension definition.
	if (isInterface && isOpenParenthesis && isCloseParenthesis) {
		[self matchExtensionDefinition];
		return YES;
	}
	
	// Found category definition.
	if (isInterface && isOpenParenthesis) {
		[self matchCategoryDefinition];
		return YES;
	}
	
	// Found class definition.
	if (isInterface) {
		[self matchClassDefinition];
		return YES;
	}
	
	// Get data needed for distinguishing between protocol definition and directive.
	BOOL isProtocol = [[self.tokenizer currentToken] matches:@"@protocol"];
	BOOL isDirective = [[self.tokenizer lookahead:2] matches:@";"] || [[self.tokenizer lookahead:2] matches:@","];
	
	// Found protocol definition.
	if (isProtocol && !isDirective) {
		[self matchProtocolDefinition];
		return YES;
	}
	
	return NO;
}

- (BOOL)matchObjectDeclaration {
	// Get data needed for distinguishing between class and category declaration.
	BOOL isImplementation = [[self.tokenizer currentToken] matches:@"@implementation"];
	BOOL isOpenParenthesis = [[self.tokenizer lookahead:2] matches:@"("];
	
	// Found category declaration.
	if (isImplementation && isOpenParenthesis) {
		[self matchCategoryDeclaration];
		return YES;
	}
	
	// Found class declaration.
	if (isImplementation) {
		[self matchClassDeclaration];
		return YES;
	}
	
	return NO;
}

- (BOOL)matchMethodDataForProvider:(GBMethodsProvider *)provider from:(NSString *)start to:(NSString *)end {
	// This method only matches class or instance methods, not properties!
	// - (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
	NSString *comment = [[self.tokenizer lastCommentString] copy];
	NSString *sectionComment = [[self.tokenizer previousCommentString] copy];
	NSString *sectionName = [self sectionNameFromCommentString:sectionComment];
	__block BOOL result = NO;
	__block GBSourceInfo *filedata = nil;
	GBMethodType methodType = [start isEqualToString:@"-"] ? GBMethodTypeInstance : GBMethodTypeClass;
	[self.tokenizer consumeFrom:start to:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if (!filedata) filedata = [self.tokenizer fileDataForToken:token filename:self.filename];
		
		// Get result types.
		NSMutableArray *methodResult = [NSMutableArray array];
		[self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			[methodResult addObject:[token stringValue]];
		}];
		
		// Get all arguments. Note that we ignore semicolons which may "happen" in declaration before method opening brace!
		__block NSMutableArray *methodArgs = [NSMutableArray array];
		[self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			// If we receive semicolon, ignore it - this works for both - definition and declaration!
			if ([token matches:@";"]) {
				*stop = YES;
				return;
			}
			
			// Get argument name.
			NSString *argumentName = [token stringValue];
			[self.tokenizer consume:1];
			
			__block NSString *argumentVar = nil;
			__block NSMutableArray *argumentTypes = [NSMutableArray array];
			__block NSMutableArray *terminationMacros = [NSMutableArray array];
			__block BOOL isVarArg = NO;
			if ([[self.tokenizer currentToken] matches:@":"]) {
				[self.tokenizer consume:1];
				
				// Get argument types.
				[self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
					[argumentTypes addObject:[token stringValue]];
				}];
				
				// Get argument variable name.
				if (![[self.tokenizer currentToken] matches:end]) {
					argumentVar = [[self.tokenizer currentToken] stringValue];
					[self.tokenizer consume:1];
				}
				
				// If we have variable args block following, consume the rest of the tokens to get optional termination macros.
				if ([[self.tokenizer lookahead:0] matches:@","] && [[self.tokenizer lookahead:1] matches:@"..."]) {
					isVarArg = YES;
					[self.tokenizer consume:2];
					[self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
						[terminationMacros addObject:[token stringValue]];
					}];
					*stop = YES; // Ignore the rest of parameters as vararg is the last and above block consumed end token which would confuse above block!
				}
			}
			
			GBMethodArgument *argument = nil;
			if ([argumentTypes count] == 0)
				argument = [GBMethodArgument methodArgumentWithName:argumentName];
			else if (!isVarArg)
				argument = [GBMethodArgument methodArgumentWithName:argumentName types:argumentTypes var:argumentVar];
			else
				argument = [GBMethodArgument methodArgumentWithName:argumentName types:argumentTypes var:argumentVar terminationMacros:terminationMacros];
			[methodArgs addObject:argument];
			*consume = NO;
		}];
		
		// Create method instance and register it.
		GBMethodData *methodData = [GBMethodData methodDataWithType:methodType result:methodResult arguments:methodArgs];
		GBLogDebug(@"Matched method %@%@.", start, methodData);
		[methodData registerSourceInfo:filedata];
		[methodData registerCommentString:comment];
		[provider registerSectionIfNameIsValid:sectionName];
		[provider registerMethod:methodData];
		*consume = NO;
		*stop = YES;
		result = YES;
	}];
	return result;
}

- (void)registerLastCommentToObject:(GBModelBase *)object {
	[object registerCommentString:[self.tokenizer lastCommentString]];
}

- (void)registerDeclaredDataFromCurrentTokenToObject:(GBModelBase *)object {
	[object registerSourceInfo:[self.tokenizer fileDataForCurrentTokenWithFilename:self.filename]];
}

- (NSString *)sectionNameFromCommentString:(NSString *)string {
	NSCharacterSet* trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	if ([[string stringByTrimmingCharactersInSet:trimSet] length] == 0) return nil;
	NSString *name = [string stringByMatching:self.settings.commentComponents.methodGroupRegex capture:1];
	if ([[name stringByTrimmingCharactersInSet:trimSet] length] == 0) return nil;
	return [name stringByWordifyingWithSpaces];
}

@end

