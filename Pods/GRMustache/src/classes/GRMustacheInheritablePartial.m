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

#import "GRMustacheInheritablePartial_private.h"
#import "GRMustachePartial_private.h"
#import "GRMustacheContext_private.h"

@interface GRMustacheInheritablePartial()
- (id)initWithPartial:(GRMustachePartial *)partial components:(NSArray *)components;
@end

@implementation GRMustacheInheritablePartial
@synthesize partial=_partial;

+ (instancetype)inheritablePartialWithPartial:(GRMustachePartial *)partial components:(NSArray *)components
{
    return [[[self alloc] initWithPartial:partial components:components] autorelease];
}

- (void)dealloc
{
    [_partial release];
    [_components release];
    [super dealloc];
}

#pragma mark - GRMustacheTemplateComponent

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    context = [context contextByAddingInheritablePartial:self];
    return [_partial renderContentType:requiredContentType inBuffer:buffer withContext:context error:error];
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // look for the last inheritable component in inner components
    for (id<GRMustacheTemplateComponent> innerComponent in _components) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}


#pragma mark - Private

- (id)initWithPartial:(GRMustachePartial *)partial components:(NSArray *)components
{
    self = [super init];
    if (self) {
        _partial = [partial retain];
        _components = [components retain];
    }
    return self;
}

@end
