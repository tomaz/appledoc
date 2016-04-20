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

#import "GRMustacheVariableTag_private.h"

@interface GRMustacheVariableTag()
- (id)initWithExpression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType escapesHTML:(BOOL)escapesHTML;
@end

@implementation GRMustacheVariableTag

+ (instancetype)variableTagWithExpression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType escapesHTML:(BOOL)escapesHTML
{
    return [[[self alloc] initWithExpression:expression contentType:contentType escapesHTML:escapesHTML] autorelease];
}


#pragma mark - GRMustacheTag

@synthesize escapesHTML=_escapesHTML;

- (GRMustacheTagType)type
{
    return GRMustacheTagTypeVariable;
}


#pragma mark - Private

- (id)initWithExpression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType escapesHTML:(BOOL)escapesHTML
{
    self = [super initWithType:GRMustacheTagTypeVariable expression:expression contentType:contentType];
    if (self) {
        _escapesHTML = escapesHTML;
    }
    return self;
}

@end
