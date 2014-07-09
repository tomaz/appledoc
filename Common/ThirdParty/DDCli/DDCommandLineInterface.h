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
#import <sysexits.h>

#import "DDGetoptLongParser.h"
#import "DDCliApplication.h"
#import "DDCliUtil.h"
#import "DDCliParseException.h"


/**
 * @mainpage ddcli: An Objective-C Command Line Helper
 *
 * <a href="http://www.dribin.org/dave/software/#ddcli">ddcli</a> is an
 * Objective-C library to help write command line
 * applications by simplifying parsing command line options and
 * eliminating much of the boiler plate code.  The <a
 * href="http://developer.apple.com/documentation/Darwin/Reference/ManPages/man3/getopt_long.3.html">getopt_long(3)</a>
 * function is used to parse command options, but the complexity of
 * using this function is hidden by an Objective-C wrapper
 * (DDGetoptLongParser).  <a
 * href="http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/index.html">Key-Value
 * Coding</a> (KVC) is used to set the options on a target class.  A
 * simple example should help make this clear.
 *
 * The main class is DDCliApplication.  You customize its behavior by
 * creating a class that implements the DDCliApplicationDelegate
 * protocol.  This protocol has two methods that must be implemented:
 *
 * @include appDelegate.m
 *
 * The first method allows the delegate to add options to the parser.
 * The second method is the main entry point for the command line
 * application.  The simplest way to add options is to use the
 * DDGetoptLongParser.addOptionsFromTable: method:
 *
 * @include willParseOptions.m
 *
 * As options are parsed your delegate is also used as the target of
 * KVC modifiers.  The long option is used as the key to the
 * setValue:forKey: call.  The value is a boolean YES for options that
 * take no arguments or a string for options that do.  The simplest
 * way to handle this is to use instance variables with the same name
 * as the long options:
 *
 * @include SimpleApp.h
 *
 * After options are parsed, the entry point is called, assuming there
 * were no invalid options.  This implementation just prints the
 * arguments, and exits:
 *
 * @include runWithArguments.m
 * 
 * This code also uses #ddprintf which works just like printf, except
 * you can use the %@ format string.  The final part that needs
 * implementing is the main function.  The #DDCliAppRunWithDefaultClass
 * function makes this a one liner:
 *
 * @include ddcli_main.m
 *
 * Here are a few sample runs of this program:
 *
 * @verbatim
% simple
Output: (null), help: 0
Arguments: ()
@endverbatim
@verbatim
% simple -o output.txt the quick "brown fox"
Output: output.txt, help: 0
Arguments: (the, quick, "brown fox")
@endverbatim
@verbatim
% simple -h
Output: (null), help: 1
Arguments: ()
@endverbatim
 *
 * The full source for this simple application can be found on @link
 * SimpleApp.m @endlink example.
 *
 * Since KVC is used, you can implement a set<option>: method to
 * customize the behavior when options are parsed.  For example, you
 * could use this to store all occurences of an option in an array.
 * See @link ExampleApp.m @endlink for a more complex example that uses
 * this technique.
 *
 * @defgroup functions Functions and Global Variables
 * @defgroup constants Constants
 */
