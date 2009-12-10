appledoc purpose
================

The main purpose of appledoc utility is to generate Apple like source code documentation. 
It uses doxygen for parsing the source files and creating intermediate XML files. These 
are then eventually converted to different outputs and optionally fully indexed and browsable 
documentation set. The utility can also install the documentation set into the Xcode 
documentation window. The whole process is wrapped into a single (and simple) command line.

The idea for such a utility came from a lack of good document generator for Objective C
that generated nice looking documentation. After testing many different solutions, I came
accross Matt Ball's doxyclean utility. This is a Phyton script that produces apple like
documentation through the use of doxygen for the hard part of source parsing. After using
it for a while, I started playing with it to come closer to what I finally wanted - the
working documentation set. In fact, after some tweaking with the code and a huge (and I
really mean *huge*) Xcode custom build script, I was finally (almost) satisfied. What
I was not happy about was the mentioned build script which was not only hard to maintain,
but was also the part that had to be repeated in each Xcode project, so any tweaking would
require manual copying of script between projects... Also doxygen Objective C support is
not 100% which affects member and cross-file links for doxyclean as well (at least at the
moment of this writting, Matt is constantly updating the utility, so this may have been 
fixed!). I did tweak the script a bit to get (some) of the links working, however, I am 
not that familirar with Phyton and debugging the script was difficult. That, combined with 
my inexperience with Phyton, lead me to a complete rewrite of the utility in Objective C 
and this is what you are looking at now...

If you want to give Matt's doxyclean a try, check it out on his 
[github](http://github.com/mattball/doxyclean/) page. Especially if you're interested in
using the generator in non OS X environment or in Tiger, you're probably out of luck with 
appledoc. Matt is also constantly updating his code and has implemented several features 
which may be decision makers for you such as links to Foundation and AppKit classes etc.

Finally, I want to thank Matt for letting him use his css and his XSLT code, so
thanks Matt... :-)


Features
--------
 
* Generates apple like XHTML documentation.
* Generates visual class hierarchy.
* Generates fully indexed and browsable documentation set.
* Installs documentation set to Xcode documentation window and research assistant.
* Optionally merges category documentation into extended class.
* Preserves (almost) all member links including inter-object ones.
* Fixes several doxygen Objective C related defficiencies.
* Automatically generates required source files for doxygen and documentation set.
* Almost all pure Objective C code which makes it easy to debug and play with.
* Simple command line usage which greatly simplifies Xcode scripts.


Prerequisites
-------------

*	Doxygen must be installed; [mac ports](http://www.macports.org/) version is 
	recommended since it will install the utility to a default path which is used
	by appledoc.
*	The requirement for building the source is Xcode 3.


Installation
------------

The recommended way of installing is to use `git clone` command, which will also greatly 
simplify updating. To install, type the following into your terminal:

	git clone git://github.com/tomaz/appledoc.git appledoc

This will generate `appledoc` directory at the current path. Inside you'll find the Xcode
project which you can open and build. Now you're ready to use the utility, so you can
copy the built executable to some directory that's in your path. This will make it easier
to use it later on. However, some external files are also needed before you can actually
run the utility over your code. These include css and XSLT files and need to be copied
into proper directory. You can find all required files in the project's `Templates` sub 
directory and manually copy them to one of the following paths:

* ~/.appledoc
* ~/Library/Application Support/appledoc

(Copy only the files, not the Templates directory itself!). However, to automate the process,
you can also use "Install" script from the Xcode - just select "Install" as the active
target and build it. It will install all required files to the application support
directory (you still need to manually copy the executable).

Now you're ready to go! Build the project to generate the `appledoc` executable. I recommend
you copy the executable to some directory on your path such as `/usr/local/bin` or similar so
that it is easily accessible. You can periodically check for updates by typing the following 
into your terminal:

	cd <directory where you installed appledoc>
	git pull

If you're using precompiled executable, the installation is similar. Just copy the files to
the locations as mentioned above.


Quick start / tutorial
----------------------

Let's assume your source files are located in `~/MyProject` and you want to create HTML
documentation in the `Help` subdirectory. The way to do it is:

	appledoc -p "My Great Project" -i ~/MyProject -o ~/MyProject/Help --xhtml
	
Then open `~/MyProject/Help/cxhtml/Index.html` file to see your documentation. As you 
continue to work on your project, you may delete or rename some of documented source files.
If you run the appledoc again, you may still see the old file remaining in the documentation, 
no matter how many times you run the utility. To remedy that, simply remove `Help` directory
and run the utility again. However, `appledoc` can automate this for you by using the 
following command line:

	appledoc -p "My Great Project" -i ~/MyProject -o ~/MyProject/Help --xhtml --clean-before-build

This will delete the directory given with the `-o` option before building, so fresh build
will be issued each time. *Be careful with this option though - if you keep anything
besides the generated documentation there, it will be deleted too, so first make sure that
you are fine with deleting the output directory in Finder before using this option (or
see other options below)!*

You may have noticed that the `Help` subdirectory contains `cxml` and `xml` directories 
besides the `cxhtml`. These are intermediate files. If you're only interested in the final 
product, you may preffer the following command line:

	appledoc -p "My Great Project" -i ~/MyProject -o ~/MyProject/Help --xhtml --clean-temp-files
	
Now only the final product - HTML files in this case - remain. In fact you may want to
use this option instead of `--clean-before-build` if you don't need intermediate files.
It will automatically take care of the file renames and deletes as well.

Browsing through the documentation in Safari or other browser is just fine. However, you
want to use it within the Xcode itself - when you select your class or methods, you want
to see the documentation in Research Assistant and you want to be able to type one of
your methods in Xcode documentation window search field and see it in the list and all
other things you're used to with Apple documentation. No problem, change the command line
to:

	appledoc -p "My Great Project" -i ~/MyProject -o ~/MyProject/Help --docset --clean-temp-files
	
First you'll notice that the HTML files are removed from the output path and there's no
documentation set there. However, when you open the Xcode documentation window, you can
see `Custom documentation` option with `My Great Project` listed within. Click on that
and you can browse the documentation and use all of the other documentation features.

*Note that all the above command lines assume `appledoc` is found on the path.*


Known issues
------------

*	As of doxygen 1.6.1 some objective-c classes derived information is not extracted
	(NSManagedObject as an example). In such cases the hieararchy misses all these 
	subclasses. The objects and main index documentation is still extracted properly.



Command line usage
==================

The utility was designed to allow as simple command line usage as possible while still
allowing full automation of all processes required to generate fully working documentation
set or other output. With that in mind, most of the options are kept to some reasonable 
default, so they can only be changed if needed.

Note that in general for all options that require a parameter, the parameter needs to be
enclosed within quotes if it contains spaces - if you're using the utility from the
command line, the spaces are automatically escaped for you, at least for paths, so this 
may not be necessary, however if you're using it as Xcode build script, you need to take 
care of that!

Oh, and all boolean swithces can be prefixed with `--no-` following the switch name to
override the default or global value. Example: `--no-docset`.

That being said, the usage is:
	
	appledoc [options]
	
To get the list of all available options, use the `appledoc` command line without any
option. The options will also be written if generation fails, including the reason for
failure. In such case, it might be necessary to increase verbose level to get more
information as to where the problem came from. But we're ahead of ourselves now...


Required options
----------------

*	`-p <name>` or `--project <name>`: The name of the project.
*	`-i <path>` or `--input <path>`: The path of the source files.
*	`-o <path>` or `--output <path>`: The path at which to generate output.


Doxygen related options
-----------------------

*	`-c <path>` or `--doxyfile <path>`: The name and full path to the doxygen configuration
	file. Defaults to `<input-path>/Doxyfile` if not specified which will create the
	`Doxyfile` in the source directory if it doesn't yet exist. You may want to add it to
	the Xcode groups and files (and add it to SCM repository) after first run, so you can
	tweak it later on - the file will not be overwritten if it already exists! Just make 
	sure to keep xml generation on, because `appledoc` depends on that! Note that the 
	`appledoc` project includes the file and I tweaked it to support my style of brief 
	description.
*	`-d <path>` or `--doxygen <path>`: Full path to the doxygen command. Defaults to
	`/opt/local/bin/doxygen` if not specified which is where mac ports will install
	the utility. If you have it on other path, you will need to provide it through
	command line arguments each time documentation is generated or change it once in
	global parameters (see below).


Clean XML generation options
----------------------------

*	`--fix-class-locations`: Fix class locations if they seem invalid. This fixes doxygen
	paths for cases where categories are defined in separate files. Doxygen gets confused
	and decides that the main class is implemented in one of these. If you experience such
	behavior, use this option to correct it. However this will only work properly if the
	name of the file is the same as the name of the class... Experiment to see it it's
	working for you.
*	`--remove-empty-paragraphs`: If used all empty paragraphs will be stripped.
*	`--merge-categories`: Merges categories documentation to the extended classes.
*	`--keep-merged-sections`: When merging categories, preserve their sections. By default
	each category is merged into a single section within the class with the name of the
	category itself. However, with this option, all sections (member groups) are preserved
	as well. Note though that this may make the documentation very cluttered, so experiment
	to see what works best for you.


Clean output generation options
-------------------------------
 
Note that by default, only clean XML files will be generated, so you need to specify one
or more of the following options to actually produce something more readable...

*	`--xhtml`: Generate XHTML documentation.
*	`--docset`: Generate documentation set (this will automatically enable xhtml as well!).
*	`--markdown`: Generate Markdown documentation.


XHTML output options
--------------------

*	`--xhtml-bordered-issues`: Use bordered examples, warnings and bugs to make them
	stand out of the rest a bit more. This also produces more Apple like documentation.


Documentation set related options
---------------------------------

*	`--docid <id>`: Documentation set unique bundle ID. Defaults to `com.custom.<project>.docset`.
*	`--docfeed <name>`: Documentation set feed name. This is what will be visible in the
	Xcode documentation window. Defaults to `Custom documentation`.
*	`--docplist <path>`: Full path to documentation set description plist file. Defaults
	to `<input-path>/DocSet-Info.plist` if not specified, which will create the file in
	the source directory if it doesn't yet exist. Again, you may want to include the file
	to your Xcode project (and SCM), so you can tweak it if necessary.
*	`--docutil <path>`: Full path to `docsetutils` executable. This is needed to index
	the created documentation set. Defaults to `/Developer/usr/bin/docsetutils` which is
	the default install location, however if you use another path, you must manually
	specify it.
	
	
Markdown output options
-----------------------

*	`--markdown-line-length <number>`: The number of chars to use before forcing a new
	line. Setting this value below or equal to 0 prevents wrapping take place. Defaults to 80.
	note that wrapping for non-wrappable phrases (method names for example) can be controller
	finer with `--markdown-line-threshold` and `--markdown-line-margin`. Note that line
	wrapping values may not seem intuitive from the start on, so play with them a bit to
	get a feel.
*	`--markdown-line-threshold <number>`: If a non-wrappable phrase is being added to a
	line and causes the line to break, this setting prevents break if the line length is
	below the given threshold of the `--markdown-line-length` and the phrase length is not
	too big. This value should be kept reasonably small. Defaults to 7.
*	`--markdown-line-margin <number>`: If a non-wrappable phrase is being added to a line
	and the line length passes the `--markdown-line-threshold` "test" above and the overall
	length of the line including the phrase is still below the given margin (added to the
	value of `--markdown-line-length`), the phrase is kept in the same line. This value
	should be kept reasonably small. Defaults to 12.
*	`--markdown-refstyle-links`: Use reference style links. When used, the links to
	same or inter-object members will be created using reference style links which are
	generated as footnotes. Numbers will be used for link IDs, starting with 1 and
	links to the same object or member will be properly handled (i.e. will not be repeated). 
	Using this option will result in much more readable output. If this option is not used, 
	inline links will be generated which is the default. Note that this option only affects
	object files creation, index and hierarchy always use inline links!


Formatting options
------------------

*	`--object-reference-template`: Inter-object reference (links) generation style. This
	option allows you to change the way the link names are generated. Defaults to 
	`$PREFIX[$OBJECT $MEMBER]`. However you may choose to only generate member name or any
	combination. You can use `$PREFIX`, `$OBJECT` and `$MEMBER` placeholders which will be 
	replaced by the selector prefix (`-` or `+`), object name and member name respectively.
*	`--member-reference-template`: Same-object reference (links) generation style. This
	option allows you to change the way the link names are generated. Defaults to
	`$PREFIX $MEMBER`. You can use `$PREFIX` and `$MEMBER` placeholders which will be
	replaced by the selector prefix (`-` or `+`) and member name respectively.
*	`--date-time-template`: Date and time template format. This is used for generating
	last updated. Any number of date and time components can be formatted using format
	specifiers of `NSCalendarDate`. Defaults to `(Last updated: %Y-%m-%d)`. As you can
	see this allows you to use any static text, such as your copyright notice, for
	example: `(c) 2008-%Y YourCompany. All rights reserved. (Last updated: %Y-%m-%d)`
	would give you similar footer as Apple documentation does.


Miscellaneous options
---------------------

*	`--clean-temp-files`: Remove all temporary build files. Note that this is 
	dynamic and will delete generated files based on what is build. If html is created, 
	all doxygen and clean xml is removed. If doc set is installed, the whole output path 
	is removed. This is useful if you are only interested in installing and using the 
	documentation within the Xcode and want to remove all intermediate files.
*	`--clean-before-build`: Remove output files before build. *This option should only be 
	used if output is generated in a separate directory. It will remove the whole 
	directory structure starting with the `<output-path>` path! BE CAREFUL!!!* Note that this 
	option is automatically disabled if `<output-path>` and `<input-path>` directories are the 
	same.
*	`-t <path>` or `--templates <path>`: Full path to template files. If not provided, 
	templates are searched in `~/.appledoc` or `~/Library/Application Support/appledoc`
	directories in the given order. The templates path is also checked for `Globals.plist` 
	file that contains default global parameters. Global parameters are overriden by 
	command line arguments. See more about globals later on.
*	`-v <level>` or `--verbose <level>`: The verbose level (1-5). Defaults to 0 (only errors).
	You may want to increase this if utility is failing and you don't know why.



Global parameters
=================

Ok, so it turns out that `appledoc` command line may become quite cluttered after all if 
default values are not desired. Additionally, there may be some sets of options that are 
repeated for every project. Well, that's where global parameters come to assistance. As 
already mentioned above, there are several default paths possible where the required 
external files are searched for (see installation section for more details or alternatively, 
a custom path can be specified via the command line arguments, checked previous section for 
that).

If file `Globals.plist` is found on any of the predefined template paths or at the custom
templates path from the command line, the file is read and the values from it replace
factory defaults as stated in previous section. In practice this means, that all commonly
used sets of variables can be written once in the global parameters file and only use
the parameters that are specific for a certain project. If you're "lucky" enough, only
the required parameters will be necessary.

All global parameters may be overriden by command line parameters. The priority of the
parameters is (from less to more):

* Factory defaults.
* Global parameters.
* Command line parameters.


Global parameters list
----------------------

There is no direct support of creating the global parameters through the `appledoc` command
line, but you can use the Property List Editor. Just create a root dictionary with the
desired keys and values as specified below. The list of global parameters and their command 
line counterparts is:

*	`DoxygenCommandLine` (String): `--doxygen`
*	`DoxygenConfigFile` (String): `--doxyfile`

*	`CreateXHTML` (Boolean): `--xhtml`
*	`CreateDocSet` (Boolean): `--docset`
*	`CreateMarkdown` (Boolean): `--markdown`

*	`XHTMLUseBorderedExamples` (Boolean): `--xhtml-bordered-issues` can be used to set
	XHTMLUseBorderedExamples, XHTMLUseBorderedWarnings and XHTMLUseBorderedBugs in one
	setting. There is no way to specify each separately over command line. There's also
	no way to specify all three with a single setting in global parameters.
*	`XHTMLUseBorderedWarnings` (Boolean): see previous item.
*	`XHTMLUseBorderedBugs` (Boolean): see previous item.

*	`DocSetBundleID` (String): `--docid`
*	`DocSetBundleFeed` (String): `--docfeed`
*	`DocSetSourcePlist` (String): `--docplist`
*	`DocSetUtilCommandLine` (String): `--docutil`
*	`DocSetInstallPath` (String): The path for installing the documentation set. Not
	possible to change over command line.

*	`MarkdownLineLength` (Number): `--markdown-line-length`
*	`MarkdownLineWrapThreshold` (Number): `--markdown-line-threshold`
*	`MarkdownLineWrapMargin` (Number): `--markdown-line-margin`
*	`MarkdownReferenceStyleLinks` (Boolean): `--markdown-refstyle-links`

*	`FixClassLocations` (Boolean): `--fix-class-locations`
*	`RemoveEmptyParagraphs` (Boolean): `--remove-empty-paragraphs`
*	`MergeCategories` (Boolean): `--merge-categories`
*	`KeepMergedSections` (Boolean): `--keep-merged-sections`

*	`ObjectReferenceTemplate` (String): `--object-reference-template`
*	`MemberReferenceTemplate` (String): `--member-reference-template`
*	`DateTimeTemplate` (String): `--date-time-template`

*	`CleanTemporaryFilesAfterBuild` (Boolean): `--clean-temp-files`
*	`CleanOutputFilesBeforeBuild` (Boolean): `--clean-before-build`
*	`VerboseLevel` (Number): `--verbose`


Global parameters placeholders
------------------------------

The following template placeholders can be used within the global parameters:

- `$PROJECT`: This will be replaced by the project name from the command line.
- `$INPUT`: This will be replaced by the input path from the command line.
- `$OUTPUT`: This will be replaced by the output path from the command line.

These can be used to get some dynamic information without being forced to repeat the
command line from project to project. For example, you can use it for custom documentation
set ID - if the  `DocSetBundleID` is `com.yourdomain.$PROJECT.docset`, the `$PROJECT` will 
automatically be replaced by the passed project name from the `--project` command line 
argument.

Additionally, `$PREFIX`, and `$MEMBER` can be used as placeholders for `MemberReferenceTemplate`
parameter, while the `ObjectReferenceTemplate` can also use `$OBJECT` as described above.



Xcode integration
=================

Automated documentation builds
------------------------------

The following command line is useful as the script within custom Xcode run script phase
in cases where the *Place Build Products In* option is set to *Customized location*.
It will create a directory named `Help` alongside `Debug` and `Release` in the
specified custom location. Inside it will create a sub directory named after the
project name in which all documentation sub-directories and files will be created:

	appledoc -p "$PROJECT_NAME" -i "$SRCROOT" -o "$BUILD_DIR/Help/$PROJECT_NAME" --docset --clean-temp-files

The following command line is useful as the script within custom Xcode run script phase
in cases where the *Place Build Products In* option is set to *Project directory*.
It will create a directory named `Help` inside the project source directory in
which all documentation sub-directories and files will be created:

	appledoc -p "$PROJECT_NAME" -i "$SRCROOT" -o "$SRCROOT/Help" --docset --clean-temp-files

Note that doxygen parsing and documentation set indexing may take quite some time,
especially on large projects, so you may prefer to create a special shell script build
target which you can use to periodically update the documentation. Or you can create
several targets for updating xhtml and docset separately depending on your preference.


Automated documentation generation
----------------------------------

I'm using the following macros for automating doxygen code documentation for objects. The
macros are suited to my documentation style, so feel free to update them to your liking.
All macros were copied from the Apple's headerdoc counterparts. I suggest you assign 
keyboard shortcuts to them since you'll be using them quite often (especially the method
one which automatically prepares the parameters and return doxygen commands based on the
selected source code).

The macros include template placeholders, so once you invoke them, you can use `CTRL+/` or 
`CTRL+SHIFT+/` (if you use default Xcode keyboard mapping) to jump between different
placeholders.

*Note that I've experienced problems with 0xFFFC characters appearing inside
the generated documentation. Although these are not visible, it still took a little while
until I found the source - Xcode user script templates placeholders. There's full of these
in the HeaderDoc macros which I used to prepare Doxygen ones. To see it in action, use the
arrow keys within the Xcode user scripts editor to navigate over the placeholders (try 
HeaderDoc method template). If you need to press left or right key multiple times in the 
beggining or end of the placeholder before the caret moves to the next char, that's it...*

*So either re-type (not copy/paste) the whole scripts again or edit the custom user scripts 
file found in the `~/Library/Application Support/Developer/Shared/Xcode/XCUserScripts.plist`
(open it with a text editor, not with Property List Editor), and change encodings to let's 
say Western ISO latin 1 - don't convert the file, only reinterpret it! Then the strange chars 
will pop up and you can easily delete them. After you're done, reinterpret the file back to 
UTF-8, save it and restart Xcode.*

For all macros use these options:

*	`Input` = `Selection`
*	`Directory` = `Home Directory`
*	`Output` = `Replace Selection`


### Insert class template ###

	#! /usr/bin/perl -w
	# Insert Doxygen template for class
	use strict;

	my $selection = <<'SELECTION';
	%%%{PBXSelectedText}%%%
	SELECTION
	chomp $selection;

	print "//////////////////////////////////////////////////////////////////////////////////////////\n";
	print "//////////////////////////////////////////////////////////////////////////////////////////\n";
	print "/** %%%{PBXSelection}%%%<#brief description#>%%%{PBXSelection}%%%\n";
	print "\n";
	print "<#full description#>\n";
	print "*/\n";
	print $selection;
	exit 0;


### Insert group template ###

	#! /usr/bin/perl -w
	# Insert Doxygen template for method group
	use strict;

	my $selection = <<'SELECTION';
	%%%{PBXSelectedText}%%%
	SELECTION
	chomp $selection;

	print "//////////////////////////////////////////////////////////////////////////////////////////\n";
	print "/// \@name ";
	if (length($selection)) {
		print $selection;
	}
	else {
		print "<#group description#>";
	}
	print "\n";
	print "//////////////////////////////////////////////////////////////////////////////////////////\n";

	exit 0;


### Insert method template ###

	#! /usr/bin/perl -w
	# 
	# Inserts a template Doxygen comment for an Objective-C method.
	# If the user selects a method declaration and
	# chooses this command, the template includes
	# the method name and the names of each parameter.
	# If the user doesn't select a declaration before issuing
	# this command, a default template is inserted.

	use strict;

	my $selection = <<'SELECTION';
	%%%{PBXSelectedText}%%%
	SELECTION
	chomp $selection;
	my $unmodifiedSelection = $selection; # used to retain linebreaks in output

	$selection =~ s/\n/ /sg;     # put on one line, if necessary
	$selection =~ s/\s+$//;      # remove any trailing spaces
	$selection =~ s/\s{2,}/ /g;  # regularize remaining spaces

	my $displayMethodName= '';
	my $returnsAValue= 0;
	my @params = ();

	# is it a method declaration that we understand?
	if (length($selection) && ($selection =~ /^[+-]/) && ($selection =~ /;$/)) {
		# determine if it returns a value
		$selection =~ m/[+-]\s+(\((.*?)\))?(.*);/;
		my $return = $2;
		my $fullMethodName = $3;
		if ((defined($return)) && ($return ne 'void') && ($return ne 'IBAction')) {$returnsAValue=1;};
		
		if (defined($fullMethodName)) {
			# get rid of type info for args
			$fullMethodName =~ s/\(.*?\)//g;
			
			if ($fullMethodName =~ /:/) {
				# get keyword:arg pairs
				my @keyArgPairs = split(/\s+/, $fullMethodName);
				
				foreach my $pair (@keyArgPairs) {
					if ($pair =~ /:/) { # don't treat parameters with spaces as method names
						my @parts = split(/:/, $pair);
						while (@parts) {
							$displayMethodName .= shift(@parts).":";
							push (@params, shift @parts);
						}
					} else {
						if (length($pair)) { # but do add them to the parameter list
						push (@params, $pair);
						}
					}
				}
			} else {
				$displayMethodName = $fullMethodName;
			}
		}
	}

	print "/** %%%{PBXSelection}%%%<#brief description#>%%%{PBXSelection}%%%￼\n";
	print "\n";
	print "<#full description#>\n";
	print "\n";

	foreach my $param (@params) {
		print "\@param $param <#parameter description#>\n" if (defined($param));
	}

	print "\@return <#result description#>\n" if ($returnsAValue);
	print "\@exception <#exception name and why#>\n";
	print "*/\n";
	print $unmodifiedSelection;

	exit 0;


LICENCE
=======

Copyright (c) 2009 Tomaz Kragelj

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

 
Tomaz Kragelj <tkragelj@gmail.com>
