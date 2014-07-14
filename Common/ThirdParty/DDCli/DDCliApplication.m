/*
 * Copyright (c) 2007-2013 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <sysexits.h>
#import <objc/runtime.h>
#import "DDCliApplication.h"
#import "DDGetoptLongParser.h"
#import "DDCliUtil.h"
#import "DDCliParseException.h"

DDCliApplication * DDCliApp = nil;

@interface DDCliApplication ()

- (Class)findFirstDelegateClass;

@end

@implementation DDCliApplication

+ (DDCliApplication *)sharedApplication;
{
    if (DDCliApp == nil)
        DDCliApp = [[DDCliApplication alloc] init];
    return DDCliApp;
}

- (id)init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    _name = [[processInfo processName] retain];
    
    return self;
}

- (void)dealloc
{
    [_name release];
    
    [super dealloc];
}

- (NSString *)name;
{
    return _name;
}

- (NSString *)description;
{
    return [self name];
}

- (int)runWithDelegate:(id<DDCliApplicationDelegate>)delegate
             arguments:(NSArray *)arguments
{
    int result = EXIT_SUCCESS;
    @try
    {
        DDGetoptLongParser * optionsParser =
            [DDGetoptLongParser optionsWithTarget: delegate];
        [delegate application: self willParseOptions: optionsParser];
		if ( arguments == nil )
		{
			arguments = [optionsParser parseOptions];
		}
		else
		{
			arguments = [optionsParser parseOptionsWithArguments:arguments command:[[NSProcessInfo processInfo] processName]];
		}
        if (arguments == nil)
        {
            return EX_USAGE;
        }

        result = [delegate application: self
                      runWithArguments: arguments];
    }
    @catch (DDCliParseException * e)
    {
        ddfprintf(stderr, @"%@: %@\n", self, [e reason]);
        result = [e exitCode];
    }
    @catch (NSException * e)
    {
        ddfprintf(stderr, @"Caught: %@: %@\n", [e name], [e description]);
        result = EXIT_FAILURE;
    }
    
    return result;
}

- (int)runWithClass:(Class)delegateClass
{
    id<DDCliApplicationDelegate> delegateInstance = nil;
    @try {
        if (delegateClass == nil)
            delegateClass = [self findFirstDelegateClass];
        if (delegateClass == nil)
        {
            ddfprintf(stderr, @"%@: delegate class not found\n", self);
            return EX_CONFIG;
        }
        
        delegateInstance = [[delegateClass alloc] init];
        return [self runWithDelegate:delegateInstance arguments:nil];
    }
    @finally {
        [delegateInstance release];
    }
    
}

- (Class)findFirstDelegateClass;
{
    Protocol * delegateProtocol = @protocol(DDCliApplicationDelegate);
    Class delegateClass = nil;
    
    Class * classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = (Class*)alloca(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
    }
    int i;
    for (i = 0; i < numClasses; i++)
    {
        if (class_conformsToProtocol(classes[i], delegateProtocol))
        {
            delegateClass = classes[i];
            break;
        }
    }
    
    return delegateClass;
}

@end

int DDCliAppRunWithClass(Class delegateClass)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // Initialize singleton/global
    DDCliApplication * app = [DDCliApplication sharedApplication];
    int result = [app runWithClass: delegateClass];

    [pool drain];
    
    return result;
}

int DDCliAppRunWithDefaultClass()
{
    return DDCliAppRunWithClass(nil);
}
