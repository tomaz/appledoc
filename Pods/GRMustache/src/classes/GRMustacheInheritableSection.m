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

#import "GRMustacheInheritableSection_private.h"

@interface GRMustacheInheritableSection()
@property (nonatomic, readonly) NSString *identifier;
/**
 * @see +[GRMustacheInheritableSection inheritableSectionWithComponents:]
 */
- (instancetype)initWithIdentifier:(NSString *)identifier components:(NSArray *)components;

@end

@implementation GRMustacheInheritableSection
@synthesize identifier=_identifier;

+ (instancetype)inheritableSectionWithIdentifier:(NSString *)identifier components:(NSArray *)components
{
    return [[[self alloc] initWithIdentifier:identifier components:components] autorelease];
}

- (void)dealloc
{
    [_identifier release];
    [_components release];
    [super dealloc];
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    if (!context) {
        // With a nil context, the method would return NO without setting the
        // error argument.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheInheritablePartial: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:requiredContentType inBuffer:buffer withContext:context error:error]) {
            return NO;
        }
    }
    
    return YES;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Inheritable section can only override inheritable section
    if (![component isKindOfClass:[GRMustacheInheritableSection class]]) {
        return component;
    }
    GRMustacheInheritableSection *otherSection = (GRMustacheInheritableSection *)component;
    
    // Identifiers must match
    if (![otherSection.identifier isEqual:_identifier]) {
        return otherSection;
    }
    
    // OK, override with self
    return self;
}


#pragma mark - Private

- (instancetype)initWithIdentifier:(NSString *)identifier components:(NSArray *)components
{
    self = [self init];
    if (self) {
        _identifier = [identifier retain];
        _components = [components retain];
    }
    return self;
}

@end
