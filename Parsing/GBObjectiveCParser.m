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
#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBObjectiveCParser.h"

@interface GBObjectiveCParser ()

- (PKTokenizer *)tokenizerWithInputString:(NSString *)input;
- (void)updateLastComment:(GBComment **)comment sectionComment:(GBComment **)sectionComment sectionName:(NSString **)sectionName;
@property (strong) GBTokenizer *tokenizer;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;
@property (assign) BOOL includeInOutput;
@property (assign) BOOL propertyAfterPragma;

@end

@interface GBObjectiveCParser (DefinitionParsing)

- (void)matchClassDefinition;
- (void)matchCategoryDefinition;
- (void)matchExtensionDefinition;
- (void)matchProtocolDefinition;
- (void)matchSuperclassForClass:(GBClassData *)class;
- (void)matchAdoptedProtocolForProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)matchIvarsForProvider:(GBIvarsProvider *)provider;
- (void)matchMethodDefinitionsForProvider:(GBMethodsProvider *)provider forClass: (GBClassData *) class defaultsRequired:(BOOL)required;
- (BOOL)matchMethodDefinitionForProvider:(GBMethodsProvider *)provider required:(BOOL)required;
- (BOOL)matchPropertyDefinitionForProvider:(GBMethodsProvider *)provider required:(BOOL)required;

@end

@interface GBObjectiveCParser (DeclarationsParsing)

- (void)matchClassDeclaration;
- (void)matchCategoryDeclaration;
- (void)matchMethodDeclarationsForProvider:(GBMethodsProvider *)provider defaultsRequired:(BOOL)required;
- (BOOL)matchMethodDeclarationForProvider:(GBMethodsProvider *)provider required:(BOOL)required;
- (void)consumeMethodBody;

@end

@interface GBObjectiveCParser (CommonParsing)

- (BOOL)matchNextObject;
- (BOOL)matchObjectDefinition;
- (BOOL)matchObjectDeclaration;
- (BOOL)matchTypedefEnumDefinition;
- (BOOL)matchTypedefBlockDefinitionForProvider;
- (BOOL)matchMethodDataForProvider:(GBMethodsProvider *)provider from:(NSString *)start to:(NSString *)end required:(BOOL)required;
- (void)registerComment:(GBComment *)comment toObject:(GBModelBase *)object startingWith:(PKToken *)startToken;
- (void)registerLastCommentToObject:(GBModelBase *)object;
- (void)registerSourceInfoFromCurrentTokenToObject:(GBModelBase *)object;
- (NSString *)sectionNameFromComment:(GBComment *)comment;

@end

#pragma mark -

@implementation GBObjectiveCParser

#pragma mark ￼Initialization & disposal

+ (id)parserWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing objective-c parser with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Parsing handling

- (void)parseObjectsFromString:(NSString *)input sourceFile:(NSString *)filename toStore:(id)aStore {
	NSParameterAssert(input != nil);
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);
	NSParameterAssert(aStore != nil);
	GBLogDebug(@"Parsing objective-c objects...");
	self.store = aStore;
	self.tokenizer = [GBTokenizer tokenizerWithSource:[self tokenizerWithInputString:input] filename:filename settings:self.settings];
    self.includeInOutput = YES;
	self.propertyAfterPragma = NO;
    for (NSString *excludeOutputPath in self.settings.excludeOutputPaths) {
        if ([filename isEqualToString:excludeOutputPath]) {
            self.includeInOutput = NO;
            break;
        }
        
        NSString *excludeOutputDir = excludeOutputPath;
        if (![excludeOutputDir hasSuffix:@"/"])
            excludeOutputDir = [NSString stringWithFormat:@"%@/", excludeOutputDir];
        if ([filename hasPrefix:excludeOutputDir]) {
            self.includeInOutput = NO;
            break;
        }
    }
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

#pragma mark Helper methods

- (void)updateLastComment:(GBComment **)comment sectionComment:(GBComment **)sectionComment sectionName:(NSString **)sectionName {
	if (comment) *comment = [self.tokenizer lastComment];
	if (sectionComment) {
		*sectionComment = [self.tokenizer previousComment];
		if (sectionName) *sectionName = [self sectionNameFromComment:*sectionComment];
	}
}

#pragma mark Properties

@synthesize tokenizer;
@synthesize settings;
@synthesize store;
@synthesize includeInOutput;
@synthesize propertyAfterPragma;

@end

#pragma mark -

@implementation GBObjectiveCParser (DefinitionParsing)

- (void)matchClassDefinition {
	// @interface CLASSNAME
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBClassData *class = [GBClassData classDataWithName:className];
    class.includeInOutput = self.includeInOutput;
	[self registerSourceInfoFromCurrentTokenToObject:class];
	GBLogDebug(@"Matched %@ class definition at line %lu.", className, class.prefferedSourceInfo.lineNumber);
	[self registerLastCommentToObject:class];
	[self.tokenizer consume:2];
	[self matchSuperclassForClass:class];
	[self matchAdoptedProtocolForProvider:class.adoptedProtocols];
	[self matchIvarsForProvider:class.ivars];
    
    GBMethodsProvider *methodsProvider = class.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

    [self matchMethodDefinitionsForProvider:methodsProvider forClass: class defaultsRequired:NO];
	[self.store registerClass:class];
}

- (void)matchCategoryDefinition {
	// @interface CLASSNAME ( CATEGORYNAME )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	NSString *categoryName = [[self.tokenizer lookahead:3] stringValue];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:categoryName className:className];
    category.includeInOutput = self.includeInOutput;
	[self registerSourceInfoFromCurrentTokenToObject:category];
	GBLogVerbose(@"Matched %@(%@) category definition at line %lu.", className, categoryName, category.prefferedSourceInfo.lineNumber);
	[self registerLastCommentToObject:category];
	[self.tokenizer consume:5];
	[self matchAdoptedProtocolForProvider:category.adoptedProtocols];

    GBMethodsProvider *methodsProvider = category.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

    [self matchMethodDefinitionsForProvider:methodsProvider forClass: nil defaultsRequired:NO];
	[self.store registerCategory:category];
}

- (void)matchExtensionDefinition {
	// @interface CLASSNAME ( )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	GBCategoryData *extension = [GBCategoryData categoryDataWithName:nil className:className];
    extension.includeInOutput = self.includeInOutput;
	GBLogVerbose(@"Matched %@() extension definition at line %lu.", className, extension.prefferedSourceInfo.lineNumber);
	[self registerSourceInfoFromCurrentTokenToObject:extension];
	[self registerLastCommentToObject:extension];
	[self.tokenizer consume:4];
	[self matchAdoptedProtocolForProvider:extension.adoptedProtocols];

    GBMethodsProvider *methodsProvider = extension.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

	[self matchMethodDefinitionsForProvider:methodsProvider forClass: nil defaultsRequired:NO];
	[self.store registerCategory:extension];
}

- (void)matchProtocolDefinition {
	// @protocol PROTOCOLNAME
	NSString *protocolName = [[self.tokenizer lookahead:1] stringValue];
	GBProtocolData *protocol = [GBProtocolData protocolDataWithName:protocolName];
    protocol.includeInOutput = self.includeInOutput;
	GBLogVerbose(@"Matched %@ protocol definition at line %lu.", protocolName, protocol.prefferedSourceInfo.lineNumber);
	[self registerSourceInfoFromCurrentTokenToObject:protocol];
	[self registerLastCommentToObject:protocol];
	[self.tokenizer consume:2];
	[self matchAdoptedProtocolForProvider:protocol.adoptedProtocols];

    GBMethodsProvider *methodsProvider = protocol.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

	[self matchMethodDefinitionsForProvider:methodsProvider forClass: nil defaultsRequired:YES];
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

- (void)matchMethodDefinitionsForProvider:(GBMethodsProvider *)provider forClass: (GBClassData *) class defaultsRequired:(BOOL)required {
	__block BOOL isRequired = required;
	[self.tokenizer consumeTo:@"@end" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([token matches:@"@required"]) {
			isRequired = YES;
		} else if ([token matches:@"@optional"]) {
			isRequired = NO;
		} else if ([self matchMethodDefinitionForProvider:provider required:isRequired]) {
			*consume = NO;
		} else if ([self matchPropertyDefinitionForProvider:provider required:isRequired]) {
			*consume = NO;
        } else if ([self matchTypedefBlockDefinitionForProvider]) {
            *consume = NO;
		}
	}];
}

- (BOOL)matchMethodDefinitionForProvider:(GBMethodsProvider *)provider required:(BOOL)required {
	if ([self matchMethodDataForProvider:provider from:@"+" to:@";" required:required]) return YES;
	if ([self matchMethodDataForProvider:provider from:@"-" to:@";" required:required]) return YES;
	return NO;
}

- (BOOL)matchPropertyDefinitionForProvider:(GBMethodsProvider *)provider required:(BOOL)required {
	__block GBComment *comment;
	__block GBComment *sectionComment;
	__block NSString *sectionName;
	__block BOOL firstToken = YES;
	__block BOOL result = NO;
	__block GBSourceInfo *filedata = nil;
	__block PKToken *startToken = [self.tokenizer currentToken];
	[self.tokenizer consumeFrom:@"@property" to:@";" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if (!filedata) filedata = [self.tokenizer sourceInfoForToken:token];
		if (firstToken) {
			[self updateLastComment:&comment sectionComment:&sectionComment sectionName:&sectionName];
			if (!self.propertyAfterPragma) [self.tokenizer resetComments];
			self.propertyAfterPragma = NO;
			firstToken = NO;
		}
		
		// Get attributes.
		NSMutableArray *propertyAttributes = [NSMutableArray array];
		[self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			if ([token matches:@","]) return;
			[propertyAttributes addObject:[token stringValue]];
		}];
		
		// Get property types and name. Handle block types properly!
		NSMutableArray *propertyComponents = [NSMutableArray array];
		__block BOOL parseAttribute = NO;
		__block NSUInteger parenthesisDepth = 0;
		[self.tokenizer consumeTo:@";" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			if ([token matches:@"__attribute__"] || [token matches:@"DEPRECATED_ATTRIBUTE"]) {
				parseAttribute = YES;
				parenthesisDepth = 0;
			} else if (parseAttribute) {
				if ([token matches:@"("]) {
					parenthesisDepth++;					
				} else if ([token matches:@")"]) {
					parenthesisDepth--;
					if (parenthesisDepth == 0) parseAttribute = NO;
				}					
			} else {
				[propertyComponents addObject:[token stringValue]];
			}
		}];
		
		// Register property.
		GBMethodData *propertyData = [GBMethodData propertyDataWithAttributes:propertyAttributes components:propertyComponents];
		[propertyData registerSourceInfo:filedata];
		GBLogDebug(@"Matched property definition %@ at line %lu.", propertyData, propertyData.prefferedSourceInfo.lineNumber);
		[self registerComment:comment toObject:propertyData startingWith:startToken];
		[propertyData setIsRequired:required];
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
    class.includeInOutput = self.includeInOutput;
	[self registerSourceInfoFromCurrentTokenToObject:class];
	GBLogVerbose(@"Matched %@ class declaration at line %lu.", className, class.prefferedSourceInfo.lineNumber);
	[self registerLastCommentToObject:class];
	[self.tokenizer consume:2];

    GBMethodsProvider *methodsProvider = class.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

	[self matchMethodDeclarationsForProvider:class.methods defaultsRequired:NO];
	[self.store registerClass:class];
}

- (void)matchCategoryDeclaration {
	// @implementation CLASSNAME ( CATEGORYNAME )
	NSString *className = [[self.tokenizer lookahead:1] stringValue];
	NSString *categoryName = [[self.tokenizer lookahead:3] stringValue];
	GBCategoryData *category = [GBCategoryData categoryDataWithName:categoryName className:className];
    category.includeInOutput = self.includeInOutput;
	[self registerSourceInfoFromCurrentTokenToObject:category];
	GBLogVerbose(@"Matched %@(%@) category declaration at line %lu.", className, categoryName, category.prefferedSourceInfo.lineNumber);
	[self registerLastCommentToObject:category];
	[self.tokenizer consume:5];

    GBMethodsProvider *methodsProvider = category.methods;
    methodsProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;

    [self matchMethodDeclarationsForProvider:methodsProvider defaultsRequired:NO];
	[self.store registerCategory:category];
}

- (void)matchMethodDeclarationsForProvider:(GBMethodsProvider *)provider defaultsRequired:(BOOL)required {
	__block BOOL isRequired = required;
	[self.tokenizer consumeTo:@"@end" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		if ([self matchMethodDeclarationForProvider:provider required:isRequired]) {
			*consume = NO;
		}
	}];
}

- (BOOL)matchMethodDeclarationForProvider:(GBMethodsProvider *)provider required:(BOOL)required {
	if ([self matchMethodDataForProvider:provider from:@"+" to:@"{" required:required]) {
		[self consumeMethodBody];
		return YES;
	}
	if ([self matchMethodDataForProvider:provider from:@"-" to:@"{" required:required]) {
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
    if ([self matchTypedefBlockDefinitionForProvider]) return YES;
    if ([self matchTypedefEnumDefinition]) return YES;
	return NO;
}

- (BOOL)matchTypedefBlockDefinitionForProvider {
    
    if (![[self.tokenizer currentToken] matches:@"typedef"]) {
        return NO;
    }
    
    __block BOOL isTypeDefBlock = YES;
    __block NSString *returnType = nil;
    __block PKToken *lastToken = nil;
    NSUInteger currentLine = [[self.tokenizer sourceInfoForCurrentToken] lineNumber];
    [self.tokenizer lookaheadTo:@"^" usingBlock:^(PKToken *token, BOOL *stop) {

        // break and cancel everything if new line token found before block token could be find
        if ([[self.tokenizer sourceInfoForToken: token] lineNumber] != currentLine) {
            isTypeDefBlock = NO;
            *stop = YES;
            return;
        }
        
        if (returnType == nil) {
            
            if (![token matches: @"typedef"]) {
                returnType = [token stringValue];
            }
            
        } else {
            if ([token matches: @"*"]) {
                returnType = [returnType stringByAppendingString: [token stringValue]];
                
            } else if ([token matches: @"("]) {
                // can be ignored, we seem to be at the end
                
            } else {
                // typedef started with two return type tokens -> cannot be -> cancel!
                isTypeDefBlock = NO;
                *stop = YES;
                return;
            }

        }
        lastToken = token;
    }];
    
    // last token must have been a "("
    if (isTypeDefBlock && ![lastToken matches: @"("]) {
        return NO;
    }
    
    if (isTypeDefBlock)
    {
        
        [self.tokenizer consumeTo: @"^" usingBlock: nil];
        NSString *blockName = [[self.tokenizer currentToken] stringValue];
        
        GBSourceInfo *startInfo = [tokenizer sourceInfoForCurrentToken];
        GBComment *lastComment = [tokenizer lastComment];
        GBLogVerbose(@"Matched %@ typedef block definition at line %lu.", blockName, startInfo.lineNumber);

        [self.tokenizer consume:2];
        
        NSMutableArray *values = nil;
        
        if (![[self.tokenizer lookahead: 2] matches: @"void"]) {
            values = [NSMutableArray array];
            [self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop)
             {
                 NSString *className = [[self.tokenizer currentToken] stringValue];
                 [self.tokenizer consume: 1];
                 
                 NSMutableString *argName = [NSMutableString string];
                 while([[self.tokenizer currentToken] matches:@"*"])
                 {
                     [argName appendString: [[self.tokenizer currentToken] stringValue]];
                     [tokenizer consume:1];
                 }
                 
                 NSString *tokenString = [[self.tokenizer currentToken] stringValue];
                 if (tokenString) {
                     [argName appendString:tokenString];
                 }
                 [self.tokenizer consume:1];
                 
                 if([[self.tokenizer currentToken] matches:@","])
                 {
                     [tokenizer consume:1];
                 }
                 
                 GBTypedefBlockArgument *newArg = [GBTypedefBlockArgument typedefBlockArgumentWithName: argName className: className];
                 
                 [values addObject: newArg];
                 
                 *consume = NO;
             }];
        }
        
        GBTypedefBlockData *newBlock = [GBTypedefBlockData typedefBlockWithName: blockName returnType: returnType parameters: values];
        newBlock.includeInOutput = self.includeInOutput;

        [newBlock registerSourceInfo:startInfo];
        [self registerComment:lastComment toObject:newBlock startingWith:nil];
        [self.tokenizer resetComments];

        //consume ;
        [self.tokenizer consume:1];

        [self.store registerTypedefBlock: newBlock];
        
        return YES;

    }
    return NO;
}


- (BOOL)matchTypedefEnumDefinition {
    BOOL isTypeDef = [[self.tokenizer currentToken] matches:@"typedef"];
    BOOL isTypeDefEnum = [[self.tokenizer lookahead:1] matches:@"NS_ENUM"];
    BOOL isTypeDefOptions = [[self.tokenizer lookahead:1] matches:@"NS_OPTIONS"];
    BOOL hasOpenBracket = [[self.tokenizer lookahead:2] matches:@"("];
    
    //ONLY SUPPORTED ARE typedef enum { } name; because that is the only way to bind the name to the enum values.
    if(!isTypeDef)
    {
        return NO;
    }
    
    if((isTypeDefEnum || isTypeDefOptions) && hasOpenBracket)
    {
        __block PKToken *startToken = [self.tokenizer currentToken];
        [self.tokenizer consume:3];  //consume 'typedef' 'NS_ENUM' and '('
        
        //get the enum type
        NSString *typedefType = [[self.tokenizer currentToken] stringValue];
        [self.tokenizer consume:1];
        
        //consume ','
        [self.tokenizer consume:1];
        
        //get the typename
        NSString *typedefName = [[self.tokenizer currentToken] stringValue];
        [self.tokenizer consume:1];
        
        //consume ')'
        [self.tokenizer consume:1];
        
        GBSourceInfo *startInfo = [tokenizer sourceInfoForCurrentToken];
        GBComment *lastComment = [tokenizer lastComment];
        GBLogVerbose(@"Matched %@ typedef enum definition at line %lu.", typedefName, startInfo.lineNumber);
        
        GBTypedefEnumData *newEnum = [GBTypedefEnumData typedefEnumWithName:typedefName];
        newEnum.includeInOutput = self.includeInOutput;
        newEnum.enumPrimitive = typedefType;
        newEnum.isOptions = isTypeDefOptions;
        
        [newEnum registerSourceInfo:startInfo];
        [self registerComment:lastComment toObject:newEnum startingWith:startToken];
        [self.tokenizer resetComments];
        
        
        //[self.tokenizer consume:1];
        startToken = [self.tokenizer currentToken];
        [self.tokenizer consumeFrom:@"{" to:@"}" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop)
         {
             /* ALWAYS start with the name of the Constant */
              
             startToken = token;
             GBEnumConstantData *newConstant = [GBEnumConstantData constantWithName:[token stringValue]];
             GBSourceInfo *filedata = [tokenizer sourceInfoForToken:token];
             [newConstant registerSourceInfo:filedata];
             [newConstant setParentObject:newEnum];

             GBComment *comment = [self.tokenizer lastComment];

             [self.tokenizer consume:1];
             [self.tokenizer resetComments];
             
             [self consumeMacro];
             
             if([[self.tokenizer currentToken] matches:@"="])
             {
                 [self.tokenizer consume:1];
                 
                 //collect the stringvalues until a ',' is detected.
                 NSMutableArray *values = [NSMutableArray array];
                 
                 while(![[tokenizer currentToken] matches:@","] && ![[tokenizer currentToken] matches:@"}"])
                 {
                     if(![self consumeMacro])
                     {
                         [values addObject:[[tokenizer currentToken] stringValue]];
                         [tokenizer consume:1];
                     }
                 }
                 
                 NSString *value = [values componentsJoinedByString:@" "];
                 [newConstant setAssignedValue:value];
             }
             
             if([[self.tokenizer currentToken] matches:@","])
             {
                 [tokenizer consume:1];
             }

             [self registerComment:comment toObject:newConstant startingWith:startToken];
             startToken = [self.tokenizer currentToken];
             
             *consume = NO;
             
             [newEnum.constants registerConstant:newConstant];
         }];
        
        //if there is a macro, consume it.
        [self consumeMacro];
        
        //consume ;
        [self.tokenizer consume:1];
        [self.store registerTypedefEnum:newEnum];
        return YES;
    }
    else
    {
        BOOL isRegularEnum = [[self.tokenizer lookahead:1] matches:@"enum"];
        BOOL isCurlyBrace = [[self.tokenizer lookahead:2] matches:@"{"];
        
        if(isRegularEnum && isCurlyBrace)
        {
            GBSourceInfo *startInfo = [tokenizer sourceInfoForCurrentToken];
            GBLogXWarn(startInfo, @"unsupported typedef enum at %@!", startInfo);
        }
    }
    return NO;
}

-(bool)isTokenUppercaseOnly:(NSString *)token
{
    return [token isEqualToString:[token uppercaseString]];
}

-(bool)consumeMacro
{
    //Eat away and MACRO
    if( ![[self.tokenizer currentToken] matches:@"="]
          && ![[self.tokenizer currentToken] matches:@"}"]
          && ![[self.tokenizer currentToken] matches:@","]
          && [[self.tokenizer currentToken] isWord]
          && [self isTokenUppercaseOnly:[[self.tokenizer currentToken] stringValue]])
    {
        [self.tokenizer consume:1];
        
        //now a macro may come with bracketed arguments.
        if([[self.tokenizer currentToken] matches:@"("])
        {
            [self.tokenizer consumeTo:@")" usingBlock:nil];
        }
        return YES;
    }
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

- (BOOL)matchMethodDataForProvider:(GBMethodsProvider *)provider from:(NSString *)start to:(NSString *)end required:(BOOL)required {
	// This method only matches class or instance methods, not properties!
	// - (void)assertIvar:(GBIvarData *)ivar matches:(NSString *)firstType,... NS_REQUIRES_NIL_TERMINATION;
	__block GBComment *comment;
	__block GBComment *sectionComment;
	__block NSString *sectionName;	
	__block BOOL assertMethod = YES;
	__block BOOL result = NO;
	__block GBSourceInfo *filedata = nil;
	__block GBMethodType methodType = [start isEqualToString:@"-"] ? GBMethodTypeInstance : GBMethodTypeClass;
	[self updateLastComment:&comment sectionComment:&sectionComment sectionName:&sectionName];
	__block PKToken *startToken = [self.tokenizer currentToken];
	[self.tokenizer consumeFrom:start to:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
		// In order to provide at least some assurance the minus or plus actually starts the method, we validate next token is opening parenthesis. Very simple so might need some refinement... Note that we skip subsequent - or + tokens so that we can handle stuff like '#pragma mark -' gracefully (note that we also do it for + although that shouldn't be necessary, but feels safer).
		if (assertMethod) {
			if ([token matches:@"-"] || [token matches:@"+"]) {
				[self updateLastComment:&comment sectionComment:&sectionComment sectionName:&sectionName];
				methodType = [token matches:@"-"] ? GBMethodTypeInstance : GBMethodTypeClass;
				return;
			}
			if (![token matches:@"("]) {
				if ([token matches:@"@property"]) {
					self.propertyAfterPragma = YES;
					*consume = NO;
					*stop = YES;
					return;
				}
				[self.tokenizer resetComments];
				*consume = NO;
				*stop = YES;
				return;
			}
			assertMethod = NO;
		}
		
		// Prepare source information and reset comments; we alreay read the values so as long as we have found a method, we should reset the comments to prepare ground for next methods. This is needed due to the way this method works - it actually ends by jumping to the first token after the given end symbol, which effectively positions tokenizer to the first token of the following method. Therefore it already consumes any comment preceeding the method. So we can't reset AFTER finished parsing, but rather before! Note that we should only do it once...
		if (!filedata) {
			filedata = [self.tokenizer sourceInfoForToken:token];
			[self.tokenizer resetComments];
		}
		
		// Get result types.
		NSMutableArray *methodResult = [NSMutableArray array];
		[self.tokenizer consumeFrom:@"(" to:@")" usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			[methodResult addObject:[token stringValue]];
		}];
		
		// Get all arguments. Note that we ignore semicolons which may "happen" in declaration before method opening brace!
		__block BOOL parseAttribute = NO;
		__block NSUInteger parenthesisDepth = 0;
		NSMutableArray *methodArgs = [NSMutableArray array];
		[self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
			if ([token matches:@"__attribute__"] || [token matches:@"DEPRECATED_ATTRIBUTE"]) {
				parseAttribute = YES;
				parenthesisDepth = 0;
				return;
			}
			if (parseAttribute) {
				if ([token matches:@"("]) {
					parenthesisDepth++;
				} else if ([token matches:@")"]) {
					parenthesisDepth--;
					if (parenthesisDepth == 0) parseAttribute = NO;
				}
				return;
			}
			
			// If we receive semicolon, ignore it - this works for both - definition and declaration!
			if ([token matches:@";"]) {
				*stop = YES;
				return;
			}
			
			// Get argument name.
			NSString *argumentName = [token stringValue];
			[self.tokenizer consume:1];
			
			__block NSString *argumentVar = nil;
			NSMutableArray *argumentTypes = [NSMutableArray array];
			__block NSMutableArray *terminationMacros = [NSMutableArray array];
            __block BOOL variableArg = NO;
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
                    variableArg = YES;
					[self.tokenizer consume:2];
					[self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
						[terminationMacros addObject:[token stringValue]];
					}];
					*stop = YES; // Ignore the rest of parameters as vararg is the last and above block consumed end token which would confuse above block!
				} else {                
					// If we have no more colon before end, consume the rest of the tokens to get optional termination macros.
					__block BOOL hasColon = NO;
					[self.tokenizer lookaheadTo:end usingBlock:^(PKToken *token, BOOL *stop) {
						if ([token matches:@":"]) {
							hasColon = YES;
							*stop = YES;
						}
					}];
					if (!hasColon) {
						[self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
							[terminationMacros addObject:[token stringValue]];
						}];
						*stop = YES; // Ignore the rest of parameters
					}
				}
                
                if (terminationMacros.count == 0) {
                    terminationMacros = nil;
                }
			} else {
                // remaining tokens are termination macros
                [self.tokenizer consumeTo:end usingBlock:^(PKToken *token, BOOL *consume, BOOL *stop) {
                    [terminationMacros addObject:[token stringValue]];
                }];
                *stop = YES; // Ignore the rest of parameters
            }
            
            GBMethodArgument *argument = [GBMethodArgument methodArgumentWithName:argumentName types:argumentTypes var:argumentVar variableArg:variableArg terminationMacros:terminationMacros];
            [methodArgs addObject:argument];
            *consume = NO;
		}];
		
		// Create method instance and register it.
		GBMethodData *methodData = [GBMethodData methodDataWithType:methodType result:methodResult arguments:methodArgs];
		[methodData registerSourceInfo:filedata];		
		GBLogDebug(@"Matched method %@%@ at line %lu.", start, methodData, methodData.prefferedSourceInfo.lineNumber);
		[self registerComment:comment toObject:methodData startingWith:startToken];
		[methodData setIsRequired:required];
		[provider registerSectionIfNameIsValid:sectionName];
		[provider registerMethod:methodData];
		*consume = NO;
		*stop = YES;
		result = YES;
	}];
	return result;
}

- (void)registerLastCommentToObject:(GBModelBase *)object {
	[self registerComment:[self.tokenizer lastComment] toObject:object startingWith:nil];
	[self.tokenizer resetComments];
}

- (void)registerComment:(GBComment *)comment toObject:(GBModelBase *)object startingWith:(PKToken *)startToken {
	if (startToken) {
		GBComment *postfixComment = [self.tokenizer postfixCommentFrom:startToken];
		if (comment && postfixComment) {
			GBLogInfo(@"Ignored postfix comment '%@' from '%@' in favour of '%@'",
			          [postfixComment.stringValue normalizedDescription],
			          object,
			          [comment.stringValue normalizedDescription]);
		}
		if (!comment && postfixComment) {
			GBLogDebug(@"Using postfix comment '%@' for '%@'",
			          [postfixComment.stringValue normalizedDescription],
			          object);
			comment = postfixComment;
		}
	}
	[object setComment:comment];

	if (comment) GBLogDebug(@"Assigned comment '%@' to '%@'...", [comment.stringValue normalizedDescription], object);
}

- (void)registerSourceInfoFromCurrentTokenToObject:(GBModelBase *)object {
	GBSourceInfo *info = [self.tokenizer sourceInfoForCurrentToken];
	[object registerSourceInfo:info];
}

- (NSString *)sectionNameFromComment:(GBComment *)comment {
	// If comment has nil or whitespace-only string value, ignore it.
	NSCharacterSet* trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];	
	if ([[comment.stringValue stringByTrimmingCharactersInSet:trimSet] length] == 0) return nil;
	
	// If comment doesn't contain section name, ignore it, otherwise return the name.
	NSString *name = [comment.stringValue stringByMatching:self.settings.commentComponents.methodGroupRegex capture:1];
	if ([[name stringByTrimmingCharactersInSet:trimSet] length] == 0) return nil;
	return [name stringByWordifyingWithSpaces];
}

@end

