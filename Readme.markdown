About appledoc
==============

appledoc is command line tool that helps Objective-C developers generate Apple-like source code documentation from specially formatted source code comments. It's designed to take as readable source code comments as possible for the input and use comments as well as surrounding source code to generate visually appealing documentation in the form of HTML as well as fully indexed and browsable Xcode documentation set. Although there are several tools that can create HTML documentation for Objective-C, all of those know to me fall short in meeting the minimum of goals described below.

Main goals of appledoc:

- Human-readable source code comments.
- Simple cross references to objects and members.
- Generate Apple-like source code HTML documentation.
- Generate and install fully indexed and browsable Xcode documentation set.
- Single tool to drive generation from source code parsing to documentation set installation.
- Easily customizable output.
- 100% Objective-C implementation for easy debugging.

To make your experience with appledoc as smooth as possible, we warmly suggest reading this whole document as well as all online documentation mentioned in "using appledoc" section below!

Usage of appledoc is allowed under the terms listed in LICENSE section at the bottom of this file!

Want to keep updated? Follow us on Twitter - [@gentlebytes](http://twitter.com/gentlebytes).


Quick install
=============

The recommended way is to clone GitHub project and compile the tool from Xcode. As cloning GitHub project will create the link to the main repository, it greatly simplifies future upgrading too. To install, type the following in the Terminal:

	git clone git://github.com/tomaz/appledoc.git

This creates appledoc directory. Within you can find appledoc.xcodeproj Xcode project; open it and compile appledoc target - this should work out of the box, however your system must meet minimum system requirements, see below. I recommend you copy resulting appledoc executable from build directory to one of the directories in your path (`echo $PATH`) to make it easily accessible.

Optional:
Appledoc is selfcontained and contains the necessary template files. IF you want to modify these default  from Templates subdirectory to one of the expected locations:

- ~/Library/Application Support/appledoc
- ~/.appledoc

You can also use install-appledoc.sh script to perform quick installation. Open Terminal and switch to appledoc directory. Type following command:

	sudo sh install-appledoc.sh (if you need templates add '-t default')

It compiles appledoc and installs its binary to /usr/local/bin and templates (if wanted) to ~/.appledoc by default. You can override this directories with -b and -t options respectively. For example:

	sudo sh install-appledoc.sh -b /usr/bin -t ~/Library/Application\ Support/appledoc
	
**Alternatively with Homebrew:**

    brew install appledoc

Homebrew does not install templates by default.

Using appledoc
==============

Use `appledoc --help` to see the list of all command line switches. Read more about appledoc on [appledoc site](http://gentlebytes.com/appledoc). Also read [wiki pages](https://github.com/tomaz/appledoc/wiki/index) for some more in-depth articles.

Use [appledoc Google group](https://groups.google.com/forum/#!forum/appledoc) as a forum for questions on usage or other general questions.

Use [appledoc issues page](https://github.com/tomaz/appledoc/issues) to submit bug and feature requests. Before submitting new issues, check the forums to see if your question is answered there - unless you can confirm your issue as a new feature request or a bug, you should start at the forum to keep GitHub issues clean. Also read through issues to see if the issue is already there and vote on it or add a comment (don't forget about closed issues).

Installation tips
-----------------

To keep up to date, just go to Terminal and cd into appledoc directory, issue `git pull` and recompile appledoc.xcodeproj. Don't forget to overwrite appledoc executable you've copied to $PATH :)

If you also want to compile and run AppledocTests (unit tests) target, you need to copy all the frameworks indicated within Libraries & Frameworks group to shared frameworks directory before building unit tests target! This is not required for building the appledoc tool itself.

Integrating with Xcode
-----------------

You can setup Xcode to automate appledoc document creation. [Find out how](https://github.com/tomaz/appledoc/blob/master/XcodeIntegrationScript.markdown) using a Run Script and your project's Build Phases.

Docset usage tips
-----------------

Pre-generated documentation and docsets for most Cocoa frameworks are available at:  
- [CocoaDocs](http://cocoadocs.org)

Once you have a docset, you might want to use it with a documentation browser:  
- [Xcode](https://developer.apple.com/xcode/)  
- [Dash](http://kapeli.com/dash)

Troubleshooting
---------------

Have problems? This is what you can do to troubleshoot:

1. Make sure you have the latest appledoc version. Try `git pull` and run with latest version again.
2. IF you have template files installed, make sure you're using the latest - delete the predefined folders and have appledoc copy the files from its embedded archive again (see Quick Install section above).
3. Increase verbosity level with `--verbose` command line switch. Default level is 2, but you can progressively increment verbosity up to 6 with each level giving you more detailed information. As this will give you a lot more information, you may want to concentrate only on specific set of source files you have problem with. Note that increasing verbosity will result in slower performance so using levels above 4 for every day use is not recommended.
4. Appledoc is open source project! You have all the source code available, so run it from Xcode. You can setup Xcode to pass the desired command line arguments and add breakpoints to help you isolate your issue. If you feel you'd like to contribute more to community, you are welcome to fork the project on GitHub and add features to it. Keep us posted so we can add these features to main repository as well - include unit tests if possible.
5. If you think you found a bug or want to request new feature, go to [appledoc issues page](https://github.com/tomaz/appledoc/issues). First read existing issues to see if there is already a request there (if you're using master branch, also read closed issues as your request may have already been covered but isn't yet merged on master branch). You can vote on existing requests to help us decide which features to concetrate on or you can add a comment to aid in solving it. If you don't find the request there, create a new issue; include parts of source files that give you problems if possible and/or description or steps that lead to it.
6. If you're having problems with some of your source files and don't want to publish them online, you can contact us through email below. We'll do our best to help you out, but bear in mind appledoc is not commercial product; it's created and maintaned in our spare time, so resources are limited.


Developer notes
---------------

If you wish to contribute, see the [Developer Notes file](https://github.com/tomaz/appledoc/blob/master/Developer%20Notes.markdown) for short overview of how appledoc works internally.


Minimum system requirements
---------------------------

- Xcode 4.5 or greater for compiling
- OS X 10.7 for compiling and running

License
=======

appledoc is licensed with modified BSD license. In plain language: you're allowed to do whatever you wish with the code, modify, redistribute, embed in your products (free or commercial), but you must include copyright, terms of usage and disclaimer as stated in the license, the same way as any other BSD licensed code. You can of course use documentation generated by appledoc for your products (free or commercial), but you must attribute appledoc either in documentation itself or other appropriate place such as your website.

If for whatever reason you cannot agree to these terms, contact us through contact form on [our about page](http://gentlebytes.com/about), we'll do our best to help you out you out and find a workable solution!


Copyright (c) 2009-2011, Gentle Bytes
All rights reserved.

Redistribution and use in source, binary forms and generated documentation, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

- Redistributions of documentation generated by appledoc must include attribution to appledoc, either in documentation itself or other appropriate media.

- Neither the name of the appledoc, Gentle Bytes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Gentle Bytes appledoc@gentlebytes.com
