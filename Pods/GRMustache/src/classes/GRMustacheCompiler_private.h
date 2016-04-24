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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheParser_private.h"
#import "GRMustacheContentType.h"

@class GRMustacheTemplateRepository;
@class GRMustacheAST;

/**
 * The GRMustacheCompiler interprets GRMustacheTokens provided by a
 * GRMustacheParser, and outputs a syntax tree of objects conforming to the
 * GRMustacheTemplateComponent protocol, the template components that make a
 * Mustache template.
 *
 * @see GRMustacheTemplateComponent
 * @see GRMustacheToken
 * @see GRMustacheParser
 */
@interface GRMustacheCompiler : NSObject<GRMustacheParserDelegate> {
@private
    NSError *_fatalError;
    
    NSMutableArray *_currentComponents;
    NSMutableArray *_componentsStack;
    
    GRMustacheToken *_currentOpeningToken;
    NSMutableArray *_openingTokenStack;
    
    NSObject *_currentTagValue;
    NSMutableArray *_tagValueStack;
    
    GRMustacheTemplateRepository *_templateRepository;
    id _baseTemplateID;
    GRMustacheContentType _contentType;
    BOOL _contentTypeLocked;
}

/**
 * The template repository that provides partial templates to the compiler.
 */
@property (nonatomic, assign) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_INTERNAL;

/**
 * ID of the currently compiled template
 */
@property (nonatomic, retain) id baseTemplateID GRMUSTACHE_API_INTERNAL;

/**
 * Returns an initialized compiler.
 *
 * @param contentType  The contentType that affects the compilation phase.
 *
 * @return a compiler
 */
- (id)initWithContentType:(GRMustacheContentType)contentType GRMUSTACHE_API_INTERNAL;

/**
 * Returns a Mustache Abstract Syntax Tree.
 *
 * The AST will contain something if a GRMustacheParser has provided
 * GRMustacheToken instances to the compiler.
 *
 * For example:
 *
 * ```
 * // Create a Mustache compiler
 * GRMustacheCompiler *compiler = [[[GRMustacheCompiler alloc] initWithContentType:...] autorelease];
 *
 * // Some GRMustacheCompilerDataSource tells the compiler where are the
 * // partials.
 * compiler.dataSource = ...;
 *
 * // Create a Mustache parser
 * GRMustacheParser *parser = [[[GRMustacheParser alloc] initWithContentType:...] autorelease];
 *
 * // The parser feeds the compiler
 * parser.delegate = compiler;
 *
 * // Parse some string
 * [parser parseTemplateString:... templateID:...];
 *
 * // Extract template components from the compiler
 * GRMustacheAST *AST = [compiler ASTReturningError:...];
 * ```
 *
 * @param error  If there is an error building the abstract syntax tree, upon
 *               return contains an NSError object that describes the problem.
 *
 * @return A GRMustacheAST instance
 *
 * @see GRMustacheAST
 */
- (GRMustacheAST *)ASTReturningError:(NSError **)error GRMUSTACHE_API_INTERNAL;
@end
