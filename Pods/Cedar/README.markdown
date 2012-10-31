# Cedar

BDD-style testing using Objective-C


## Usage


### Clone from GitHub

* Don't forget to initialize submodules:

        $ git submodule update --init


### Installation

* Run the `installCodeSnippetsAndTemplates` script in the Cedar directory.

        $ ./installCodeSnippetsAndTemplates


### Non-iOS testing

* Select your project in Xcode to bring up the project editor.
* Click on "Add Target".
* Select "Cedar" under the Mac section.
* Select either an OSX Cedar Testing Bundle or a OSX Cedar Spec Suite.  If you
  prefer to run a separate target to see your spec results, choose the
  spec suite.  If you prefer to run your specs with Xcode's built-in
  OCUnit runner, choose the testing bundle.  Name this target Specs, or something
  else suitable.
* If you're using ARC there are some caveats with using Cedar matchers, see below under "Matchers and ARC".
* If you created a spec bundle, you must additionally add it to the list of tests
  for the intended target:
  * Select the target you want the tests to run against.
  * Edit the scheme (Cmd-<)
  * Select Test and then add your spec bundle to the list of tests
* You target is now set up and should include an ExampleSpec.mm.  To run it:
  * Spec bundle: Choose Test (Cmd-U) for the target you want to run tests for.
  * Spec suite: Select your spec suite target and Run/Debug.



### iOS testing

* Select your project in Xcode to bring up the project editor.
* Click on "Add Target".
* Select "Cedar" under the iOS section.
* Select either an iOS Cedar Testing Bundle or a iOS Cedar Spec Suite.  If you
  prefer to run a separate target to see your spec results, choose the
  spec suite.  If you prefer to run your specs with Xcode's built-in
  OCUnit runner, choose the testing bundle.  Name this target Specs, or something
  else suitable.
* If you're using ARC there are some caveats with using Cedar matchers, see below under "Matchers and ARC".
* If you're creating a spec bundle, you must specify the intended target of your tests
  when creating it in the Test Target field.  Additionally, once you have created your
  spec bundle target, you must then add it to the list of tests for the test target:
  * Select the test target.
  * Edit the scheme (Cmd-<)
  * Select Test and then add your spec bundle to the list of tests.
* Your target is now set up and should include an ExampleSpec.mm.  To run it:
  * Spec bundle: Choose Test (Cmd-U) for the target you want to run tests for.
  * Spec suite: Select your spec suite target and Run/Debug.

#### Running iOS tests suites in headless mode

* By default, when you run an iOS test suite target, the results are displayed in a UITableView
  in the simulator.  If you prefer to have the results output to the console instead, just add
  the `CEDAR_HEADLESS_SPECS` to the environment of the spec suite target:
  * Select the spec suite target
  * Edit the scheme (Cmd-<)
  * Select Run > Arguments
  * Add `CEDAR_HEADLESS_SPECS` to the Environment section.


## Matchers

Cedar has a new set of matchers that use C++ templates to circumvent type issues that plague other
matcher libraries.  For example, rather than this (OCHamcrest):

    assertThat(aString, equalTo(@"something"));
    assertThatInt(anInteger, equalToInt(7));
    assertThatInt(anInteger, isNot(equalToInt(9)));
    assertThatBool(aBoolean, equalTo(YES));

you can write the following:

    expect(aString).to(equal(@"something"));
    expect(anInteger).to(equal(7));
    expect(anInteger).to_not(equal(9));
    expect(aBoolean).to(equal(YES));

although you would more likely write the last line as:

    expect(aBoolean).to(be_truthy());

Here is a list of built-in matchers you can use:

    expect(...).to(be_nil());

    expect(...).to(be_truthy());
    expect(...).to_not(be_truthy());

    expect(...).to(equal(10));
    expect(...).to == 10; // shortcut to the above
    expect(...) == 10; // shortcut to the above

    expect(...).to(be_greater_than(5));
    expect(...).to > 5; // shortcut to the above
    expect(...) > 5; // shortcut to the above

    expect(...).to(be_greater_than_or_equal_to(10));
    expect(...).to(be_gte(10)); // shortcut to the above
    expect(...).to >= 10; // shortcut to the above
    expect(...) >= 10; // shortcut to the above

    expect(...).to(be_less_than(11));
    expect(...).to < 11; // shortcut to the above
    expect(...) < 11; // shortcut to the above

    expect(...).to(be_less_than_or_equal_to(10));
    expect(...).to(be_lte(10)); //shortcut to the above
    expect(...).to <= 10; // shortcut to the above
    expect(...) <= 10; // shortcut to the above

    expect(...).to(be_close_to(5)); // default within(.01)
    expect(...).to(be_close_to(5).within(.02));

    expect(...).to(be_instance_of([NSObject class]));
    expect(...).to(be_instance_of([NSObject class]).or_any_subclass());

    expect(...).to(be_same_instance_as(object));

    expect(...).to(contain(@"something"));
    expect(...).to(be_empty());

    expect(^{ ... }).to(raise_exception([NSInternalInconsistencyException class]));

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

### Matchers and ARC

A bug in the current Xcode compiler currently prevents the type C++ deduction from actually working if you have automatic reference counting enabled.  At this time, this leaves you with a few alternatives:

1. Disable ARC for your spec files, but continue to use it for your application code.  You can do this by selecting spec files in the target's "Compile Sources" build phase and adding the compiler flag `-fno-objc-arc`.  You can help ensure that you do this by creating a `SpecHelper.h` file in your spec target that you `#import` into every spec which contains this guard:

        #if __has_feature(objc_arc)
            #error ARC must be disabled for specs!
        #endif

2. Use another matcher library like [Expecta](http://github.com/petejkim/expecta).  Just remove the following line from your spec files:


        using namespace Cedar::Matchers;


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

Doubles.  Got 'em.

    spy_on(someInstance);
    id<CedarDouble> fake = fake_for(someClass);
    id<CedarDouble> anotherFake = fake_for(someProtocol);
    id<CedarDouble> niceFake = nice_fake_for(someClass);
    id<CedarDouble> anotherNiceFake = nice_fake_for(someProtocol);

Method stubbing:

    fake stub_method("selector").with(x);
    fake stub_method("selector").with(x).and_with(y);
    fake stub_method("selector").and_return(z);
    fake stub_method("selector").with(x).and_return(z);
    fake stub_method("selector").and_raise_exception();
    fake stub_method("selector").and_raise_exception([NSException]);
    fake stub_method("selector").with(anything);

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
subset of your tests.  That can be achieved by marking any number of examples
with an 'f'. You can use `fit`, `fdescribe` and `fcontext` like this:

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

Note: For improved Xcode integration see
[CedarShortcuts](https://github.com/cppforlife/CedarShortcuts), an Xcode plugin
that provides keyboard shortcuts for focusing on specs under editor cursor.


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

### Finding Slow-Running Tests

Set the `CEDAR_REPORT_SLOW_TESTS` environment vairables to have Cedar identify
and prints out the slowest `N` (10 by default) tests in your suite, and the
slowest `N` top-level groups. These top-level groups typically have a one to one
correspondence with your spec files allowing you to easily identify the slowest
running slow files. You can change `N` by setting the `CEDAR_TOP_N_SLOW_TESTS`
env variable.

### Faster Failure Reporting

Set the `CEDAR_REPORT_FAILURES_IMMEDIATELY` environment variable to have Cedar
print failure details before finishing running all tests.

### JUnit XML Reporting

The `CDRJUnitXMLReporter` can be used to generate (simple) JUnit compatible
XML that can be read by build servers such as Jenkins. To use this reporter,
you can take advantage of the ability to specify multiple reporters like so:

    CEDAR_REPORTER_CLASS=CDRColorizedReporter,CDRJUnitXMLReporter

By default, the XML file will be written to `build/TEST-Cedar.xml` but this
path can be overridden with the `CEDAR_JUNIT_XML_FILE` env variable.


## Code Snippets

Code snippets are installed as part of Cedar.  These are installed into
`~/Library/Developer/XCode/UserData/CodeSnippets`


## Command line automation

The Rakefile contains useful rake tasks that let you run cedar specs from the
command line.  The `ocunit:logic` and `ocunit:application` tasks demonstrate how
you can run OCUnit style test bundles.  The `specs` and `uispecs` tasks show how
you can run cedar test suites.


## Troubleshooting

### Linker problem ld: file not found
Example failure:

    ld: file not found: <path to build dir>/Products/<Configuration>-<device>/<target name>.app/<target name>
    clang: error: linker command failed with exit code 1 (use -v to see invocation)

  * This error occurs when there is an incorrect target name used.
  * To fix this, Update the `Bundle Loader` setting in build settings to
  `$(BUILT_PRODUCTS_DIR)/<target name>.app/<target name>`
  Ensuring that your new target name is the correct.

### Linker problem ld: symbol(s) not found
Example failure:

    Undefined symbols for architecture i386:
    "_OBJC_CLASS_$_SomeClassFromYourApp", referenced from:
        objc-class-ref in SomeClassFromYourAppSpec.o
        (maybe you meant: _OBJC_CLASS_$__OBJC_CLASS_$_SomeClassFromYourApp)
    ld: symbol(s) not found for architecture i386

This error can happen when you have a spec bundle which is run against code built with "Strip Debug Symbols During Copy" set to Yes.

You should ensure that you're running your tests against code built with this configuration setting set to No.  This should be the default if you're building with the Debug configuration.

### No matching function to call
Example failure:

    error: no matching function for call to 'CDR_expect'
    note: candidate template ignored: substitution failure [with T = SOME_TYPE]

  * This is caused by a C++ compiler bug in Xcode when ARC is enabled and you use a Cedar matcher.  See the above section "Matchers and ARC" on how to deal with this.


## Contributions and feedback

Welcomed!  Feel free to join and contribute to the public Tracker project [here](http://www.pivotaltracker.com/projects/77775).

The [public Google group](http://groups.google.com/group/cedar-discuss) for Cedar is cedar-discuss@googlegroups.com.
Or, you can follow the growth of Cedar on Twitter: [@cedarbdd](http://twitter.com/cedarbdd).

Copyright (c) 2011 Pivotal Labs. This software is licensed under the MIT License.
