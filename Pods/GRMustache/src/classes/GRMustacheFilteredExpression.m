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

#import <objc/runtime.h>
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheFilter_private.h"
#import "GRMustacheError.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheToken_private.h"

@interface GRMustacheFilteredExpression()
@property (nonatomic, retain) GRMustacheExpression *filterExpression;
@property (nonatomic, retain) GRMustacheExpression *argumentExpression;
- (id)initWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry;
@end

@implementation GRMustacheFilteredExpression
@synthesize filterExpression=_filterExpression;
@synthesize argumentExpression=_argumentExpression;

+ (instancetype)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry
{
    return [[[self alloc] initWithFilterExpression:filterExpression argumentExpression:argumentExpression curry:curry] autorelease];
}

- (id)initWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry
{
    self = [super init];
    if (self) {
        _filterExpression = [filterExpression retain];
        _argumentExpression = [argumentExpression retain];
        _curry = curry;
    }
    return self;
}

- (void)dealloc
{
    [_filterExpression release];
    [_argumentExpression release];
    [super dealloc];
}

- (void)setToken:(GRMustacheToken *)token
{
    [super setToken:token];
    _filterExpression.token = token;
    _argumentExpression.token = token;
}

- (BOOL)isEqual:(id)expression
{
    if (![expression isKindOfClass:[GRMustacheFilteredExpression class]]) {
        return NO;
    }
    if (![_filterExpression isEqual:((GRMustacheFilteredExpression *)expression).filterExpression]) {
        return NO;
    }
    return [_argumentExpression isEqual:((GRMustacheFilteredExpression *)expression).argumentExpression];
}

- (NSUInteger)hash
{
    return [_filterExpression hash] ^ [_argumentExpression hash];
}


#pragma mark GRMustacheExpression

- (BOOL)hasValue:(id *)value withContext:(GRMustacheContext *)context protected:(BOOL *)protected error:(NSError **)error
{
    id filter;
    if (![_filterExpression hasValue:&filter withContext:context protected:NULL error:error]) {
        return NO;
    }
    
    id argument;
    if (![_argumentExpression hasValue:&argument withContext:context protected:NULL error:error]) {
        return NO;
    }
    
    if (filter == nil) {
        GRMustacheToken *token = self.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu of template %@", token.templateSubstring, (unsigned long)token.line, token.templateID];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu", token.templateSubstring, (unsigned long)token.line];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Missing filter"];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        } else {
            NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
        }
        return NO;
    }
    
    if (![filter respondsToSelector:@selector(transformedValue:)]) {
        GRMustacheToken *token = self.token;
        NSString *renderingErrorDescription = nil;
        if (token) {
            if (token.templateID) {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to %s protocol in tag `%@` at line %lu of template %@: %@", protocol_getName(@protocol(GRMustacheFilter)), token.templateSubstring, (unsigned long)token.line, token.templateID, filter];
            } else {
                renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to %s protocol in tag `%@` at line %lu: %@", protocol_getName(@protocol(GRMustacheFilter)), token.templateSubstring, (unsigned long)token.line, filter];
            }
        } else {
            renderingErrorDescription = [NSString stringWithFormat:@"Object does not conform to %s protocol: %@", protocol_getName(@protocol(GRMustacheFilter)), filter];
        }
        NSError *renderingError = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:renderingErrorDescription forKey:NSLocalizedDescriptionKey]];
        if (error != NULL) {
            *error = renderingError;
        } else {
            NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
        }
        return NO;
    }
    
    if (protected != NULL) {
        *protected = NO;
    }
    
    if (value != NULL) {
        if (_curry && [filter respondsToSelector:@selector(filterByCurryingArgument:)]) {
            *value = [(id<GRMustacheFilter>)filter filterByCurryingArgument:argument];
        } else {
            *value = [(id<GRMustacheFilter>)filter transformedValue:argument];
        }
    }
    return YES;
}

@end
