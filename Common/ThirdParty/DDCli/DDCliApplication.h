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

#import <Foundation/Foundation.h>

@class DDCliApplication;
@class DDGetoptLongParser;

/**
 * Methods that the DDCliApplication delegate must implement.
 */
@protocol DDCliApplicationDelegate <NSObject>

/**
 * This is the main entry point of a command line application.  It is
 * called after options have been parsed, and the arguments passed in
 * have the options removed.
 *
 * @param app The corresponding application instance
 * @param arguments Command line arguments, post option parsing
 * @return The return value of the application
 */
- (int)application:(DDCliApplication *)app
  runWithArguments:(NSArray *)arguments;

/**
 * Called prior to option parsing so that options may added to the
 * options parser.
 *
 * @param app The corresponding application instance
 * @param optionParser The option parser.
 */
- (void)application:(DDCliApplication *)app
   willParseOptions:(DDGetoptLongParser *)optionParser;

@end

/**
 * A class that represents a command line application.
 */
@interface DDCliApplication : NSObject
{
    @private
    NSString * _name;
}

/**
 * Returns the common shared application.
 *
 * @return The common shared application
 */
+ (DDCliApplication *)sharedApplication;

/**
 * Returns the name of this application.
 *
 * @return The name of this application
 */
- (NSString *)name;

/**
 * Returns the name of this application.  Coupled with the
 * #DDCliApp global, this makes it easy to print standard Unix-style
 * error messages:
 *
 * @code
 ddfprintf(stderr, "%@: An error occured", DDCliApp);
 * @endcode
 *
 * @return The application name
 */
- (NSString *)description;

/**
 * Runs a command line application with the specified delegate class,
 * and returns the result.  This instantiates an instance of the
 * delegate class, and releases it up completion.  Exceptions are
 * trapped, and an error message is printed.
 *
 * @param delegateClass The class of the delegate or <code>nil</code>
 *   to search all classes for the delegate.
 * @return Result to be returned by <code>main</code>.
 */
- (int)runWithClass:(Class)delegateClass;

/**
 * Runs a command line application with the specified delegate and
 * arguments, and returns the result.  Exceptions are trapped, and an
 * error message is printed.
 *
 * @param delegate The delegate.
 * @param arguments Array of arguments.
 * @return Result to be returned by <code>main</code>.
 */
- (int)runWithDelegate:(id<DDCliApplicationDelegate>)delegate
             arguments:(NSArray *)arguments;

@end

/**
 * @ingroup functions
 * @{
 */

/** The shared application. */
extern DDCliApplication * DDCliApp;

/**
 * Runs a command line application with the given delegate class.
 * This sets up an autorelease pool, and creates an instance of the
 * delegate class.
 *
 * @param delegateClass Class to instantiate for the delegate or
 *   <code>nil</code> to specify the default delegate class.
 */
int DDCliAppRunWithClass(Class delegateClass);

/**
 * Runs a command line application with the default delegate class.  To find
 * the default delegate class, all classes are searched until one is found
 * that implements the DDCliApplicationDelegate protocol.  The first matching
 * class is used as the delegate class, so be sure to only include a single
 * class that implements this protocol per application.
 */
int DDCliAppRunWithDefaultClass();

/** @} */

/**
 * @example SimpleApp.m
 *
 * This is a very simple example application.
 *
 * @include ddcli_main.m
 * @include SimpleApp.h
 */

/**
 * @example ExampleApp.m
 *
 * This is a slighly more complex example application.  Here are a
 * few sample runs of this program:
 *
 * @verbatim
% example                           
example: At least one argument is required
example: Usage [OPTIONS] <argument> [...]
Try `example --help' for more information.
@endverbatim
@verbatim
% example --help         
example: Usage [OPTIONS] <argument> [...]

  -f, --foo FOO                 Use foo with FOO
  -I, --include FILE            Include FILE
  -b, --bar[=BAR]               Use bar with BAR
      --long-opt                Enable long option
  -v, --verbose                 Increase verbosity
      --version                 Display version and exit
  -h, --help                    Display this help and exit

A test application for DDCommandLineInterface.
@endverbatim
@verbatim
% example --foo bar --long-opt one.c
foo: bar, bar: (null), longOpt: 1, verbosity: 0
Include directories: ()
Arguments: ("one.c")
@endverbatim
@verbatim
% example -vvv -I/usr/include -I/usr/local/include one.c two.c
foo: (null), bar: (null), longOpt: (null), verbosity: 3
Include directories: ("/usr/include", "/usr/local/include")
Arguments: ("one.c", "two.c")
@endverbatim
 *
 * Here is the source code:
 *
 * @include ddcli_main.m
 * @include ExampleApp.h
 */
