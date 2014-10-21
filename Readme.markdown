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


Minimum system requirements
---------------------------

- Xcode 6.1+ for compiling
- OS X 10.9+ for compiling and running


License
=======

Copyright (c) 2009-2014, Gentle Bytes
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
