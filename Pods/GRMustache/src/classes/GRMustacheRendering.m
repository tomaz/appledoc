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
#import <pthread.h>
#import "GRMustacheRendering_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateRepository_private.h"


// =============================================================================
#pragma mark - Rendering declarations


// GRMustacheNilRendering renders for nil

@interface GRMustacheNilRendering : NSObject<GRMustacheRendering>
@end
static GRMustacheNilRendering *nilRendering;


// GRMustacheBlockRendering renders with a block

@interface GRMustacheBlockRendering : NSObject<GRMustacheRendering> {
@private
    NSString *(^_block)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block;
@end


// NSNull, NSNumber, NSString, NSObject, NSFastEnumeration rendering

typedef NSString *(*GRMustacheRenderIMP)(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderGeneric(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);


// =============================================================================
#pragma mark - Current Template Repository

static pthread_key_t GRCurrentTemplateRepositoryStackKey;
void freeCurrentTemplateRepositoryStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentTemplateRepositoryStack() pthread_key_create(&GRCurrentTemplateRepositoryStackKey, freeCurrentTemplateRepositoryStack)
#define getCurrentThreadCurrentTemplateRepositoryStack() (NSMutableArray *)pthread_getspecific(GRCurrentTemplateRepositoryStackKey)
#define setCurrentThreadCurrentTemplateRepositoryStack(classes) pthread_setspecific(GRCurrentTemplateRepositoryStackKey, classes)


// =============================================================================
#pragma mark - Current Content Type

static pthread_key_t GRCurrentContentTypeStackKey;
void freeCurrentContentTypeStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentContentTypeStack() pthread_key_create(&GRCurrentContentTypeStackKey, freeCurrentContentTypeStack)
#define getCurrentThreadCurrentContentTypeStack() (NSMutableArray *)pthread_getspecific(GRCurrentContentTypeStackKey)
#define setCurrentThreadCurrentContentTypeStack(classes) pthread_setspecific(GRCurrentContentTypeStackKey, classes)


// =============================================================================
#pragma mark - GRMustacheRendering

@implementation GRMustacheRendering

+ (void)initialize
{
    setupCurrentTemplateRepositoryStack();
    setupCurrentContentTypeStack();
    
    nilRendering = [[GRMustacheNilRendering alloc] init];
    
    // We could have declared categories on NSNull, NSNumber, NSString and
    // NSDictionary.
    //
    // We do not, because many GRMustache users use the static library, and
    // we don't want to force them adding the `-ObjC` option to their
    // target's "Other Linker Flags" (which is required for code declared by
    // categories to be loaded).
    //
    // Instead, dynamically alter the classes whose rendering implementation
    // is already known.
    //
    // Other classes will be dynamically attached their rendering implementation
    // in the GRMustacheRenderGeneric implementation attached to NSObject.
    [self registerRenderingImplementation:GRMustacheRenderNSNull   forClass:[NSNull class]];
    [self registerRenderingImplementation:GRMustacheRenderNSNumber forClass:[NSNumber class]];
    [self registerRenderingImplementation:GRMustacheRenderNSString forClass:[NSString class]];
    [self registerRenderingImplementation:GRMustacheRenderNSObject forClass:[NSDictionary class]];
    [self registerRenderingImplementation:GRMustacheRenderGeneric  forClass:[NSObject class]];
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    // All objects but nil know how to render (see setupRendering).
    return object ?: nilRendering;
}

+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    return [[[GRMustacheBlockRendering alloc] initWithBlock:block] autorelease];
}


#pragma mark - <GRMustacheRendering>

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return @"";
}


#pragma mark - Current Template Repository

+ (void)pushCurrentTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentTemplateRepositoryStack(stack);
    }
    [stack addObject:templateRepository];
}

+ (void)popCurrentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    NSAssert(stack, @"Missing currentTemplateRepositoryStack");
    NSAssert(stack.count > 0, @"Empty currentTemplateRepositoryStack");
    [stack removeLastObject];
}

+ (GRMustacheTemplateRepository *)currentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    return [stack lastObject];
}


#pragma mark - Current Content Type

+ (void)pushCurrentContentType:(GRMustacheContentType)contentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentContentTypeStack(stack);
    }
    [stack addObject:[NSNumber numberWithUnsignedInteger:contentType]];
}

+ (void)popCurrentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    NSAssert(stack, @"Missing currentContentTypeStack");
    NSAssert(stack.count > 0, @"Empty currentContentTypeStack");
    [stack removeLastObject];
}

+ (GRMustacheContentType)currentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (stack.count > 0) {
        return [(NSNumber *)[stack lastObject] unsignedIntegerValue];
    }
    return ([self currentTemplateRepository].configuration ?: [GRMustacheConfiguration defaultConfiguration]).contentType;
}


#pragma mark - Private

/**
 * Have the class _aClass_ conform to the GRMustacheRendering protocol by adding
 * the GRMustacheRendering protocol to the list of protocols _aClass_ conforms
 * to, and setting the implementation of
 * renderForMustacheTag:context:HTMLSafe:error: to _imp_.
 *
 * @param imp     an implementation
 * @param aClass  the class to modify
 */
+ (void)registerRenderingImplementation:(GRMustacheRenderIMP)imp forClass:(Class)klass
{
    SEL selector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
    Protocol *protocol = @protocol(GRMustacheRendering);
    
    // Add method implementation
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, YES, YES);
    class_addMethod(klass, selector, (IMP)imp, methodDescription.types);
    
    // Add protocol conformance
    class_addProtocol(klass, protocol);
}



@end


// =============================================================================
#pragma mark - Rendering Implementations

@implementation GRMustacheNilRendering

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeSection:
            // {{ nil }}
            // {{# nil }}...{{/}}
            return @"";
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ nil }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}

@end


@implementation GRMustacheBlockRendering

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    if (block == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Can't build a rendering object with a nil block."];
    }
    
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _block(tag, context, HTMLSafe, error);
}

@end


static NSString *GRMustacheRenderGeneric(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // Self doesn't know (yet) how to render
    
    Class klass = object_getClass(self);
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)])
    {
        // Future invocations will use GRMustacheRenderNSFastEnumeration
        [GRMustacheRendering registerRenderingImplementation:GRMustacheRenderNSFastEnumeration forClass:klass];
        return GRMustacheRenderNSFastEnumeration(self, _cmd, tag, context, HTMLSafe, error);
    }
    
    if (klass != [NSObject class])
    {
        // Future invocations will use GRMustacheRenderNSObject
        [GRMustacheRendering registerRenderingImplementation:GRMustacheRenderNSObject forClass:klass];
    }
    
    return GRMustacheRenderNSObject(self, _cmd, tag, context, HTMLSafe, error);
}


static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeSection:
            // {{ null }}
            // {{# null }}...{{/}}
            return @"";
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ null }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}


static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ number }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# number }}...{{/}}
            if ([self boolValue]) {
                // janl/mustache.js and defunkt/mustache don't push bools in the
                // context stack. Follow their path, and avoid the creation of a
                // useless context nobody cares about.
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                return @"";
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ number }}...{{/}}
            if ([self boolValue]) {
                return @"";
            } else {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}


static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return self;
            
        case GRMustacheTagTypeSection:
            // {{# string }}...{{/}}
            if (self.length > 0) {
                context = [context newContextByAddingObject:self];
                NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                [context release];
                return rendering;
            } else {
                return @"";
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ string }}...{{/}}
            if (self.length > 0) {
                return @"";
            } else {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}


static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ object }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# object }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ object }}...{{/}}
            return @"";
    }
}


static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable: {
            // {{ list }}
            // Render the concatenation of the rendering of each item
            
            BOOL success = YES;
            GRMustacheBuffer buffer = GRMustacheBufferCreate(1024);
            BOOL oneItemHasRenderedHTMLSafe = NO;
            BOOL oneItemHasRenderedHTMLUnescaped = NO;
            
            for (id item in self) {
                @autoreleasepool {
                    // Render item
                    
                    id<GRMustacheRendering> itemRenderingObject = [GRMustacheRendering renderingObjectForObject:item];
                    BOOL itemHasRenderedHTMLSafe = NO;
                    NSError *renderingError = nil;
                    NSString *rendering = [itemRenderingObject renderForMustacheTag:tag context:context HTMLSafe:&itemHasRenderedHTMLSafe error:&renderingError];
                    
                    if (rendering == nil && renderingError == nil)
                    {
                        // Rendering is nil, but rendering error is not set.
                        //
                        // Assume a rendering object coded by a lazy programmer, whose
                        // intention is to render nothing.
                        
                        rendering = @"";
                    }
                    
                    if (!rendering) {
                        // make sure error is not released by autoreleasepool
                        if (error != NULL) [*error retain];
                        success = NO;
                        break;
                    }
                    
                    if (rendering.length > 0) {
                        // check consistency of HTML escaping before appending the rendering to the buffer
                        
                        if (itemHasRenderedHTMLSafe) {
                            oneItemHasRenderedHTMLSafe = YES;
                            if (oneItemHasRenderedHTMLUnescaped) {
                                [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                            }
                        } else {
                            oneItemHasRenderedHTMLUnescaped = YES;
                            if (oneItemHasRenderedHTMLSafe) {
                                [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                            }
                        }
                        
                        GRMustacheBufferAppendString(&buffer, rendering);
                    }
                }
            }
            
            if (!success) {
                if (error != NULL) [*error autorelease];
                GRMustacheBufferRelease(&buffer);
                return nil;
            }
            if (HTMLSafe != NULL) {
                *HTMLSafe = !oneItemHasRenderedHTMLUnescaped;   // oneItemHasRenderedHTMLUnescaped is initialized to NO: we assume safest (YES) if list is empty.
            }
            return GRMustacheBufferGetStringAndRelease(&buffer);
        }
            
        case GRMustacheTagTypeSection: {
            // {{# list }}...{{/}}
            // Non inverted sections render for each item in the list
            
            BOOL success = YES;
            BOOL bufferCreated = NO;
            GRMustacheBuffer buffer;
            for (id item in self) {
                if (!bufferCreated) {
                    buffer = GRMustacheBufferCreate(1024);
                    bufferCreated = YES;
                }
                // Each item enters a new context
                @autoreleasepool {
                    GRMustacheContext *itemContext = [context newContextByAddingObject:item];
                    NSString *rendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
                    [itemContext release];
                    
                    if (!rendering) {
                        // make sure error is not released by autoreleasepool
                        if (error != NULL) [*error retain];
                        success = NO;
                        break;
                    }
                    
                    GRMustacheBufferAppendString(&buffer, rendering);
                }
            }
            if (!success) {
                if (error != NULL) [*error autorelease];
                GRMustacheBufferRelease(&buffer);   // buffer exists, because we have an error, and errors come from items.
                return nil;
            } else if (bufferCreated) {
                return GRMustacheBufferGetStringAndRelease(&buffer);
            } else {
                if (HTMLSafe != NULL) {
                    *HTMLSafe = YES;   // assume safest (YES) if list is empty.
                }
                return @"";
            }
        }
            
        case GRMustacheTagTypeInvertedSection: {
            // {{^ list }}...{{/}}
            // Inverted section render if and only if self is empty.
            
            BOOL empty = YES;
            for (id _ __attribute__((unused)) in self) {
                empty = NO;
                break;
            }
            
            if (empty) {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                return @"";
            }
        }
    }
}
