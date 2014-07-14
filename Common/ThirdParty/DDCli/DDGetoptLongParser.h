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
#import <getopt.h>
#import <libgen.h>

extern int
dd_getopt_long(int nargc, char * const *nargv, const char *options,
			   const struct option *long_options, int *idx);
extern int
dd_getopt_long_only(int nargc, char * const *nargv, const char *options,
					const struct option *long_options, int *idx);

/* Function pointer to getopt_long() or getopt_long_only() */
typedef int (*DDGetoptFunction)(int, char * const *, const char *,
                                const struct option *, int *);

/**
 * Argument options.
 * @ingroup constants
 */
typedef enum DDGetoptArgumentOptions
{
    /** Option takes no argument */
    DDGetoptNoArgument = no_argument,
    /** Option takes an optional argument */
    DDGetoptOptionalArgument = optional_argument,
    /** Option takes a mandatory argument */
    DDGetoptRequiredArgument = required_argument,
	/** Option can be explicitly negated with --no-argname */
	DDGetoptNoArgumentNegatable = 4,
} DDGetoptArgumentOptions;

/**
 * Structure to use for option tables.
 */
typedef struct
{
    /**
     * The long option without the double dash ("--").  This is required.
     */
    char * longOption;
    /** A single character for the short option.  Maybe be null or 0. */
    int shortOption;
    /** Argument options for this option. */
    DDGetoptArgumentOptions argumentOptions;
} DDGetoptOption;

/**
 * A command line option parser implemented using <a
 * href="http://developer.apple.com/documentation/Darwin/Reference/ManPages/man3/getopt_long.3.html">getopt_long(3)</a>.
 * In order to simplify usage, this class drives the option parsing by
 * running the while loop.  When an option is found, <a
 * href="http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/index.html">Key-Value
 * Coding</a> (KVC) is used to set a key on the target class.  Unless
 * overridden, the key to use is the same as the long option.  The
 * long option is converted to camel case, if needed.  For example the
 * option "long-option" has a default key of "longOption".
 *
 * @sa DDGetoptOption
 */
@interface DDGetoptLongParser : NSObject
{
    @private
    id _target;
    int _nextShortOption;
    NSMutableString * _optionString;
    NSMutableDictionary * _optionInfoMap;
    NSMutableData * _optionsData;
    int _currentOption;
    NSMutableArray * _utf8Data;
    DDGetoptFunction _getoptFunction;
}

/**
 * Create an autoreleased option parser with the given target.
 *
 * @param target Object that receives target messages.
 */
+ (DDGetoptLongParser *)optionsWithTarget:(id)target;

/**
 * Create an option parser with the given target.
 *
 * @param target Object that receives target messages.
 */
- (id)initWithTarget:(id)target;

/**
 * Returns the target object.
 *
 * @return The target object
 */
- (id)target;

/**
 * Sets the target object.
 *
 * @param target The target object
 */
- (void)setTarget:(id)target;

/**
 * If set to YES, parses options with getopt_long_only() instead of
 * getopt_long().
 *
 * @param getoptLongOnly YES means parse with getopt_long_only()
 */
- (void)setGetoptLongOnly:(BOOL)getoptLongOnly;

/**
 * Add all options from a null terminated option table.  The final
 * entry in the table should contain a nil long option and a null
 * short option.
 *
 * @param optionTable An array of DDGetoptOption.
 */
- (void)addOptionsFromTable:(DDGetoptOption *)optionTable;

/**
 * Add an option with both long and short options.  The long option
 * should not contain the double dash ("--").  If you do not want a
 * short option, set it to the zero or the null character.
 *
 * @param longOption The long option
 * @param shortOption The short option
 * @param key The key use when the option is parsed
 * @param argumentOptions Options for this options argument
 */
- (void)addLongOption:(NSString *)longOption
          shortOption:(char)shortOption
                  key:(NSString *)key
      argumentOptions:(DDGetoptArgumentOptions)argumentOptions;

/**
 * Add an option with no short option.
 *
 * @param longOption The long option
 * @param key The key use when the option is parsed
 * @param argumentOptions Options for this options argument
 */
- (void)addLongOption:(NSString *)longOption
                  key:(NSString *)key
      argumentOptions:(DDGetoptArgumentOptions)argumentOptions;

/**
 * Parse the options using the arguments and command name from
 * NSProcessInfo.
 *
 * @return Arguments left over after option parsing or <code>nil</code>
 */
- (NSArray *)parseOptions;

/**
 * Parse the options on an array of arguments.
 *
 * @param arguments Array of command line arguments
 * @param command Command name to use for error messages.
 * @return Arguments left over after option processing or <code>nil</code>
 */
- (NSArray *)parseOptionsWithArguments:(NSArray *)arguments
                               command:(NSString *)command;

@end

/**
 * DDGetoptLong delegate methods.
 */
@interface NSObject (DDGetoptLong)

/**
 * Called if an option that is not recognized is found.  If this is
 * not implemented, then a default error message is printed.  For long
 * options, the option includes the two dashes. For short options, the
 * option is just a single character.
 *
 * @param option The option that was not recognized.
 */
- (void)optionIsNotRecognized:(NSString *)option;

/**
 * Called if an argument was not supplied for option that is required
 * to have an argument.  If this is not implemented then a defeault
 * error message is printed.  For long options, the option includes
 * the two dashes. For short options, the option is just a single
 * character.
 *
 * @param option The option that had the missiong argument.
 */
- (void)optionIsMissingArgument:(NSString *)option;

+ (NSString *)optionToKey:(NSString *)option;

@end
