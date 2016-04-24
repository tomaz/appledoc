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

#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheKeyAccess_private.h"

@interface GRMustacheScopedExpression()
@property (nonatomic, retain) GRMustacheExpression *baseExpression;
@property (nonatomic, copy) NSString *scopeIdentifier;

- (id)initWithBaseExpression:(GRMustacheExpression *)baseExpression scopeIdentifier:(NSString *)scopeIdentifier;
@end

@implementation GRMustacheScopedExpression
@synthesize baseExpression=_baseExpression;
@synthesize scopeIdentifier=_scopeIdentifier;

+ (instancetype)expressionWithBaseExpression:(GRMustacheExpression *)baseExpression scopeIdentifier:(NSString *)scopeIdentifier
{
    return [[[self alloc] initWithBaseExpression:baseExpression scopeIdentifier:scopeIdentifier] autorelease];
}

- (id)initWithBaseExpression:(GRMustacheExpression *)baseExpression scopeIdentifier:(NSString *)scopeIdentifier
{
    self = [super init];
    if (self) {
        self.baseExpression = baseExpression;
        self.scopeIdentifier = scopeIdentifier;
    }
    return self;
}

- (void)dealloc
{
    [_baseExpression release];
    [_scopeIdentifier release];
    [super dealloc];
}

- (void)setToken:(GRMustacheToken *)token
{
    [super setToken:token];
    _baseExpression.token = token;
}

- (BOOL)isEqual:(id)expression
{
    if (![expression isKindOfClass:[GRMustacheScopedExpression class]]) {
        return NO;
    }
    if (![_baseExpression isEqual:((GRMustacheScopedExpression *)expression).baseExpression]) {
        return NO;
    }
    return [_scopeIdentifier isEqual:((GRMustacheScopedExpression *)expression).scopeIdentifier];
}

- (NSUInteger)hash
{
    return [_baseExpression hash] ^ [_scopeIdentifier hash];
}


#pragma mark - GRMustacheExpression

- (BOOL)hasValue:(id *)value withContext:(GRMustacheContext *)context protected:(BOOL *)protected error:(NSError **)error
{
    id scopedValue;
    if (![_baseExpression hasValue:&scopedValue withContext:context protected:NULL error:error]) {
        return NO;
    }
    
    if (protected != NULL) {
        *protected = NO;
    }
    if (value) {
        *value = [GRMustacheKeyAccess valueForMustacheKey:_scopeIdentifier inObject:scopedValue unsafeKeyAccess:context.unsafeKeyAccess];
    }
    return YES;
}

@end
