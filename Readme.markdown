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


Quick install
=============

The recommended way is to clone GitHub project and compile the tool from Xcode. As cloning GitHub project will create the link to the main repository, it greatly simplifies future upgrading too. To install, type the following in the Terminal:

	git clone git://github.com/tomaz/appledoc.git

This creates appledoc directory. Within you can find appledoc.xcodeproj Xcode project; open it and compile appledoc target - this should work out of the box, however your system must meet minimum system requirements, see below. I recommend you copy resulting appledoc executable from build directory to one of the directories in your path (`echo $PATH`) to make it easily accessible.

Before running the tool, you need to copy all required template files from Templates subdirectory to one of the expected locations:

- ~/Library/Application Support/appledoc
- ~/.appledoc


Using appledoc
==============

Use `appledoc --help` to see the list of all command line switches. Read more about appledoc on [appledoc site](http://appledoc.gentlebytes.com) and check short help, documentation and tips on [appledoc's GitHub page](http://tomaz.github.com/appledoc/). Use [appledoc issues page](https://github.com/tomaz/appledoc/issues) to submit bug and feature requests. Before submitting read through open issues to see if the issue is already there and vote on it or add a comment. If you're not using development branch (see installation tips below) also check closed issues as your request may have already been covered but is not yet on master branch!

Installation tips
-----------------

To keep up to date, just go to Terminal and cd into appledoc directory, issue `git pull` and recompile appledoc.xcodeproj. Don't forget to overwrite appledoc executable you've copied to $PATH :)

If you've used installation procedure described above in "quick install" section, you're using appledoc on it's master branch. This gives you most stable version available, however it doesn't include all the latest bug fixes and updates. In fact, all of the work on appledoc happens on development branch and is then merged to master branch from time to time. If you'd like to be updated as frequently as possible, you can switch to development branch. We keep this branch very stable too, so you should be fine using it. Switching to development branch only requires one additional step after cloning (this guide includes clone command, if you've already cloned appledoc, skip the first one):

	git clone git://github.com/tomaz/appledoc.git
	cd appledoc
	git checkout --track origin/development

You have now switched to development branch, which you can confirm by running `git branch`. You can update using the same method described above (i.e. `git pull`).

If you also want to compile and run AppledocTests (unit tests) target, you need to copy all the frameworks indicated within Libraries & Frameworks group to shared frameworks directory before building unit tests target! This is not required for building the appledoc tool itself.

Troubleshooting
---------------

Have problems? This is what you can do to troubleshoot:

1. Make sure you have the latest appledoc version, prefferably on development branch. Try `git pull` and run with latest version again. If you're working with master branch, use instructions above to switch to development branch and see if it fixes your issue.
2. Increase verbosity level with `--verbose 3` command line switch. You can progressively increment verbosity up to 6 with each level giving you more detailed information. As this will give you a lot more information, you may want to concentrate only on specific set of source files you have problem with. Note that increasing verbosity will result in slower performance so using levels above 4 for every day use is not recommended.
3. Appledoc is open source project! You have all the source code available, so run it from Xcode. You can setup Xcode to pass the desired command line arguments and add breakpoints to help you isolate your issue. If you feel you'd like to contribute more to community, you are welcome to fork the project on GitHub and add features to it. Keep us posted so we can add these features to main repository as well - include unit tests if possible.
4. If you think you found a bug or want to request new feature, go to [appledoc issues page](https://github.com/tomaz/appledoc/issues). First read existing issues to see if there is already a request there (if you're using master branch, also read closed issues as your request may have already been covered but isn't yet merged on master branch). You can vote on existing requests to help us decide which features to concetrate on or you can add a comment to aid in solving it. If you don't find the request there, create a new issue; include parts of source files that give you problems if possible and/or description or steps that lead to it.
5. If you're having problems with some of your source files and don't want to publish them online, you can contact us through email below. We'll do our best to help you out, but bear in mind appledoc is not commercial product; it's created and maintaned in our spare time, so resources are limited.

Minimum system requirements
---------------------------

- Xcode 3.2 or greater for compiling
- OS X 10.6 for running


LICENCE
=======

appledoc is licenced with MIT licence as stated below. Basically you can use it whatever way you wish, including in commercial projects. Although you don't have to, we'd appreciate you link back to us from your product or web page/blog:

Copyright (c) 2009-2010 Gentle Bytes

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Gentle Bytes appledoc@gentlebytes.com