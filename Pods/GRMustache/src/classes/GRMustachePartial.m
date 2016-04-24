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

#import "GRMustachePartial_private.h"
#import "GRMustacheAST_private.h"
#import "GRMustacheTranslateCharacters_private.h"
#import "GRMustacheRendering_private.h"

@implementation GRMustachePartial
@synthesize AST=_AST;

- (void)dealloc
{
    [_AST release];
    [super dealloc];
}

#pragma mark <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(GRMustacheBuffer *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    if (!context) {
        // With a nil context, the method would return NO without setting the
        // error argument.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    GRMustacheContentType partialContentType = _AST.contentType;
    BOOL needsEscapingBuffer = NO;
    GRMustacheBuffer unescapedBuffer;
    GRMustacheBuffer *renderingBuffer = nil;
    
    if (requiredContentType == GRMustacheContentTypeHTML && (partialContentType != GRMustacheContentTypeHTML)) {
        // Self renders text, but is asked for HTML.
        // This happens when self is a text partial embedded in a HTML template.
        //
        // We'll have to HTML escape our rendering.
        needsEscapingBuffer = YES;
        unescapedBuffer = GRMustacheBufferCreate(1024);
        renderingBuffer = &unescapedBuffer;
    } else {
        // Self renders text and is asked for text,
        // or self renders HTML and is asked for HTML.
        //
        // We won't need any specific processing here.
        renderingBuffer = buffer;
    }
    
    BOOL success = YES;
    
    [GRMustacheRendering pushCurrentContentType:partialContentType];
    for (id<GRMustacheTemplateComponent> component in _AST.templateComponents) {
        // component may be overriden by a GRMustacheInheritablePartial: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:partialContentType inBuffer:renderingBuffer withContext:context error:error]) {
            success = NO;
            break;
        }
    }
    [GRMustacheRendering popCurrentContentType];
    
    if (!success) {
        if (needsEscapingBuffer) {
            GRMustacheBufferRelease(&unescapedBuffer);
        }
        return NO;
    }
    
    if (needsEscapingBuffer) {
        NSString *unescapedString = GRMustacheBufferGetStringAndRelease(&unescapedBuffer);
        GRMustacheBufferAppendString(buffer, GRMustacheTranslateHTMLCharacters(unescapedString));
    }
    
    return YES;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Look for the last inheritable component in inner components.
    //
    // This allows a partial do define an inheritable section:
    //
    //    {
    //        data: { },
    //        expected: "partial1",
    //        name: "Partials in inheritable partials can override inheritable sections",
    //        template: "{{<partial2}}{{>partial1}}{{/partial2}}"
    //        partials: {
    //            partial1: "{{$inheritable}}partial1{{/inheritable}}";
    //            partial2: "{{$inheritable}}ignored{{/inheritable}}";
    //        },
    //    }
    for (id<GRMustacheTemplateComponent> innerComponent in _AST.templateComponents) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}

@end
