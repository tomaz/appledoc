/*
 * Copyright (c) 2007-2008 Dave Dribin
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
#import "DDCliApplication.h"
#import "DDGetoptLongParser.h"
#import "DDCliUtil.h"
#import "DDCliParseException.h"

DDCliApplication * DDCliApp = nil;

@implementation DDCliApplication

+ (DDCliApplication *) sharedApplication;
{
    if (DDCliApp == nil)
        DDCliApp = [[DDCliApplication alloc] init];
    return DDCliApp;
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    mName = [[processInfo processName] retain];
    
    return self;
}

- (NSString *) name;
{
    return mName;
}

- (int) runWithClass: (Class) delegateClass;
{
    NSObject<DDCliApplicationDelegate> * delegate = nil;
    int result = EXIT_SUCCESS;
    @try
    {
        delegate = [[delegateClass alloc] init];

        DDGetoptLongParser * optionsParser =
            [DDGetoptLongParser optionsWithTarget: delegate];
        [delegate application: self willParseOptions: optionsParser];
        NSArray * arguments = [optionsParser parseOptions];
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
    @finally
    {
        if (delegate != nil)
        {
            [delegate release];
            delegate = nil;
        }
    }
    
    return result;
}

- (NSString *) description;
{
    return [self name];
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
