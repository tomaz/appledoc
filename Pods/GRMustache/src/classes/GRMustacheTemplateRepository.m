// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheCompiler_private.h"
#import "GRMustacheError.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustachePartial_private.h"
#import "GRMustacheAST_private.h"

static NSString* const GRMustacheDefaultExtension = @"mustache";


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a base URL.
 */
@interface GRMustacheTemplateRepositoryBaseURL : GRMustacheTemplateRepository {
@private
    NSURL *_baseURL;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a directory identified by its path.
 */
@interface GRMustacheTemplateRepositoryDirectory : GRMustacheTemplateRepository {
@private
    NSString *_directoryPath;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a bundle.
 */
@interface GRMustacheTemplateRepositoryBundle : GRMustacheTemplateRepository {
@private
    NSBundle *_bundle;
    NSString *_templateExtension;
    NSStringEncoding _encoding;
}
- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding;
@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryPartialsDictionary

/**
 * Private subclass of GRMustacheTemplateRepository that is its own data source,
 * and loads templates from a dictionary.
 */
@interface GRMustacheTemplateRepositoryPartialsDictionary : GRMustacheTemplateRepository {
@private
    NSDictionary *_partialsDictionary;
}
- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary;
@end


// =============================================================================
#pragma mark - GRMustacheTemplateRepository

@interface GRMustacheTemplateRepository()

/**
 * Parses templateString and returns an abstract syntax tree.
 * 
 * @param templateString  A Mustache template string.
 * @param contentType     The content type of the returned AST.
 * @param templateID      The template ID of the template, or nil if the
 *                        template string is not tied to any identified template.
 * @param error           If there is an error, upon return contains an NSError
 *                        object that describes the problem.
 *
 * @return a GRMustacheAST instance.
 * 
 * @see GRMustacheTemplateRepository
 */
- (GRMustacheAST *)ASTFromString:(NSString *)templateString contentType:(GRMustacheContentType)contentType templateID:(id)templateID error:(NSError **)error;

@end

@implementation GRMustacheTemplateRepository
@synthesize dataSource=_dataSource;
@synthesize configuration=_configuration;

+ (instancetype)templateRepositoryWithBaseURL:(NSURL *)URL
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (instancetype)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBaseURL alloc] initWithBaseURL:URL templateExtension:ext encoding:encoding] autorelease];
}

+ (instancetype)templateRepositoryWithDirectory:(NSString *)path
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (instancetype)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryDirectory alloc] initWithDirectory:path templateExtension:ext encoding:encoding] autorelease];
}

+ (instancetype)templateRepositoryWithBundle:(NSBundle *)bundle
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:GRMustacheDefaultExtension encoding:NSUTF8StringEncoding] autorelease];
}

+ (instancetype)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    return [[[GRMustacheTemplateRepositoryBundle alloc] initWithBundle:bundle templateExtension:ext encoding:encoding] autorelease];
}

+ (instancetype)templateRepositoryWithDictionary:(NSDictionary *)partialsDictionary
{
    return [[[GRMustacheTemplateRepositoryPartialsDictionary alloc] initWithPartialsDictionary:partialsDictionary] autorelease];
}

+ (instancetype)templateRepository
{
    return [[[GRMustacheTemplateRepository alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        _partialForTemplateID = [[NSMutableDictionary alloc] init];
        _partialForTemplateString = [[NSMutableDictionary alloc] init];
        _configuration = [[GRMustacheConfiguration defaultConfiguration] copy];
    }
    return self;
}

- (void)dealloc
{
    [_partialForTemplateID release];
    [_partialForTemplateString release];
    [_configuration release];
    [super dealloc];
}

- (GRMustacheTemplate *)templateNamed:(NSString *)name error:(NSError **)error
{
    GRMustachePartial *partial = [self partialNamed:name relativeToTemplateID:nil error:error];
    if (!partial) {
        return nil;
    }
    
    GRMustacheTemplate *template = [[[GRMustacheTemplate alloc] init] autorelease];
    template.templateRepository = self;
    template.partial = partial;
    template.baseContext = _configuration.baseContext;
    return template;
}

- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)error
{
    return [self templateFromString:templateString contentType:_configuration.contentType error:error];
}

- (GRMustacheTemplate *)templateFromString:(NSString *)templateString contentType:(GRMustacheContentType)contentType error:(NSError **)error
{
    GRMustachePartial *partial = [self partialFromString:templateString contentType:contentType error:error];
    if (!partial) {
        return nil;
    }
    
    GRMustacheTemplate *template = [[[GRMustacheTemplate alloc] init] autorelease];
    template.templateRepository = self;
    template.partial = partial;
    template.baseContext = _configuration.baseContext;
    return template;
}

- (void)reloadTemplates
{
    @synchronized(self) {
        [_partialForTemplateID removeAllObjects];
        [_partialForTemplateString removeAllObjects];
    }
}

- (void)setConfiguration:(GRMustacheConfiguration *)configuration
{
    if (_configuration.isLocked) {
        [NSException raise:NSGenericException format:@"%@ was mutated after template compilation", self];
        return;
    }
    
    if (_configuration != configuration) {
        [_configuration release];
        _configuration = [configuration copy];
    }
}


#pragma mark Private

- (GRMustacheAST *)ASTFromString:(NSString *)templateString contentType:(GRMustacheContentType)contentType templateID:(id)templateID error:(NSError **)error
{
    GRMustacheAST *AST = nil;
    @autoreleasepool {
        // It's time to lock the configuration.
        [_configuration lock];
        
        // Create a Mustache compiler that loads partials from self
        GRMustacheCompiler *compiler = [[[GRMustacheCompiler alloc] initWithContentType:contentType] autorelease];
        compiler.templateRepository = self;
        compiler.baseTemplateID = templateID;
        
        // Create a Mustache parser that feeds the compiler
        GRMustacheParser *parser = [[[GRMustacheParser alloc] initWithConfiguration:_configuration] autorelease];
        parser.delegate = compiler;
        
        // Parse and extract template components from the compiler
        [parser parseTemplateString:templateString templateID:templateID];
        AST = [[compiler ASTReturningError:error] retain];  // make sure AST is not released by autoreleasepool
        
        // make sure error is not released by autoreleasepool
        if (!AST && error != NULL) [*error retain];
    }
    if (!AST && error != NULL) [*error autorelease];
    return [AST autorelease];
}

- (GRMustachePartial *)partialNamed:(NSString *)name relativeToTemplateID:(id)baseTemplateID error:(NSError **)error
{
    // Protect our _partialForTemplateID dictionary, and our dataSource
    @synchronized(self) {
        
        id templateID = nil;
        if (name) {
           templateID = [self.dataSource templateRepository:self templateIDForName:name relativeToTemplateID:baseTemplateID];
        }
        if (templateID == nil) {
            NSError *missingTemplateError = [NSError errorWithDomain:GRMustacheErrorDomain
                                                                code:GRMustacheErrorCodeTemplateNotFound
                                                            userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: `%@`", name, nil]
                                                                                                 forKey:NSLocalizedDescriptionKey]];
            if (error != NULL) {
                *error = missingTemplateError;
            } else {
                NSLog(@"GRMustache error: %@", missingTemplateError.localizedDescription);
            }
            return nil;
        }
        
        GRMustachePartial *partial = [_partialForTemplateID objectForKey:templateID];
        
        if (partial == nil) {
            // templateRepository:templateStringForTemplateID:error: is a dataSource method.
            // We are not sure the dataSource will set error when not returning any templateString.
            // We thus have to take extra care of error handling here.
            NSError *templateStringError = nil;
            NSString *templateString = [self.dataSource templateRepository:self templateStringForTemplateID:templateID error:&templateStringError];
            if (!templateString) {
                if (templateStringError == nil) {
                    templateStringError = [NSError errorWithDomain:GRMustacheErrorDomain
                                                              code:GRMustacheErrorCodeTemplateNotFound
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: `%@`", name, nil]
                                                                                               forKey:NSLocalizedDescriptionKey]];
                }
                if (error != NULL) {
                    *error = templateStringError;
                } else {
                    NSLog(@"GRMustache error: %@", templateStringError.localizedDescription);
                }
                return nil;
            }
            
            
            // store an empty template before compiling, so that we support
            // recursive partials
            
            partial = [[[GRMustachePartial alloc] init] autorelease];
            [_partialForTemplateID setObject:partial forKey:templateID];
            
            
            // Compile
            
            GRMustacheAST *AST = [self ASTFromString:templateString contentType:_configuration.contentType templateID:templateID error:error];
            
            
            // compiling done
            
            if (AST) {
                partial.AST = AST;
            } else {
                // forget invalid empty template
                [_partialForTemplateID removeObjectForKey:templateID];
                partial = nil;
            }
        }
        
        return partial;
    }
}

- (GRMustachePartial *)partialFromString:(NSString *)templateString contentType:(GRMustacheContentType)contentType error:(NSError **)error
{
    // Protect our _partialForTemplateString dictionary
    @synchronized(self) {
        GRMustachePartial *partial = [_partialForTemplateID objectForKey:templateString];
        
        if (partial == nil) {
            GRMustacheAST *AST = [self ASTFromString:templateString contentType:contentType templateID:nil error:error];
            if (!AST) {
                return nil;
            }
            
            partial = [[[GRMustachePartial alloc] init] autorelease];
            partial.AST = AST;
            
            [_partialForTemplateString setObject:partial forKey:templateString];
        }
        
        return partial;
    }
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBaseURL

@interface GRMustacheTemplateRepositoryBaseURL()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryBaseURL

- (id)initWithBaseURL:(NSURL *)baseURL templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        _baseURL = [baseURL retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_baseURL release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    // Rebase template names starting with a /
    if ([name characterAtIndex:0] == '/') {
        name = [name substringFromIndex:1];
        baseTemplateID = nil;
    }
    
    if (name.length == 0) {
        return nil;
    }
    
    if (baseTemplateID) {
        NSAssert([baseTemplateID isKindOfClass:[NSURL class]], @"");
        if (_templateExtension.length == 0) {
            return [[NSURL URLWithString:name relativeToURL:(NSURL *)baseTemplateID] URLByStandardizingPath];
        }
        return [[NSURL URLWithString:[name stringByAppendingPathExtension:_templateExtension] relativeToURL:(NSURL *)baseTemplateID] URLByStandardizingPath];
    }
    if (_templateExtension.length == 0) {
        return [[_baseURL URLByAppendingPathComponent:name] URLByStandardizingPath];
    }
    return [[[_baseURL URLByAppendingPathComponent:name] URLByAppendingPathExtension:_templateExtension] URLByStandardizingPath];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error
{
    NSAssert([templateID isKindOfClass:[NSURL class]], @"");
    return [NSString stringWithContentsOfURL:(NSURL *)templateID encoding:_encoding error:error];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryDirectory

@interface GRMustacheTemplateRepositoryDirectory()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryDirectory

- (id)initWithDirectory:(NSString *)directoryPath templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        _directoryPath = [directoryPath retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_directoryPath release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    // Rebase template names starting with a /
    if ([name characterAtIndex:0] == '/') {
        name = [name substringFromIndex:1];
        baseTemplateID = nil;
    }
    
    if (name.length == 0) {
        return nil;
    }
    
    if (baseTemplateID) {
        NSAssert([baseTemplateID isKindOfClass:[NSString class]], @"");
        NSString *basePath = [(NSString *)baseTemplateID stringByDeletingLastPathComponent];
        if (_templateExtension.length == 0) {
            return [[basePath stringByAppendingPathComponent:name] stringByStandardizingPath];
        }
        return [[basePath stringByAppendingPathComponent:[name stringByAppendingPathExtension:_templateExtension]] stringByStandardizingPath];
    }
    if (_templateExtension.length == 0) {
        return [[_directoryPath stringByAppendingPathComponent:name] stringByStandardizingPath];
    }
    return [[[_directoryPath stringByAppendingPathComponent:name] stringByAppendingPathExtension:_templateExtension] stringByStandardizingPath];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error
{
    NSAssert([templateID isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString *)templateID encoding:_encoding error:error];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryBundle

@interface GRMustacheTemplateRepositoryBundle()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryBundle

- (id)initWithBundle:(NSBundle *)bundle templateExtension:(NSString *)templateExtension encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self) {
        if (bundle == nil) {
            bundle = [NSBundle mainBundle];
        }
        _bundle = [bundle retain];
        _templateExtension = [templateExtension retain];
        _encoding = encoding;
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_bundle release];
    [_templateExtension release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    return [_bundle pathForResource:name ofType:_templateExtension];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error
{
    NSAssert([templateID isKindOfClass:[NSString class]], @"");
    return [NSString stringWithContentsOfFile:(NSString *)templateID encoding:_encoding error:error];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheTemplateRepositoryPartialsDictionary

@interface GRMustacheTemplateRepositoryPartialsDictionary()<GRMustacheTemplateRepositoryDataSource>
@end

@implementation GRMustacheTemplateRepositoryPartialsDictionary

- (id)initWithPartialsDictionary:(NSDictionary *)partialsDictionary
{
    self = [super init];
    if (self) {
        _partialsDictionary = [partialsDictionary retain];
        self.dataSource = self;
    }
    return self;
}

- (void)dealloc
{
    [_partialsDictionary release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    return name;
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error
{
    return [_partialsDictionary objectForKey:templateID];
}

@end


