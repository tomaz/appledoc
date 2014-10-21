GBCli
-----

GBCli is command line interface helper library. It provides classes for simplifying command line Objective C foundation tools code. The library is designed to be as flexible as possible to suit wide range of tools. It requires no external dependency besides *Foundation.framework*. The library was inspired by [DDCli](http://www.dribin.org/dave/software/#ddcli) by Dave Dribin.

Here's how it happened (skip this part if you're only interested in techical stuff :) - When I started work on redesigning [appledoc](http://gentlebytes.com/appledoc), one of the first files I included was DDCli library. However I soon discovered it doesn't work well with arc. That, coupled with different workflow I wanted, prompted me to dig in Dave's code to see how I could change it to suit my needs better. To cut long story short - at the end I ended writing the whole library from scratch and now parsing is implemented manually, without relying on `getopt_long`. As I was adding more functionality, I realized, I could make it as reusable component and publish it on GitHub...

This file serves as tutorial demonstrating what you can do with the library.


Integrating to your project
---------------------------

The simplest way of integrating GBCli is through cocoapods. Just add this line to your Podfile:

```
pod "GBCli"
```

Then import all files so compiler can see them: `#import <GBCli/GBCli.h>`.

If you prefer to include sources directly, just copy all .h and .m files from `GBCli/src` subfolder to your Xcode project and import `GBCli.h` header (in this case you'll probably need to use `#import "GBCli.h"`).


Parsing command line arguments
------------------------------

The most basic building block of the library is parsing command line arguments. This is implemented with *GBCommandLineParser* class. To use it, you need to register all options first, then have it parse command line. Based on registered data, the class determines whether command line is valid or not. But that alone wouldn't be that useful, so the class also offers interface for getting the actual options and argument values. You can use callback API to be notified about each option and/or argument as it is parsed (**Note:** with *options* I refer to command line options such as `--verbose`, `--help` etc, while *arguments* are various arguments that follow the options such as paths to source files etc).

Besides callback API, parser also stores all recognized options and arguments internally, so you can query it for values after parsing is complete. This can solve the problem with storing values.

An example:

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
				printf("Unknown command line option %s, try --help!\n", [option UTF8String]);
				break;
			case GBParseFlagMissingValue:
				printf("Missing value for command line option %s, try --help!\n", [option UTF8String]);
				break;
			case GBParseFlagOption:
				// do something with 'option' and its 'value'
				break;
			case GBParseFlagArgument:
				// do something with argument 'value'
				break;
		}
	}];
	...
	// Now that parsing is complete, you can access options and arguments:
	id valuea = [parser valueForOption:@"optiona"];
	NSArray *arguments = parser.arguments;
	...
}
```

In above example, we've registered 3 options:

- `--optiona` with shortcut `-a` as a required value.
- `--optionb` with shortcut `-b` as an optional value.
- `--optionc` with shortcut `-c` and no value.

You can also register only long option, without short variant - just pass `0` for the short option argument. As you can see you can specify each option's value as required, optional or no value. Here's how it works:

- *Required values:* the option must be followed by a value like this: `--optiona value`, `-a value` or alternatively `--optiona=value` or `-a=value` (in later case there must be no space in between the option name, equal sign and the value!). If value is missing, parser will report missing value via *GBParseFlagMissingValue* flag. Note that you need to embed strings with whitespaces into quotes like this: `--some-option "My whitespaced string"`.
- *Optional values:* the value is optional, so all of these are valid: `--optionb value`, `-b value`, `--optionb=value`, `-b=value`. In these cases, the given value is reported as a *NSString*. Additionally, you can also omit the value altogether: `--optionb` or `-b`. In this case, *NSNumber* setup as `@YES` is reported to block as long as the option is provided on command line.
- *No value:* the option is a "command line boolean switch". If the option is found on command line (for example `--optionc` or `-c`) it is assumed as "enabled" and an `[NSNumber numberWithBool:YES]` is reported as its value in parsing block. These options can also use negated syntax in the form `--no-<option name>` (for example: `--no-optionc`) - in this case the option is assumed as "disabled" and an `[NSNumber numberWithBool:NO]` is reported as its value. This is especially useful when you have an option enabled by default (i.e. in factory settings), and you want to override the value on command line. Note that no value options also accept *option=value* syntax, so `--optionc=1` is equal to `--optionc` and `--optionc==0` to `--no-optionc`. Note that you can only use *option=equal* syntax, it doesn't work with space!


Application wide settings handling
----------------------------------

In most cases, you'd like to store values from command line into a simple to use interface that you can then pass on to various components of your tool. GBCli provides *GBSettings* class for that purpose. In its basic form, it provides *NSUserDefaults* like interface to the settings through methods like `objectForKey:`, `setObject:forKey:`, `boolForKey:`, `setBool:forKey:` etc. Example:

```
int main(int argc, char **argv) {
	// Create settings.
	GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:nil];
	[settings setInteger:50 forKey:@"optiona"];
	[settings setInteger:12 forKey:@"optionb"];

	// Create parser and register all options.
	GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
	[parser registerOption:@"optiona" shortcut:'a' requirement:GBValueRequired];
	[parser registerOption:@"optionb" shortcut:'b' requirement:GBValueOptional];
	[parser registerOption:@"optionc" shortcut:0 requirement:GBValueNone];

	// Parse command line
	[parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
		switch (flags) {
			case GBParseFlagUnknownOption:
				printf("Unknown command line option %s, try --help!\n", [option UTF8String]);
				break;
			case GBParseFlagMissingValue:
				printf("Missing value for command line option %s, try --help!\n", [option UTF8String]);
				break;
			case GBParseFlagOption:
				[settings setObject:value forKey:option];
				break;
			case GBParseFlagArgument:
				[settings addArgument:value];
				break;
		}
	}];

	// From here on, just use settings...
	NSInteger a = [settings integerForKey:@"optiona"];
	NSInteger b = [settings integerForKey:@"optionb"];
	...
}
```

Note how we provided some "factory defaults" when creating *GBSettings*. This is entirely optional, but is nice way of defining the values that should be used for optional arguments.


### Settings hierarchy

While above example may be all you need, *GBSettings* class allows you to easily manage a hierarchy of settings. For example factory defaults and command line, or additional layers in between. For example appledoc can also read settings from global or project files. And options should take precedence, so for example value provided in command line overrides factory defaults. *GBSettings* make this very simple - here's how you could extent previous example:

```
int main(int argc, char **argv) {
	// Create settings stack.
	GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
	[factoryDefaults setInteger:50 forKey:@"optiona"];
	[factoryDefaults setInteger:12 forKey:@"optionb"];
	GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];
		
	...the rest is exactly the same as previous example...
}
```

In this example, we've setup factory defaults / cmd line hierarchy:

1. First we created an *GBSettings* object that will serve as built in "factory defaults". We set it up with values of *50* for option *optiona* and *12* for *optionb*.
2. Then we prepared another *GBSettings* object that will be used to collect command line values - note how we told it about it's "parent" settings.

You establish settings hierarchy by providing *parent* settings when creating child *GBSettings* objects. By doing that, child values will take precedence to parent ones. However if child doesn't have specific value, it'll automatically fall back and ask its parent for it. And so on - you can nest as many layers as you need. And that's all there is to it - "it just works". Note that *GBCommandLineParser* doesn't need to know anything about the hierarchy, it just needs the *GBSettings* object into which it will copy all options from command line. The same for the rest of the application classes: they only need to know about the "lowest" level (or the highest precedence - depending how you look at it) *GBSettings* object. It'll automatically fetch values form its parents if needed. And in case you're wondering: if a given value isn't provided anywhere in the hierarchy, `nil` (or `0` or `NO` for scalars) is returned.

Now, you may be asking yourself why settings hierarchy might be useful. It'll become more apparent in following chapters, so if interested, read on...

But before we get there:


### Isn't there too much boiler plate code for parsing settings?

I couldn't agree more with you - this whole `parseOptionsWithArguments:count:block:` dance feels like an overhead for something that should be built in. And in fact it is, provided that you use *GBSettings*. In such case, you can simply register the settings to *GBCommandLineParser* and use one of the simplified parsing methods like this:

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
	
	// Register settings and then parse command line
	[parser registerSettings:settings];
	[parser parseOptionsWithArguments:argv count:argc];

	// From here on, just use settings...
	NSInteger a = [settings integerForKey:@"optiona"];
	NSInteger b = [settings integerForKey:@"optionb"];
	...
}
```

Now this feels much better doesn't it!? In order to use simplified parse methods, you must register settings beforehand via `registerSettings:` method. If you're using settings hierarchy, you only need to register the "lowest" level - as demonstrated in above example.

Note that these "simplified" parsing methods will simply print any error to stdout and assign options and arguments to registered settings.


### Accumulating repeated options into arrays

Sometimes, you'd like to allow the user to repeat an option several times. In such case you'd most likely be interested in receiving all values. For example, let's assume you want to be able to duplicate output to several locations. One way would be to have `--outputs` option that would take a list of locations delimited with some predefined char such as `;` - like `--outputs ~/Dir1;~/Dir2`. That's certainly possible, but would require some post processing from your part.

Fear not: *GBSettings* include "treat key as array" feature that allows you implement this through key repetition. This would allow you to use something like `--output ~/Dir1 --output ~/Dir2` (or with alternative syntax `--output=~/Dir1 --output=~/Dir2`). And the best part is - it's all handled automatically for you (well almost automatically) - you do need to register the option as an array. Assuming you're using two layers - factory defaults and command line settings, it would look like this:


```
[factorySettings registerArrayForKey:@"output"]
[settings registerArrayForKey:@"output"]
```

In this case, `[settings objectForKey:@"output"]` will return an `NSArray` containing all values. If there was no value, `nil` would be returned, if there was single value, an array with single item would be returned. Furthermore - provided you're using settings hierarchy - the resulting array would contain all values, accumulated through the whole settings stack - including all parents!

**Again:** Note that you must register the option as array to each level separately! If this seems like lot's of repeating work, read on :)


### Application specific settings interface

While using *GBSettings* out of the box via KVC interface may be sufficient for basic tools, in most cases, you'd benefit by embedding KVC into a nice `@property` based interface customized to specific application.

#### Custom properties

One way would be overriding *GBSettings* class, but Objective C provides (IMHO) better solution for that - categories. Here's how it may look one for above example:

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

Of course, if you'd chose subclassing over category, you could simply override designated initializer `initWithName:parent:` and perform initialization there! Either case, this will nicely embed settings setup into a single place.


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

Then you can setup your settings stack like this:

```
GBSettings *factoryDefaults = [GBSettings mySettingsWithName:@"Factory" parent:nil];
GBSettings *settings = [GBSettings mySettingsWithName:@"CmdLine" parent:factoryDefaults];
[factoryDefaults applyFactoryDefaults];
```

This would further cleanup outside code and keep all settings related in single place.


Bringing it to the next level
-----------------------------

When developing command line interface, there's typically lots of repeating of similar code in several places. For example: registration of command line options to parser, creating properties and mapping them to option names, implementing help display, implementing option values display etc. Wouldn't it be neat if these could be automated? That was the question going through my mind and luckily, the answer is yes - at least for some of above mentioned concerns.

I chose to implement some of the most tedious ones with *GBOptionsHelper* class. It's optional and if used, works on top of *GBSettings* and *GBCommandLineParser*. By using it, you get help and version display for free. Plus with a bonus of being able to print the values of all options by the settings level. Also for free!


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
	GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
	[options registerOption:'a' long:@"optiona" description:@"The great option a" flags:GBValueRequired];
	[options registerOption:'b' long:@"optionb" description:@"The great option b" flags:GBValueOptional];
	[options registerOption:'c' long:@"optionc" description:@"Something else too" flags:GBValueNone];
	
	// Create parser, register options from helper and parser command line.
	GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
	[parser registerSettings:settings];
	[parser registerOptions:options];
	[parser parseOptionsWithArguments:argv count:argc];
	
	// From here on, you can forget about GBOptionsHelper or GBCommandLineParser and only deal with GBSettings
	NSInteger a = [settings integerForKey:@"optiona"];
	NSInteger b = [settings integerForKey:@"optionb"];
	...
}
```

As you can see, you simply register options to *GBOptionsHelper* instead of *GBCommandLineParser* and then ask options helper to register all of its options to command line parser and proceed by parsing command line, copying all encountered values to settings class as before.

You probably also noticed registration took additional information such as description. This will come handy later on, when implementing help output, just ignore it for moment being.


### Help output

It's nice to include some form of help with command line tool. For example if user supplies `--help`, `-h`, `-?` on command line or simply types command without any arguments. It's expected command line behavior after all. If using *GBOptionsHelper*, all that's required from your part is register help option and ask the class to print help if needed. Let's first see how you can do registration part first:

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
	if (argc == 1 || settings.printHelp) {
		[options printHelp];
		return 0;
	}
	...
}
```

Above example assumes you also extended your application specific *GBSettings* subclass or category with `@property (nonatomic, assign) BOOL printHelp;` and corresponding `GB_SYNTHESIZE_BOOL(printHelp, setPrintHelp, @"help")`. I've also added additional "separators" when registering options - this is optional, but can be very useful for more complex command lines. Anyway, if you use `--help` or `-?` on command line, or simply invoke it without any options, you'd be greeted with an output like this:

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

Another nice feature you get for free with *GBOptionsHelper* is ability to print out the values that are used by current run. It can be a nice debugging tool if nothing else. Assuming there's command line switch to enable or disable this, here's how you could do it:


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

Again assuming you've added `printValues` property to your *GBSettings* subclass or category, above example would result in the following output:

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


### Filtering out options for help and values output

Sometimes you'd only like to include certain options to help and others to values display. For example: while `--help` is useful to include on help output, it usually doesn't make sense to include it on values output (if the user invokes it, it would display its help and exit, so values output wouldn't even be reached). Another example: some options may only be used on certain settings levels (such as settings read from a settings file) but not on command line (perhaps input paths which could be simply parsed as arguments following all command line switches, but would needed to be supplied as explicit paths in settings file).

By default all options are included, but you add flags to registration methods that will exclude individual options from either output. If you use `GBOptionNoCmdLine` option won't be registered to command line parser, `GBOptionNoPrint` will prevent option from appearing on print values output and `GBOptionNoHelp` on help output. You can combine several flags by or-ing them together with the value requirement: `GBValueNone|GBOptionNoHelp|GBOptionNoPrint`.


### Customizing default help and values output

You can customize default output for `printHelp` and `printValues` methods through several hooks which are called when appropriate. You could easily add your headers and footers this way without subclassing. One of perhaps most obvious examples would be providing application name and version information. While getting the application name requires no effort from your side - the tool will pick it up from the command line, you have to provide version and build information. Here's how you could do that:

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

Note usage of "placeholder strings" which will be conveniently replaced by their appropriate values: `%APPNAME`, `%APPVERSION`, `%APPBUILD`. Check source code for *GBOptionsHelper* class for other hooks.


Miscellaneous
-------------

### Option groups

GBCli 1.1 and later allows grouping options into "option groups" (or commands). This allows you to separate options into groups. This results in more readable command line (and plist files). Here's how you could use *GBOptions* to setup groups:

```
GBOptionsHelper *options = [[GBOptionsHelper alloc] init]
[options registerSeparator:@"OPTIONS:"];
[options registerOption:'a' long:@"optiona" description:@"The great option a" flags:GBValueRequired];
[options registerOption:'b' long:@"optionb" description:@"The great option b" flags:GBValueOptional];
[options registerSeparator:@"COMMANDS:"];
[options registerGroup:@"group1" description:@"[GROUP 1 OPTIONS]:" optionsBlock:^(GBOptionsHelper *options) {
	[options registerOption:0 long:@"option11" description:@"Group 1 option 1" flags:GBValueNone];
	[options registerOption:0 long:@"option12" description:@"Group 1 option 2" flags:GBValueNone];
}];
[options registerGroup:@"group2" description:@"[GROUP 2 OPTIONS]:" optionsBlock:^(GBOptionsHelper *options) {
	[options registerOption:0 long:@"option21" description:@"Group 2 option 1" flags:GBValueNone];
	[options registerOption:0 long:@"option22" description:@"Group 2 option 2" flags:GBValueNone];
}];
```

Then you'd register options to *GBCommandLineParser* as usual. Note that you can also use options outside groups, just register them outside of groups as shown above. With above code, you could use command line like this:

```
mytool --optiona group1 --option11 --option12 group2 --option21
```

Note that groups are also accepted in plist files - simply setup a value as a dictionary and prepare keys and values in there as you would for root keys:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>group1</key>
	<dict>
		<key>option11</key>
		<true/>
		<key>option12</key>
		<true/>
	</dict>
	<key>group2</key>
	<dict>
		<key>option21</key>
		<true/>
	</dict>
	<key>optiona</key>
	<true/>
</dict>
</plist>
```

Note that option groups have some limitations at the moment. Specifically: on *GBSettings* level, there's no support for groups, all settings are stored on the same level. This brings couple of potential issues:

- You can't use the same option name inside multiple groups.
- Plist files don't really validate names of groups.


### Printing and logging

GBCli 1.1 and later adds support for simple `printf` like functions that accept `NSString` instead of plain C string. These functions are: 

- `gbprint`: prints the given string to stdout. Example `gbprint(@"Hello %@", @"World");`.
- `gbprintln`: same as `gbprint` but adds newline at the end of string.
- `gbfprint`: same as `gbprint` except it allows you to specify the file. Example `gbfprint(stderr, @"Hello %@", @"World);`
- `gbfprintln`: same as `gbfprint` but adds newline at the end of string.

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