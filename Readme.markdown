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


Installation
============

The recommended way is to clone GitHub project and compile the tool from Xcode. As cloning GitHub project will create the link to the main repository, it greatly simplifies future upgrading. To install, type the following in the Terminal:

	git clone git://github.com/tomaz/appledoc.git

This creates appledoc directory. Within you can find appledoc.xcodeproj Xcode project; open it and compile appledoc target - this should work out of the box, however your system must meet minimum system requirements, see below. I recommend you copy resulting appledoc executable from build directory to one of the directories in your path (`echo $PATH`) to make it easily accessible. Before running the tool, you need to copy all required template files from Templates subdirectory to one of the expected locations:

- ~/Library/Application Support/appledoc
- ~/.appledoc

If you also want to compile and run AppledocTests (unit tests) target, you need to copy all the frameworks indicated within Libraries & Frameworks group to shared frameworks directory before building! This is not required for building the appledoc tool itself.

Minimum system requirements:

- Xcode 3.2 or greater for compiling
- OS X 10.6 for running


Using appledoc
==============

Work in progress... Use `appledoc --help` to see the list of all commands.


LICENCE
=======

appledoc is licenced with MIT licence as stated below:

Copyright (c) 2009-2010 Tomaz Kragelj

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Tomaz Kragelj tkragelj@gmail.com