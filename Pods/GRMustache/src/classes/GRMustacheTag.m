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
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustache_private.h"
#import "GRMustacheTranslateCharacters_private.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheRendering_private.h"

@implementation GRMustacheTag
@synthesize type=_type;
@synthesize expression=_expression;
@synthesize contentType=_contentType;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

- (id)initWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _type = type;
        _expression = [expression retain];
        _contentType = contentType;
    }
    return self;
}

- (NSString *)description
{
    GRMustacheToken *token = _expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (BOOL)escapesHTML
{
    // Default YES.
    // This method is overrided by GRMustacheVariableTag,
    // and sets the difference between {{name}} and {{{name}}} tags.
    return YES;
}

- (NSString *)innerTemplateString
{
    // Default empty string.
    // This method is overrided by GRMustacheSectionTag,
    // which returns the content of the section.
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (!context) {
        // Consistency with GRMustacheSectionTag handling of nil context.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    // Default empty string.
    // This method is overrided by GRMustacheSectionTag and
    // GRMustacheAccumulatorTag.
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
    }
    return @"";
}

- (GRMustacheTemplateRepository *)templateRepository
{
    return [GRMustacheRendering currentTemplateRepository];
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    NSAssert(requiredContentType == _contentType, @"Not implemented");
    
    BOOL success = YES;
    
    @autoreleasepool {
        
        // Evaluate expression
        
        BOOL protected;
        __block id object;
        NSError *valueError;
        if (![_expression hasValue:&object withContext:context protected:&protected error:&valueError]) {
            
            // Error
            
            if (error != NULL) {
                *error = [valueError retain];   // retain error so that it survives the @autoreleasepool block
            }
            
            success = NO;
            
        } else {
        
            // Hide object if it is protected
            
            if (protected) {
                // Object is protected: it may enter the context stack, and provide
                // value for `.` and `.name`. However, it must not expose its keys.
                //
                // The goal is to have `{{ safe.name }}` and `{{#safe}}{{.name}}{{/safe}}`
                // work, but not `{{#safe}}{{name}}{{/safe}}`.
                //
                // Rationale:
                //
                // Let's look at `{{#safe}}{{#hacker}}{{name}}{{/hacker}}{{/safe}}`:
                //
                // The protected context stack contains the "protected root":
                // { safe : { name: "important } }.
                //
                // Since the user has used the key `safe`, he expects `name` to be
                // safe as well, even if `hacker` has defined its own `name`.
                //
                // So we need to have `name` come from `safe`, not from `hacker`.
                // We should thus start looking in `safe` first. But `safe` was
                // not initially in the protected context stack. Only the protected
                // root was. Hence somebody had `safe` in the protected context
                // stack.
                //
                // Who has objects enter the context stack? Rendering objects do. So
                // rendering objects have to know that values are protected or not,
                // and choose the correct bucket accordingly.
                //
                // Who can write his own rendering objects? The end user does. So
                // the end user must carefully read a documentation about safety,
                // and then carefully code his rendering objects so that they
                // conform to this safety notice.
                //
                // Of course this is not what we want. So `name` can not be
                // protected. Since we don't want to let the user think he is data
                // is given protected when it is not, we prevent this whole pattern, and
                // forbid `{{#safe}}{{name}}{{/safe}}`.
                context = [context contextByAddingHiddenObject:object];
            }
            
            
            // Rendered value hooks
            
            NSArray *tagDelegateStack = [context tagDelegateStack];
            for (id<GRMustacheTagDelegate> tagDelegate in [tagDelegateStack reverseObjectEnumerator]) { // willRenderObject: from top to bottom
                if ([tagDelegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                    object = [tagDelegate mustacheTag:self willRenderObject:object];
                }
            }
            
            
            // Render value
        
            BOOL objectHTMLSafe = NO;
            NSError *renderingError = nil;  // set it to nil, so that we can help lazy coders who return nil as a valid rendering.
            NSString *rendering = [[GRMustacheRendering renderingObjectForObject:object] renderForMustacheTag:self context:context HTMLSafe:&objectHTMLSafe error:&renderingError];
            
            if (rendering == nil && renderingError == nil)
            {
                // Rendering is nil, but rendering error is not set.
                //
                // Assume a rendering object coded by a lazy programmer, whose
                // intention is to render nothing.
                
                rendering = @"";
            }
            
            
            // Finish
            
            if (rendering)
            {
                // render
                
                if (rendering.length > 0) {
                    if ((requiredContentType == GRMustacheContentTypeHTML) && !objectHTMLSafe && self.escapesHTML) {
                        rendering = GRMustacheTranslateHTMLCharacters(rendering);
                    }
                    GRMustacheBufferAppendString(buffer, rendering);
                }
                
                
                // Post-rendering hooks
                
                for (id<GRMustacheTagDelegate> tagDelegate in tagDelegateStack) { // didRenderObject: from bottom to top
                    if ([tagDelegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                        [tagDelegate mustacheTag:self didRenderObject:object as:rendering];
                    }
                }
            }
            else
            {
                // Error
                
                if (error != NULL) {
                    *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
                } else {
                    NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
                }
                success = NO;
                
                
                // Post-error hooks
                
                for (id<GRMustacheTagDelegate> tagDelegate in tagDelegateStack) { // didFailRenderingObject: from bottom to top
                    if ([tagDelegate respondsToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) {
                        [tagDelegate mustacheTag:self didFailRenderingObject:object withError:renderingError];
                    }
                }
            }
        }
    }
    
    if (!success && error) [*error autorelease];    // the error has been retained inside the @autoreleasepool block
    return success;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // tags can not override any other component
    return component;
}

@end
