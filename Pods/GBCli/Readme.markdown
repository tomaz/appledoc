GBCli
-----

GBCli is command line interface helper library. It provides classes for simplifying command line Objective C foundation tools code. The library is designed to be as flexible as possible to suit wide range of tools. It requires no external dependency besides *Foundation.framework*. The library was inspired by [DDCli](http://www.dribin.org/dave/software/#ddcli) by Dave Dribin.

Here's how it happened (skip this part if you're only interested in techincal stuff :) - When I started work on redesigning [appledoc](http://gentlebytes.com/appledoc), one of the first files I included was DDCli library. However I soon discovered it doesn't work well with arc. That, coupled with different workflow I wanted, prompted me to digg in Dave's code to see how I could change it to suit my needs better. To cut long story short - at the end I ended writing the whole library from scratch and now parsing is implemented manually, without relying on `getopt_long`. As I was adding more functionality, I realized, I could make it as reusable component and publish it on GitHub...

This file serves as tutorial demonstrating what you can do with the library.


Parsing command line arguments
-----------------------------
The most basic building block of the library is parsing command line arguments. This is implemented with *GBCommandLineParser* class. Using it is similar to how DDCli was used: register all options and have it parse command line. Based on registered data, the class determines whether command line is valid or not. But that alone wouldn't be that usefult, so the class also offers interface for getting the actual options and argument values. You can use callback API to be notified about each option. This is similar to how DDCli was implemented, except a block API is used instead of KVO. This results in more streamlined code IMHO.

Besided callback API, parser also stores all encountered option and arguments internally, so you can access them after parsing is complete. This can solve the problem with storing values, although it only provides KVC style interface which may result in verbose code.

The code looks like this:

```
int main(int argc, char **argv) {
	// Create parser and register all options.
	GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
	[parser registerOption:@"optiona" shortcut:'a' requirement:GBValueRequired];
	[parser registerOption:@"optionb" shortcut:'b' requirement:GBValueOptional];
	[parser registerOption:@"optionc" shortcut:'c' requirement:GBValueNone];
	
	// Parse command line
	[parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
		switch (flags) {
			case GBParseFlagUnknownOption:
				printf("Unknown command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagMissingValue:
				printf("Missing value for command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagArgument:
				// do something with argument 'value'
				break;
			case GBParseFlagOption:
				// do something with 'option' and its 'value'
				break;
		}
	}];
	...			
	// You can also access options and arguments after parsing is complete.
	id valuea = [parser valueForOption:@"optiona"];
	NSArray *arguments = parser.arguments;
	...
}
```

In above example, we've registered 3 options:

- `--optiona` with shortcut `-a` with a required value.
- `--optionb` with shortcut `-b` with optional value.
- `--optionc` with shortcut `-c` and no value.

You can also register only long option, withouth short variant - just pass `0` for the short option argument. As you can see you can specify each option's vaue as required, optional or no value. Here's how it works:

- Required values: the option must be followed by a value like this: `--optiona value`, `-a value` or alternatively `--optiona=value` or `-a=value`. If value is missing, parser will report missing value via *GBParseFlagMissingValue* flag.
- Optional values: the value is options, so all of these are valid: `--optionb value`, `-b value`, `--optionb=value`, `-b=value`. In these cases, the given value is reported as a *NSString*. Additionally, you can also omit the value alltogether: `--optionb` or `-b`. In this case, *NSNumber* setup as `[NSNumber numberWithBool:YES]` is reported to block.
- No value: the option is a "command line boolean switch". If the option is found on command line, for example `--optionc` or `-c-, `[NSNumber numberWithBool:YES]` is assumed and the option is "enabled". These options can also use negated syntax in the form `--no-<option name>`, like `--no-optionc` - in this case `[NSNumber numberWithBool:NO]` is assumed and the option is "disabled". This is especially useful when you have an option enabled by default (i.e. in factory settings), and you want to override the value on command line.

**Note:**  Note that you can alternatively use *option=value* syntax, for example: `--optiona="My value"` or `-a=50`. Note that there must be no whitespace between the option name, equal sign and the value!

**Note:** You can also use *option=value* syntax with no-value options, so for example instead of `--no-optionc`, you can alternatively use `--optionc=0` or `-c=0` to disable it. Likewise, you can use `--optionc=1` to enable it (although `--optionc` would do the same). You can even get creative, so `--no-optionc=0`, `--no-optionc=1` are also valid, and, as you might expect, they result in enabled and disabled option respectively (although going this "fancy" will probably make your life miserable :) But note, that you can't use space delimited option/value syntax (for example: `--optionc 0`) with no-value options!

**Note:** You can also use `registerSwitch:shortcut:` or `registerSwitch:` methods to register no value option. You might prefer this interface as it'll make the option usage more explicit. It's effectively the same as using normal registration methods and `GBValueNone` requirement.


Application wide settings handling
----------------------------------

In most cases, you'd like to store values from command line into a simple to use interface that you can then pass on to various components of your tool. GBCli provides *GBSettings* class for that purpose. In its basic form, it provides *NSUserDefaults* like interface to the settings through methods like `objectForKey:` and `setObject:forKey:` and scalar variants like `boolForKey:` and `setBool:forKey:` and similar.

But it doesn't stop there - in most cases, you'd like to have several levels of settings: for example factory defaults and command line. In more complex tools, there might be additional levels in between: for example appledoc can also read settings from global or project files. And options should take precedense, so for example value provided in command line overrides factory defaults. *GBSettings* make this very simple - here's how you could extent previous example:

```
int main(int argc, char **argv) {
	// Create settings stack.
	GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
	[factoryDefaults setInteger:50 forKey:@"optiona"];
	[factoryDefaults setInteger:12 forKey:@"optionb"];
	GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
	
	// Create parser and register all options.
	GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
	[parser registerOption:@"optiona" shortcut:'a' requirement:GBValueRequired];
	[parser registerOption:@"optionb" shortcut:'b' requirement:GBValueOptional];
	[parser registerOption:@"optionc" shortcut:0 requirement:GBValueNone];
	
	// Parse command line
	[parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
		switch (flags) {
			case GBParseFlagUnknownOption:
				printf("Unknown command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagMissingValue:
				printf("Missing value for command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagArgument:
				[settings addArgument:value];
				break;
			case GBParseFlagOption:
				[settings setObject:value forKey:option];
				break;
		}
	}];
	
	// From here on, just use settings...
	NSInteger a = [settings integerForKey:@"optiona"];
	NSInteger b = [settings integerForKey:@"optionb"];
	...
}
```

In this example, we've setup factory defaults / cmd line hierarchy. For any option, if it was provided by command line, that would be used, but if not, it would accessors would automatically revert to "parent" (i.e. previous level) settings until eventually a value would be found - that value would be returned as the result. So if our command line was `mytool --optiona 20`, the value of  *a* above would be *20*, taking precedence from *50*, defined in factory defaults. However the value of *b* would be *12* - as the value wasn't provided on command line, factory default would be used. If the value isn't provided anywhere in the hierarchy, `nil` (or `0` for scalars) is returned.

**Note:** We've simplified the code by using the same keys in command line parser and settings. Although you're not required to do so, it's highly recommended to avoid confusion. Additionally, you'll most likely benefit by declaring all the keys as constants to avoid mistypes.

**Note:** In case you're wondering - you don't have to use settings hierarcy if you don't need it! Above example would work just as same using a single *GBSettings* object. Just make sure you apply the settings in the correct order and new values will override existing ones as expected. The main reason for designing levels is to be able to print values on a per-level basis, similar to how Xcode build settings view does. But I'm ahead of myself, read more of this later on. Here’s above example simplified just for completeness sake:

```
int main(int argc, char **argv) {
	// Create settings.
	GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
	[settings setInteger:50 forKey:@"optiona"];
	[settings setInteger:12 forKey:@"optionb"];
	
	... the rest is the same as before...
}
```


### Accumulating repeated options into arrays

Sometimes, you'd like to allow the user repeat an option several times and you'd like to receive all values. For example, let's assume you want to be able to duplicate output to several locations. One way would be to have `--outputs` option that would take a list of locations delimited with some predefined char such as `;` - like `--outputs ~/Dir1;~/Dir2`. That's certainly possible, but would require some post processing from your part. `GBSettings` include "thread key as array" feature that allows you implement this through key repetition. This would change the command line interface to something like `--output ~/Dir1 --output ~/Dir2` (or with alterative syntax `--output=~/Dir1 --output=~/Dir2`).

`GBSettings` can automate this for you - all you need to do is to register an option as an array like this:

	[factorySettings registerArrayForKey:@"output"]
	[settings registerArrayForKey:@"output"]

In this case, `[settings objectForKey:@"output"]` will return an `NSArray` containing all values. If there was no value, `nil` would be returned, if there was single value, an array with single item would be returned. Furthermore - the resulting array would contain all values, accumulated through the whole settings stack - including all parents!

**Note:** Note that you must register the option as array to each level separately! If this seems like lot's of repeating work, read on :)


### Application specific settings interface

While using *GBSettings* out of the box via KVC interface may be sufficient for basic tools, in most cases, you'd benefit by embedding KVC into a nice `@property` based interface customized to specific application.

#### Custom properties

One way would be overriding `GBSettings` class, but Objective C provides (IMHO) better solution for that - categories. Here's how it may look one for above example:

```
@interface GBSettings (MyAppSettings)
@property (nonatomic, assign) NSInteger optiona;
@property (nonatomic, assign) NSInteger optionb;
@property (nonatomic, assign) BOOL optionc;
@end
```

Now we need to somehow "map" properties with specific keys. Let's see how it would look like:

```
@implementation GBSettings (MyAppSettings)

- (NSInteger)optiona {
	return [self integerForKey:@"optiona"];
}

- (void)setOptiona:(NSInteger)value {
	[self setInteger:value forKey:@"optiona"];
}

... repeat same for optionb and optionc

@end
```

Straightforward, but kind of verbose and tedious, especially with more complex tools. But there's another way - at the end of *GBSettings.h* file, there are a bunch of convenience macros that allow you synthesize your properties via a single line like this:

```
@implementation GBSettings (MyAppSettings)

GB_SYNTHESIZE_INT(optiona, setOptiona, @"optiona")
GB_SYNTHESIZE_INT(optionb, setOptionb, @"optionb")
GB_SYNTHESIZE_BOOL(optionc, setOptionc, @"optionc")

@end
```

There's a macro for each supported value type - `GB_SYNTHESIZE_BOOL` for `BOOL`, `GB_SYNTHESIZE_INT` for `NSInteger`, `GB_SYNTHESIZE_UINT` for `NSUInteger`, `GB_SYNTHESIZE_FLOAT` for `CGFloat`, `GB_SYNTHESIZE_OBJECT` for Objective C classes and special variant `GB_SYNTHESIZE_COPY` for cases where you'd like to copy the value instead of retaining it (`NSString`s for example). But you can easily create your own macros for types not supported out of the box - see implementation if *GBSettings.h*.

#### Custom initializers

Another thing you can easily stuff to your category is registration of array keys. I tend to create a new initializer method for this to keep the rest of the code as simple as possible:

```
@implementation GBSettings (MyAppSettings)

+ (id)mySettingsWithName:(NSString *)name parent:(GBSettings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:@"output"];
	}
	return result;
}

@end
```

Then you can initialize your settings stack using the custom initializer instead of `settingsWithName:parent:` like this:

```
GBSettings *factoryDefaults = [GBSettings mySettingsWithName:@"Factory" parent:nil];
GBSettings *settings = [GBSettings mySettingsWithName:@"CmdLine" parent:factoryDefaults];
```

Of course, if you'd chose subclassing over category, you could simply override designated initializer `initWithName:parent:` and perform initialization there!

#### Other customizations

Your category or subclass would also be a great place for embedding other behavior such as applying factory defaults:

```
@implementation GBSettings (MyAppSettings)

- (void)applyFactoryDefaults {
	self.optiona = 44;
	self.optionb = 55;
}

@end
```


Bringing it to the next level
-----------------------------

When developing command line interface, there's typically lots of repeating of similar code in several places. For example: registration of command line options to parser, creating properties and mapping them to option names, implementing help display, implementing option values display etc. Wouldn't it be neat if these could be automated? That was the question going through my mind and luckily, the answer is yes - at least for some of above mentioned concerns.

I chose to implement some of the most tedious ones with *GBOptionsHelper* class. It's optional and if used, works on top of `GBSettings` and `GBCommandLineParser`. By using it, you get help and version display for free. Plus with a bonus of being able to print the values of all options by the settings level. Also for free!


### How do I use it?

It's not that much different from before:

```
int main(int argc, char **argv) {
	// Create settings stack.
	GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
	[factoryDefaults setInteger:50 forKey:@"optiona"];
	[factoryDefaults setInteger:12 forKey:@"optionb"];
	GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
	
	// Create option shelper and register all options.
	GBOptionsHelper *options = [[GBOptionsHelper alloc] init]	[options registerOption:'a' long:@"optiona" description:@"The great option a" flags:GBValueRequired];
	[options registerOption:'b' long:@"optionb" description:@"The great option b" flags:GBValueOptional];
	[options registerOption:'c' long:@"optionc" description:@"Something else too" flags:GBValueNone];
	
	// Create parser, register options from helper and parser command line.
	GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
	[options registerOptionsToCommandLineParser:parser];
	[parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
		switch (flags) {
			case GBParseFlagUnknownOption:
				printf("Unknown command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagMissingValue:
				printf("Missing value for command line option %s, try --help!\n", option.UTF8String);
				break;
			case GBParseFlagArgument:
				[settings addArgument:value];
				break;
			case GBParseFlagOption:
				[settings setObject:value forKey:option];
				break;
		}
	}];
	
	// From here on, you can forget about GBOptionsHelper or GBCommandLineParser and only deal with GBSettings
	NSInteger a = [settings integerForKey:@"optiona"];
	NSInteger b = [settings integerForKey:@"optionb"];
	...
}
```

As you can see, you simply register options to `GBOptionsHelper` instead of `GBCommandLineParser` and then ask options helper to register all of its options to command line parser and proceed by parsing command line, copying all encountered values to settings class as before.

You probably also noticed registration took additional information such as description. This will come handy later on, when implementing help output, just ignore it for moment being.


### Help output

It's nice to include some form of help with command line tool. For example if user supplies `--help`, `-h`, `-?` on command line or simply types command without any arguments. It's expected command line behavior afterall. If using `GBOptionsHelper`, all that's required from your part is register help option and ask the class to print help if needed. Let's first see how you can do registration part:

```
int main(int argc, char **argv) {
	initialize settings stack as before
	...
	GBOptionsHelper *options = [[GBOptionsHelper alloc] init]
	[options registerSeparator:@"OPTION SET1"];
	[options registerOption:'a' long:@"optiona" description:@"The great option a" flags:GBValueRequired];
	[options registerOption:'b' long:@"optionb" description:@"The great option b" flags:GBValueOptional];
	[options registerSeparator:@"OPTION SET2"];
	[options registerOption:'c' long:@"optionc" description:@"Something else too" flags:GBValueNone];
	[options registerSeparator:@"MISCELLANEOUS"];
	[options registerOption:'?' long:@"help" description:@"Display this help and exit" flags:GBValueNonte];
	...
	register and parse as above
	...
	if (settings.printHelp || argc == 1) {
		[options printHelp];
		return 0;
	}
	...
}
```

Above example assumes you also extended your application specific `GBSettings` subclass or category with `@property (nonatomic, assign) BOOL printHelp;` and corresponding `GB_SYNTHESIZE_BOOL(printHelp, setPrintHelp, @"help")`. I've also added additional "separators" when registering options - this is optional, but can be very useful for more complex command lines. Anyway, if you use `--help` or `-?` on command line, or simply invoke it without any options, you'd be greeted with an output like this:

```
OPTION SET1
-a --optiona <value>   Project name 
-b --optionb [<value>] Project version 

OPTION SET2 
-c --optionc           Output path, repeat for multiple paths 

MISCELLANEOUS 
-? --help              Display this help and exit 
```


### Option values output

Another nice debugging aid is ability to print out the values that are used by current run. Assuming there's command line switch to enable or disable this, here's how you could do it:


```
int main(int argc, char **argv) {
	initialize settings stack as before
	GBSettings *factoryDefaults = ...
	GBSettings *settings = ...
	...
	GBOptionsHelper *options = [[GBOptionsHelper alloc] init]
	[options registerSeparator:@"OPTION SET1"];
	[options registerOption:'a' long:@"optiona" description:@"The great option a" flags:GBValueRequired];
	[options registerOption:'b' long:@"optionb" description:@"The great option b" flags:GBValueOptional];
	[options registerSeparator:@"OPTION SET2"];
	[options registerOption:'c' long:@"optionc" description:@"Something else too" flags:GBValueNone];
	[options registerSeparator:@"MISCELLANEOUS"];
	[options registerOption:0 long:@"print" description:@"Print values" flags:GBValueNonte];
	[options registerOption:'?' long:@"help" description:@"Display this help and exit" flags:GBValueNonte];
	...
	register and parse as above
	...
	if (settings.printValues) {
		[options printValuesFromSettings:settings];
	}
	...
}
```

Again assuming you've added `printValues` property to your `GBSettings` subclass or category, above example would result in the following output:

```
Setting         CmdLine      Factory 

OPTION SET1    
optiona                      44   
optionb         12           55     

OPTION SET2
optionc         5         

MISCELLANEOUS   
print           1
help            0
```

The display not only informs about the values that would be used on this run (44, 12, 5, 1, 0 top to bottom), but only where the values came from - was it from factory defaults or command line. Of course the display adapts to your settings hierarchy - if there are more levels in between, they are also printed out as expected!


### Customizing output & more

Sometimes you'd only like to include certain options to help and others to values display. For example: while `--help` is useful to include on help output, it usually doesn't make sense to include it on values output (if the user invokes it, it would display its help and exit, so values output wouldn't even be reached). Another example: some options may only be used on certain settings levels (such as settings read from a settings file) but not on command line (perhaps input paths which could be simply parsed as arguments following all command line switches, but would needed to be supplied as explicit paths in settings file).

By default all options are included, but you add flags to registration methods that will exclude individual options from either output. If you use `GBOptionNoCmdLine` option won't be registered to command line parser, `GBOptionNoPrint` will prevent option from appearing on print values output and `GBOptionNoHelp` on help output. You can combine several flags by or-ing them together with the value requirement: `GBValueNone|GBOptionNoHelp|GBOptionNoPrint`.

You can also customize output through several hooks which are called when appropriate. You could easily add your headers and footers this way without subclassing. Furthermore, you could use several placeholder strings which will be replaced by their appropriate values: `%APPNAME`, `%APPVERSION`, `%APPBUILD`. While getting the application name requires no effort from your side - the tool will pick it up from the command line, you have to provide version and build information. Here's how you could do that:

```
GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
options.applicationName = ^{ return @"mytool"; }; // optional, this is picked up automatically if not given
options.applicationVersion = ^{ return @"1.0"; };
options.applicationBuild = ^{ return @"100"; };
```

And here's how you add your own custom header to help output:

```
options.printHelpHeader = ^{ return @"%APPNAME: version %APPVERSION (build %APPBUILD)\n"; };
```

As blocks are only invoked if needed, you can safely add computationally intensive code in there (although that's probably not the case with this type of information).

**Note:** Version display via `printVersion` method is handled similary: when invoked, it prints the application name - either the value returned from `applicationName` block or fetching it from command line if not supplied. If `applicationVersion` is also given, version information is appended and if `applicationBuild` is given, that value is also appended resulting in the following type of output: `mytool: version 1.0 (build 100)`.

- - -

Allright, this tutorial is over, check example application included with Xcode project to see it in a more real-life situation.


Contribution notes
------------------

Want to contribute to the project? You're warmly welcome - forking the project on GitHub and creating pull request with your changes is the way to go! Although I will *probably* accept changes via email, pull requests make it much easier and hassle free! And they preserve the author. Oh, please make sure your changes to the source code match the coding style in order to maintain readability.


License
-------

The code is provided under MIT license as stated below:

	Copyright (C) 2012 by Tomaz Kragelj
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.