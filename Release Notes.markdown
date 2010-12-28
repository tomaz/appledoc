What's new
==========

2.0b3
-----

- Bug fix release for documentation set.


2.0b2
-----

- Appledoc version is included in HTML footer.
- Method result can also be specified with @returns.
- Cross reference to index and hierarchy pages.
- Class hierarchy output.
- Clean HTML output.
- Minor fixed and refactorings.


2.0b1
-----

- Custom source code and comments parsing instead of doxygen.
- Embedded template builder instead of XSLT.
- Complete rewrite.




Release Checklist
=================

All low level key components are covered with unit tests, however some higher level components aren't so make sure you check all following tests before releasing a version.

- Make sure all unit tests pass.
- Validate all input paths are parsed.
- Create HTML and validate few pages to see it's ok.
- Create documention set and make sure no warning is emitted by appledoc.
- Install documentation set and make sure it's available in Xcode.

This should provide level of quality big enough to ensure the biggest bugs are caught.


Components covered in unit tests
================================

Model group
-----------

All major components are under unit tests:

- GBStore class
- GBClassData class
- GBCategoryData class
- GBProtocolData class
- GBIvarData class
- GBMethodData class
- GBModelBase class
- GBAdoptedProtocolsProvider class
- GBIvarsProvider class
- GBMethodsProvider class
- GBComment class
- GBParagraphItems class

Not tested: helper/trivial classes, however these are briefly covered by other unit tests, most often from processing group.


Parsing group
-------------

All major components are under unit tests:

- GBTokenizer class
- GBObjectiveCParser class

Not tested: GBParser that parses command line arguments and invokes source code and comments parsing. However this is trivial and should be easily verified manually.


Processing group
----------------

All major components are under unit tests:

- GBProcessor
- GBCommentsProcessor


Generating group
----------------

Only lower level generating components are under unit tests:

- GBTemplateHandler
- GBTemplateVariablesProvider

As this is where parsed data is converted to output, this layer relies heavily on file system. Although it would be possible to unit test it, it seems like too much effort for too little gain IMHO, so only lower level building blocks are tested. This part requires most manual testing.
