Release Checklist
=================

All low level key components are covered with unit tests, however some higher level components aren't so make sure you check all following tests before releasing a version.

- Compile as release to fix missing @synthesize and similar.
- Make sure all unit tests pass.
- Validate all input paths are parsed.
- Create HTML and validate few pages to see it's ok.
- Create documention set and make sure no warning is emitted by appledoc.
- Install documentation set and make sure it's available in Xcode.
- Publish documentation set and make sure atom file is updated with new versions and xar file is generated.
- Update build number with `ruby ~/Dropbox/Scripts/Custom/git-version.rb` (copy result to GBAppledocStringsProvider's appledocData).

This should provide level of quality big enough to ensure the biggest bugs are caught.


Major classes and their roles
=============================

Main classes and top-down overview
----------------------------------

appledoc run session is managed through `GBAppledocApplication` Main responsibilities of the class are preparing settings for the session by combining factory defaults, global settings and command line switches and starting different generation phases, based on the settings: parsing source files, post processing and comments processing, generation of output files. Each phase relies on results of previous ones, so they need to be connected somehow. To avoid close coupling as well as allow additional phases in the future if need be, classes involved are not connected to each other. Instead a common class - `GBStore` is introduced. This class is a container of all information extracted from source files. Similarly, `GBApplicationSettingsProvider` contains all settings for the application. Both classes are passed around the rest of the application classes:

- `GBAppledocApplication`: Creates `GBApplicationSettingsProvider` with required settings, then creates `GBStore` instance. Then it invokes all phases handling classes as required.
- `GBParser`: Parses all source code and converts it to various objects which are then registered to `GBStore`. This is also where any static documentation that requires post-processing is searched for and registered to `GBStore`. After this class is done, store is ready for post processing. It includes all classes, categories, protocols and static documents together with their members, all represented as lists of objects in the store. Additionally, all comments are attached to the objects, but only as source strings at this point.
- `GBProcessor`: Post processes objects registered to `GBStore`. This phase requires all objects be registered to store so we can detect cross references and similar. This is where categories are merged to classes and all comments strings are converted into object representations among other things. Exact handling can be changed by various settings. The main responsibility of this phase is to prepare clean store, ready for output generation.
- `GBGenerator`: Uses all objects registered to `GBStore` to generate output as defined by settings.


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
