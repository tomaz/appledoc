----------
1. Purpose
----------

The main purpose of appledoc utility is to generate Apple like source code documentation. 
It uses doxygen for parsing the source files and creating intermediate XML files. These 
are then eventually converted to XHTML and optionally fully indexed and browsable 
documentation set. The utility can also install the documentation set into the Xcode 
documentation window. The whole process is wrapped into a single (and simple) command line.

The utility is based on Matt Ball's doxyclean Pyhton script. In fact, the whole idea
of using doxygen XML was developed from his utility. He was also kind enough for allowing
me to use his xslt and css files which do the hard work, so all credit goes to him. Check 
his work on http://github.com/mattball/doxyclean/.

You can find the latest appledoc build on http://github.com/tomaz/appledoc/.


---------------------
2. Command line usage
---------------------

USAGE: appledoc [options]

OPTIONS - required
-p --project <name>  The project name.
-i --input <path>    Source files path.
-o --output <path>   Path in which to create documentation.

OPTIONS - doxygen
-c --doxyfile <path> Name of the doxgen config file. Defaults to '<input>/Doxyfile'.
-d --doxygen <path>  Full path to doxgen command. Defaults to '/opt/local/bin/doxygen'.

OPTIONS - clean XML creation
   --no-empty-para   Do not delete empty paragraphs.
   --no-cat-merge    Do not merge category documentation to their classes.
   --keep-cat-sec    When merging category documentation preserve all category sections.
					 By default each category is merged into a since section within the class.

OPTIONS - clean HTML creation
   --no-xhtml        Don't create clean XHTML files (this will also disable DocSet!).

OPTIONS - documentation set
   --docid <id>      DocSet bundle id. Defaults to 'com.custom.<project>.docset'.
   --docfeed <name>  DocSet feed name. Defaults to 'Custom documentation'.
   --docplist <path> Full path to DocSet plist file. Defaults to '<input>/DocSet-Info.plist'.
   --docutil <path>  Full path to docsetutils. Defaults to '/Developer/usr/bin/docsetutils'.
   --no-docset       Don't create DocSet.

OPTIONS - miscellaneous
   --cleantemp       Remove all temporary build files. Note that this is dynamic and will
					 delete generated files based on what is build. If html is created, all
					 doxygen and clean xml is removed. If doc set is installed, the whole
					 output path is removed.
   --cleanbuild      Remove output files before build. This option should only be used if
					 output is generated in a separate directory. It will remove the whole
					 directory structure starting with the <output> path! BE CAREFUL!!!
					 Note that this option is automatically disabled if <output> and
					 <input> directories are the same.
-t --templates <path>Full path to template files. If not provided, templates are'.
					 searched in ~/.appledoc or ~/Library/Application Support/appledoc
					 directories in the given order. The templates path is also checked
					 for 'globals.plist' file that contains default global parameters.
					 Global parameters are overriden by command line arguments.
-v --verbose <level> The verbose level (1-4). Defaults to 0 (only errors).


-----------
3. Examples
-----------

The following command line is useful as the script within custom Xcode run script phase
in cases where the 'Place Build Products In' option is set to 'Customized location'.
It will create a directory named 'Help' alongside 'Debug' and 'Release' in the
specified custom location. Inside it will create a sub directory named after the
project name in which all documentation files will be created:
appledoc -p "$PROJECT_NAME" -i "$SRCROOT" -o "$BUILD_DIR/Help/$PROJECT_NAME" --cleanoutput

The followinfg command line is useful as the script within custom Xcode run script phase
in cases where the 'Place Build Products In' option is set to 'Project directory'.
It will create a directory named 'Help' inside the project source directory in
which all documentation files will be created:
appledoc -p "$PROJECT_NAME" -i "$SRCROOT" -o "$SRCROOT/Help" --cleanoutput

Note that in both examples --cleanoutput is used. It is safe to remove documentation.
files in these two cases since the --output path is different from source files.

Note that doxygen parsing and documentation set indexing may take quite some time,
especially on large projects, so you may prefer to create a special shell script build
target which you can use to periodically update the documentation. Or you can create
several targets for updating xhtml and docset separately depending on your preference.


----------------------------
4. Xcode doxygen integration
----------------------------

I'm using the following macros for automating doxygen code documentation for objects. The
macros are suited to my documentation style, so feel free to update them to your liking.
All macros were copied from the Apple's headerdoc counterparts. I include the macros under
Doxygen menu (alongside Headerdoc and the rest under the scripts menu). I suggest you
assign keyboard shortcuts to them since you'll be using them quite often.

The macros include template placeholders, so once you invoke them, you can use CTRL+/ or 
CTRL+SHIFT+/ (if you use default Xcode keyboard mapping) to jump between different
placeholders.

For all macros use these options:
Input = Selection
Directory = Home Directory
Output = Replace Selection

4.1 "Insert class template"
#! /usr/bin/perl -w
# Insert Doxygen template for class
use strict;

my $selection = <<'SELECTION';
%%%{PBXSelectedText}%%%
SELECTION
chomp $selection;

print "//////////////////////////////////////////////////////////////////////////////////////////\n";
print "//////////////////////////////////////////////////////////////////////////////////////////\n";
print "/** %%%{PBXSelection}%%%<#brief description#>￼￼￼%%%{PBXSelection}%%%\n";
print "\n";
print "￼￼<#full description#>\n";
print "*/\n";
print $selection;
exit 0;

4.2 "Insert group template"
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
	print "￼<#group description#>";
}
print "\n";
print "//////////////////////////////////////////////////////////////////////////////////////////\n";

exit 0;

4.3 "Insert method template"
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

print "/** %%%{PBXSelection}%%%￼<#brief description#>%%%{PBXSelection}%%%￼\n";
print "\n";
print "<#full description#>\n";
print "\n";

foreach my $param (@params) {
	print "\@param $param ￼￼￼￼￼￼<#parameter description#>\n" if (defined($param));
}

print "\@return ￼￼￼￼<#result description#>\n" if ($returnsAValue);
print "\@exception ￼￼￼￼￼<#exception name and why#>\n";
print "*/\n";
print $unmodifiedSelection;

exit 0;


----------
5. LICENCE
----------

Copyright (c) 2009 Tomaz Kragelj.

The appledoc software and associated documentation (from now, the “Software”) is freeware. 
You may use, copy, modify and/or merge copies of the Software free of charge in 
non-commercial solutions. The redistribution of this Software as part of or merged in 
commercial solutions is forbidden without prior authorization of the author. However, 
any output from the original or modified Software, may be used in any kind of project 
without any restrictions.

The Software and the accompanying documentation are provided “AS IS” without warranty 
of any kind. IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, 
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE 
USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE AUTHOR(S) HAVE BEEN ADVISED OF 
THE POSSIBILITY OF SUCH DAMAGE. The entire risk as to the results and performance of this 
software is assumed by you. If the software is defective, you, and not the author, assume 
the entire cost of all necessary servicing, repairs and corrections. If you do not agree 
to these terms and conditions, you may not install or use this software.

Tomaz Kragelj <tkragelj@gmail.com>
