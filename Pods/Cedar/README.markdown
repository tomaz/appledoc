# Cedar

BDD-style testing using Objective-C


## Usage

### Clone from GitHub

* Don't forget to initialize submodules:

        $ git submodule update --init


### Non-iOS testing

* Build the Cedar framework.  Note that you must build for an Objective-C
  runtime that supports blocks; this means Mac OS X 10.6, or a runtime from
  Plausible Labs (see below).
* Create a command-line executable target for your tests in your project.  Name
  this target Specs, unless you have another name you'd prefer.
* Add the Cedar framework to your project, and link your Specs target with it.
* Do the Copy Framework Dance:
    - Add a Copy Files build phase to your Specs target.
    - Select the Frameworks destination for the build phase.
    - Add Cedar to the new build phase.
* Add a main.m to your Specs target that looks like this:

        #import <Cedar/Cedar.h>

        int main (int argc, const char *argv[]) {
          return runSpecs();
        }

* Write your specs.  Cedar provides the SpecHelper.h file with some minimal
  macros to remove as much distraction as possible from your specs.  A spec
  file need not have a header file, and looks like this:

        #import <Cedar/SpecHelper.h>

        SPEC_BEGIN(FooSpec)
        describe(@"Foo", ^{
          beforeEach(^{
            ...
          });

          it(@"should do something", ^{
            ...
          });
        });
        SPEC_END

* Build and run.  Note that, unlike OCUnit, you must run your executable in
  order to run your specs.  Also unlike OCUnit this allows you to use the
  debugger when running specs.

### iPhone testing

* Build the Cedar-iOS static framework.  This framework contains a universal
  binary that will work both on the simulator and the device.
  NOTE: due to a bug in the build process the script that builds the framework
  will sometimes not copy all of the header files appropriately.  If after you
  build the Headers directory under the built framework is empty, try deleting
  the built framework and building again.
* Create a Cocoa Touch "Application" target for your tests in your project.  Name
  this target UISpecs, or something similar.
* Open the Info.plist file for your project and remove the "Main nib file base
  name" entry.  The project template will likely have set this to "MainWindow."
* Add the Cedar-iOS static framework to your project, and link your UISpecs
  target with it.
* Add `-ObjC`, `-lstdc++` and `-all_load` to the Other Linker Flags build setting for the
  UISpecs target.  This is necessary for the linker to correctly load symbols
  for Objective-C classes from static libraries.
* Add a main.m to your UISpecs target that looks like this:

        #import <UIKit/UIKit.h>
        #import <Cedar-iOS/Cedar-iOS.h>

        int main(int argc, char *argv[]) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

            int retVal = UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
            [pool release];
            return retVal;
        }

* Build and run.  The simulator (or device) should start and display the status
  of each of your spec classes in a table view.  You can navigate the hierarchy
  of your examples by clicking on the table cells.
* If you would like to use OCHamcrest or OCMock in your UI specs, Pivotal has
  created static frameworks which will work on the iPhone for both.  These must
  be built so you can add them as available frameworks in your specs.  See the
  sections below on Matchers and Mocks for links to the relevant projects.
* If you would like to run specs both in your UI spec target and your non-UI
  spec target, you'll need to conditionally include the appropriate Cedar
  headers in your spec files depending on the target SDK.  For example:

        #if TARGET_OS_IPHONE
        #import <Cedar-iOS/SpecHelper.h>
        #else
        #import <Cedar/SpecHelper.h>
        #endif


## Matchers

Cedar has a new set of matchers that use C++ templates to circumvent type issues that plague other
matcher libraries.  For example, rather than this (OCHamcrest):

    assertThat(aString, equalTo(@"something"));
    assertThatInt(anInteger, equalToInt(7));
    assertThatBool(aBoolean, equalTo(YES));

you can write the following:

    expect(aString).to(equal(@"something"));
    expect(anInteger).to(equal(7));
    expect(aBoolean).to(equal(YES));

although you would more likely write the last line as:

    expect(aBoolean).to(be_truthy());

Here is a list of built-in matchers you can use:

    expect(...).to(equal(10));
    expect(...).to(be_nil());
    expect(...).to(be_close_to(5)); // default within(.01)
    expect(...).to(be_close_to(5).within(.02));
    expect(...).to(be_instance_of([NSObject class]));
    expect(...).to(be_same_instance_as(object));
    expect(...).to(be_truthy());
    expect(...).to_not(be_truthy());
    expect(...).to(contain(@"something"));
    expect(...).to(be_empty());

These matchers use C++ templates for type deduction.  You'll need to do two things to use them:

* Change the file extension for each of your spec files from .m to .mm (this will tell the
  compiler that the file contains C++ code).
* Add the following line to the top of your spec files, after the file includes:

        using namespace Cedar::Matchers;

It's also theoretically very easy to add your own matchers without modifying the
Cedar library (more on this later).

These matchers will break Apple's GCC compiler, and versions 2.0 and older of the LLVM compiler
(this translates to any compiler shipped with a version of Xcode before 4.1).  Fortunately, 
LLVM 2.1 fixes the issues.

Note: If you decide to use another matcher library that uses `expect(...)` to
build its expectations (e.g. [Expecta](http://github.com/petejkim/expecta)) you
will need to add `#define CEDAR_MATCHERS_COMPATIBILITY_MODE` before importing
SpecHelper.h.  That will prevent Cedar from defining a macro that overrides that
library's expect function.

Note: If you prefer RSpec's `should` syntax you can write your expectations as follows:

        1 + 2 should equal(3);
        glass should_not be_empty();


## Shared example groups

Cedar supports shared example groups; you can declare them in one of two ways:
either inline with your spec declarations, or separately.

Declaring shared examples inline with your specs is the simplest:

    SPEC_BEGIN(FooSpecs)

    sharedExamplesFor(@"a similarly-behaving thing", ^(NSDictionary *context) {
        it(@"should do something common", ^{
            ...
        });
    });

    describe(@"Something that shares behavior", ^{
        itShouldBehaveLike(@"a similarly-behaving thing");
    });

    describe(@"Something else that shares behavior", ^{
        itShouldBehaveLike(@"a similarly-behaving thing");
    });

    SPEC_END

Sometimes you'll want to put shared examples in a separate file so you can use
them in several specs across different files.  You can do this using macros
specifically for declaring shared example groups:

    SHARED_EXAMPLE_GROUPS_BEGIN(GloballyCommon)

    sharedExamplesFor(@"a thing with globally common behavior", ^(NSDictionary *context) {
        it(@"should do something really common", ^{
            ...
        });
    });

    SHARED_EXAMPLE_GROUPS_END

The context dictionary allows you to pass example-specific state into the shared
example group.  You can populate the context dictionary available on the SpecHelper
object, and each shared example group will receive it:

    sharedExamplesFor(@"a red thing", ^(NSDictionary *context) {
        it(@"should be red", ^{
            Thing *thing = [context objectForKey:@"thing"];
            expect(thing.color).to(equal(red));
        });
    });

    describe(@"A fire truck", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[FireTruck fireTruck] forKey:@"thing"];
        });
        itShouldBehaveLike(@"a red thing");
    });

    describe(@"An apple", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[Apple apple] forKey:@"thing"];
        });
        itShouldBehaveLike(@"a red thing");
    });


## Global beforeEach and afterEach

In many cases you have some housekeeping you'd like to take care of before every spec in your entire
suite.  For example, loading fixtures or resetting a global variable.  Cedar will look for the
+beforeEach and +afterEach class methods on every class it loads; you can add this class method
onto any class you compile into your specs and Cedar will run it.  This allows spec libraries to 
provide global +beforeEach and +afterEach methods specific to their own functionality, and they 
will run automatically.

If you want to run your own code before or after every spec, simply declare a class and implement 
the +beforeEach and/or +afterEach methods.


## Mocks and stubs

Cedar works fine with OCMock.  You can download and use the [OCMock framework](http://www.mulle-kybernetik.com/software/OCMock/).
Pivotal also has a fork of a [GitHub import of the OCMock codebase](http://github.com/pivotal/OCMock),
which contains our iPhone-specific static framework target.  Cedar also references
the Pivotal fork of OCMock as a submodule.


## Pending specs

If you'd like to specify but not implement an example you can do so like this:

          it(@"should do something eventually", PENDING);

The spec runner will not try to run this example, but report it as pending.  The
PENDING keyword simply references a nil block pointer; if you prefer you can
explicitly pass nil as the second parameter.  The parameter is necessary because
C, and thus Objective-C, doesn't support function parameter overloading or
default parameters.


## Focused specs

Sometimes when debugging or developing a new feature it is useful to run only a
subset of your tests.  That can be achieved by marking any number/combination of
examples with an 'f'. You can use `fit`, `fdescribe` and `fcontext` like this:

          fit(@"should do something eventually", ^{
              // ...
          });

If your test suite has at least one focused example, all focused examples will
run and non-focused examples will be skipped and reported as such (shown as '>'
in default reporter output).

It might not be immediately obvious why the test runner always returns a
non-zero exit code when a test suite contains at least one focused example. That
was done to make CI fail if someone accidently forgets to unfocus focused
examples before commiting and pushing.


## Reporters

When running in headless mode by default Cedar uses `CDRDefaultReporter` to
output test results.  Here is how it looks:

    .P..P..

    PENDING CDRExample hasChildren should return false by default
    PENDING CDRExample hasFocusedExamples should return false by default

    Finished in 0.0166 seconds
    7 examples, 0 failures, 2 pending

Most of the time above output is exactly what you want to see; however, in some
cases you might actually want to see full names of running examples.  You can get
more detailed output by setting `CEDAR_REPORTER_OPTS` env variable to `nested`.
Here is how it looks after that:

       CDRExample
         hasChildren
    .      should return false
         isFocused
    P      should return false by default
    .      should return false when example is not focused
    .      should return true when example is focused
         hasFocusedExamples
    P      should return false by default
    .      should return false when example is not focused
    .      should return true when example is focused

    PENDING CDRExample hasChildren should return false by default
    PENDING CDRExample hasFocusedExamples should return false by default

    Finished in 0.0173 seconds
    7 examples, 0 failures, 2 pending

If the default reporter for some reason does not fit your needs you can always
write a custom reporter.  `CDRTeamCityReporter` is one such example.  It was
written to output test results in a way that TeamCity CI server can understand. 
You can tell Cedar which reporter to use by setting `CEDAR_REPORTER_CLASS` env
variable to your custom reporter class name.

### JUnit XML Reporting

The `CDRJUnitXMLReporter` can be used to generate (simple) JUnit compatible
XML that can be read by build servers such as Jenkins. To use this reporter,
you can take advantage of the ability to specify multiple reporters like so:

    CEDAR_REPORTER_CLASS=CDRColorizedReporter,CDRJUnitXMLReporter

By default, the XML file will be written to `build/TEST-Cedar.xml` but this
path can be overridden with the `CEDAR_JUNIT_XML_FILE` env variable.


## OCUnit Support (new, not battle tested)

We encourage you to use Cedar without OCUnit as described in the 'Usage' section
above to avoid several OCUnit imposed limitations; however, if for some reason
you choose to use OCUnit, Cedar does support it.  You can find example
application that uses Cedar with OCUnit in OCUnitApp, OCUnitAppTests and
OCUnitAppLogicTests directories.  Also Rakefile contains two useful rake tasks
`ocunit:logic` and `ocunit:application` that let you run OCUnit tests from the
command line.


### OCUnit Logic Tests

* Create new "Cocoa Touch Unit Testing Bundle" target in your project.
  Name it LogicSpecs.
* Build the Cedar framework.
* Add the Cedar framework to your project, and link your LogicSpecs
  target with it.
* Add `-ObjC`, `-all_load` and `-lstdc++` to the Other Linker Flags build setting for the
  LogicSpecs target.
* Write your specs and include them in LogicSpecs target.  A spec file need not have
  a header file, and looks like this:

        #import <Cedar/SpecHelper.h>

        SPEC_BEGIN(FooSpec)
        describe(@"Foo", ^{
          beforeEach(^{
            ...
          });

          it(@"should do something", ^{
            ...
          });
        });
        SPEC_END

* Build LogicSpecs and run them in test mode (click and hold Run and select
  Test).  You should see specs result output in the console window.

In addition to running logic tests in Xcode you can also run them from the
command line.  To do so first copy Rakefile to your project and update
`PROJECT_NAME`, `APP_NAME` and `OCUNIT_LOGIC_SPECS_TARGET_NAME` constants in it.
 Run your tests with `rake ocunit:logic`.


### OCUnit Application Tests

* If you are creating new project just check "Include Unit Tests" option.  If
  you want to add application tests to an existing application here is a [good
  tutorial](http://twobitlabs.com/2011/06/adding-ocunit-to-an-existing-ios-project-with-xcode-4/).
  Name your target ApplicationSpecs (or if you used "Include Unit Tests"
  option Xcode will create target for you named [AppName]Tests.)
* Build the Cedar-iOS static framework.
* Add the Cedar-iOS static framework to your project, and link
  ApplicationSpecs target with it.
* Add `-ObjC`, `-all_load` and `-lstdc++` to the Other Linker Flags build setting for the
  ApplicationSpecs target.
* Write your specs and include them in ApplicationSpecs target.  A spec file
  need not have a header file, and looks like this:

        #import <Cedar/SpecHelper.h>

        SPEC_BEGIN(FooSpec)
        describe(@"Foo", ^{
          beforeEach(^{
            ...
          });

          it(@"should do something", ^{
            ...
          });
        });
        SPEC_END

* Build ApplicationSpecs and run them in test mode (click and hold Run and
  select Test).  You should see specs result output in the console window.

In addition to running application tests in Xcode you can also run them from the
command line.  To do so first copy Rakefile to your project and update
`PROJECT_NAME`, `APP_NAME` and `OCUNIT_APPLICATION_SPECS_TARGET_NAME` constants
in it.  Run your tests with `rake ocunit:application`.


## Code Snippets

Xcode 4 has replaced text macros with code snippets.  If you're still using Xcode 3,
check out the xcode3 branch from git and read the section on MACROS.

You can place the codesnippet files contained in CodeSnippets directory into this location
(you may need to create the directory):

        ~/Library/Developer/XCode/UserData/CodeSnippets

Alternately, you can run the installCodeSnippets script, which will do it for you. 


## Contributions and feedback

Welcomed!  Feel free to join and contribute to the public Tracker project [here](http://www.pivotaltracker.com/projects/77775).

The [public Google group](http://groups.google.com/group/cedar-discuss) for Cedar is cedar-discuss@googlegroups.com.
Or, you can follow the growth of Cedar on Twitter: [@cedarbdd](http://twitter.com/cedarbdd).

Copyright (c) 2011 Pivotal Labs. This software is licensed under the MIT License.
