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

#import "DDGetoptLongParser.h"
#import "DDCliUtil.h"

extern int
dd_getopt_long(int nargc, char * const *nargv, const char *options,
			   const struct option *long_options, int *idx);
extern int
dd_getopt_long_only(int nargc, char * const *nargv, const char *options,
					const struct option *long_options, int *idx);


@interface DDGetoptLongParser ()

- (struct option *)firstOption;
- (struct option *)currentOption;
- (void)addOption;
- (NSString *)errorOption:(NSString *)option;
- (void)handleMissingArgument:(NSString *)option
                      command:(NSString *)command;
- (void)handleArgumentNotRecognized:(NSString *)option
                            command:(NSString *)command;

@end

@implementation DDGetoptLongParser

+ (DDGetoptLongParser *)optionsWithTarget:(id)target;
{
    return [[[self alloc] initWithTarget: target] autorelease];
}

- (id)initWithTarget:(id)target;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _target = target;
    // Non-single char options start after as the last ASCII character
    _nextShortOption = 256;
    _optionsData = [[NSMutableData alloc] initWithLength: sizeof(struct option)];
    _currentOption = 0;
    _utf8Data = [[NSMutableArray alloc] init];
    _optionString = [[NSMutableString alloc] init];
    [_optionString appendString: @":"];
    _optionInfoMap = [[NSMutableDictionary alloc] init];
    _getoptFunction = dd_getopt_long;
    
    return self;
}

- (void)dealloc
{
    [_optionInfoMap release];
    [_optionString release];
    [_optionsData release];
    [_utf8Data release];
    
    [super dealloc];
}

- (id)target;
{
    return _target;
}

- (void)setTarget:(id)target;
{
    _target = target;
}


- (void)setGetoptLongOnly:(BOOL)getoptLongOnly;
{
    if (getoptLongOnly)
        _getoptFunction = dd_getopt_long_only;
    else
        _getoptFunction = dd_getopt_long;
}

- (void)addOptionsFromTable:(DDGetoptOption *)optionTable;
{
    DDGetoptOption * currentOption = optionTable;
    while ((currentOption->longOption != nil) ||
           (currentOption->shortOption != 0))
    {
        [self addLongOption: [NSString stringWithUTF8String:currentOption->longOption]
                shortOption: currentOption->shortOption
                        key: [self optionToKey: [NSString stringWithUTF8String:currentOption->longOption] ]
            argumentOptions: currentOption->argumentOptions];
        currentOption++;
    }
}

- (void)addLongOption:(NSString *)longOption
          shortOption:(char)shortOption
                  key:(NSString *)key
      argumentOptions:(DDGetoptArgumentOptions)argumentOptions;
{
	if ( argumentOptions == DDGetoptNoArgumentNegatable )
	{
		[self addLongOption:longOption shortOption:shortOption key:key argumentOptions:DDGetoptNoArgument];
		NSString* noKey = [NSString stringWithFormat:@"no-%@",longOption];
		[self addLongOption:noKey shortOption:shortOption key:noKey argumentOptions:DDGetoptNoArgument];
		return;
	}
    const char * utf8String = [longOption UTF8String];
    NSData * utf8Data = [NSData dataWithBytes: utf8String length: strlen(utf8String)];
    
    struct option * option = [self currentOption];
    option->name = utf8String;
    option->has_arg = argumentOptions;
    option->flag = NULL;

    int shortOptionValue;
    if (shortOption != 0)
    {
        shortOptionValue = shortOption;
        option->val = shortOption;
        if (argumentOptions == DDGetoptRequiredArgument)
            [_optionString appendFormat: @"%c:", shortOption];
        else if (argumentOptions == DDGetoptOptionalArgument)
            [_optionString appendFormat: @"%c::", shortOption];
        else
            [_optionString appendFormat: @"%c", shortOption];
    }
    else
    {
        shortOptionValue = _nextShortOption;
        _nextShortOption++;
        option->val = shortOptionValue;
    }
    [self addOption];
    
    NSArray * optionInfo = [NSArray arrayWithObjects:
        key, [NSNumber numberWithInt: argumentOptions], nil];
    [_optionInfoMap setObject: optionInfo
                       forKey: [NSNumber numberWithInt: shortOptionValue]];
    
    [_utf8Data addObject: utf8Data];
}

- (void)addLongOption:(NSString *)longOption
                  key:(NSString *)key
      argumentOptions:(DDGetoptArgumentOptions)argumentOptions;
{
    [self addLongOption: longOption shortOption: 0
                    key: key argumentOptions: argumentOptions];
}

- (NSArray *)parseOptions;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSArray * arguments = [processInfo arguments];
    NSString * command = [processInfo processName];
    return [self parseOptionsWithArguments: arguments command: command];
}

- (NSArray *)parseOptionsWithArguments:(NSArray *)arguments
                               command:(NSString *)command;
{
    NSUInteger argc = [arguments count];
    char ** argv = alloca(sizeof(char *) * ( argc + 1 ) );
    NSUInteger i;
    for (i = 0; i < argc; i++)
    {
        NSString * argument = [arguments objectAtIndex: i];
        argv[i] = (char *) [argument UTF8String];
    }
    argv[i] = 0;
    
    // Make sure list is NULL terminated
    struct option * option = [self currentOption];
    option->name = NULL;
    option->has_arg = 0;
    option->flag = NULL;
    option->val = 0;
    
    const char * optionString = [_optionString UTF8String];
    struct option * options = [self firstOption];
    int ch;
    opterr = 1;
    
    int longOptionIndex = -1;
	/* reset the options parser because it is too stupid to be reset with just optreset */
	optreset = 1;
	opterr = 1;
	optind = 1;
    while ((ch = _getoptFunction(argc, argv, optionString, options, &longOptionIndex)) != -1)
    {
        NSString * last_argv = [NSString stringWithUTF8String: argv[optind-1]];
        if (ch == ':')
        {
            [self handleMissingArgument: last_argv command: command];
            return nil;
        }
        else if (ch == '?')
        {
            [self handleArgumentNotRecognized: last_argv command: command];
            return nil;
        }
        
        NSString * nsoptarg = nil;
        if (optarg != NULL)
            nsoptarg = [NSString stringWithUTF8String: optarg];
        
        NSArray * optionInfo = [_optionInfoMap objectForKey: [NSNumber numberWithInt: ch]];
        NSAssert(optionInfo != nil, @"optionInfo should not be nil");

        if (optionInfo != nil)
        {
            NSString * key = [optionInfo objectAtIndex: 0];
            int argumentOptions = [[optionInfo objectAtIndex: 1] intValue];
            if (argumentOptions == DDGetoptNoArgument) {
				BOOL boolValue = YES;
				if ([key hasPrefix:@"no-"]) {
					boolValue = NO;
					key = [key substringFromIndex:3];
				}
                [_target setValue: [NSNumber numberWithBool: boolValue] forKey: key];
			}
            else
                [_target setValue: nsoptarg forKey: key];
        }
    }
    
	if ( ( argc - optind ) >= 1 )
	{
		NSRange range = NSMakeRange(optind, argc - optind);
		return [arguments subarrayWithRange: range];
	}
	else
	{
		return [NSArray array];
	}
}

- (NSString *)optionToKey:(NSString *)option
{
    return [DDGetoptLongParser optionToKey:option];
}

+ (NSString *)optionToKey:(NSString *)option;
{
    NSScanner * scanner = [NSScanner scannerWithString: option];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString: @"-"]];
    NSMutableString * key = [NSMutableString string];
    NSString * string = nil;
    BOOL caps = NO;
    while ([scanner scanUpToString: @"-" intoString: &string])
    {
        if (caps)
            string = [string capitalizedString];
        [key appendString: string];
        caps = YES;
    }
    return key;
}

- (struct option *)firstOption;
{
    struct option * options = [_optionsData mutableBytes];
    return options;
}

- (struct option *)currentOption;
{
    struct option * options = [_optionsData mutableBytes];
    return &options[_currentOption];
}

- (void)addOption;
{
    [_optionsData increaseLengthBy: sizeof(struct option)];
    _currentOption++;
}

- (NSString *)errorOption:(NSString *)option;
{
    if (![option hasPrefix: @"-"])
        return [NSString stringWithFormat: @"%c", optopt];
    else
        return option;
}

- (void)handleMissingArgument:(NSString *)option
                      command:(NSString *)command;
{
    option = [self errorOption: option];
    
    if ([_target respondsToSelector: @selector(optionIsMissingArgument:)])
    {
        [_target optionIsMissingArgument: option];
    }
    else
    {
        ddfprintf(stderr, @"%@: option `%@' requires an argument\n",
                  command, option);
        ddfprintf(stderr, @"Try `%@ --help` for more information.\n", command);
    }
}

- (void)handleArgumentNotRecognized:(NSString *)option
                            command:(NSString *)command;
{
    option = [self errorOption: option];
    if ([_target respondsToSelector: @selector(optionIsNotRecognized:)])
    {
        [_target optionIsNotRecognized: option];
    }
    else
    {
        ddfprintf(stderr, @"%@: unrecognized option `%@'\n",
                  command, option);
        ddfprintf(stderr, @"Try `%@ --help` for more information.\n", command);
    }
}

@end

