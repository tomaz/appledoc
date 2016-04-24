# GHUnit [![Build Status](https://travis-ci.org/gh-unit/gh-unit.png)](https://travis-ci.org/gh-unit/gh-unit)

GHUnit is a test framework for Mac OS X and iOS.
It can be used standalone or with other testing frameworks like SenTestingKit or GTM.

## Moved repostitory
GH-Unit is moved from gabriel/gh-unit to gh-unit/gh-unit.

## Features

- Run tests, breakpoint and interact directly with the XCode Debugger.
- Run from the command line or via a Makefile.
- Run tests in parallel.
- Allow testing of UI components.
- Capture and display test metrics.
- Search and filter tests by keywords. 
- View logging by test case.
- Show stack traces and useful debugging information.
- Include as a framework in your projects
- Determine whether views have changed (UI verification)
- Quickly approve and record view changes
- View image diff to see where views have changed

## Install (Cocoapods)

Using [CocoaPods](http://cocoapods.org/):

### iOS
```
target :Testtarget do
	pod 'GHUnitIOS', '~> 0.5.7'`
end
```
### OSX
```
target :Testtarget do
	pod 'GHUnitOSX', '~> 0.5.7'`
end
```

## Install (From Source)
Checkout gh-unit.

### iOS
```bash
cd Project-iOS && make
```

Add the `GHUnitIOS.framework` to your project

### OS X
```bash
cd Project-MacOSX && make
```
Add the `GHUnit.framework` to your project

## Documentation

- [How to install, create and run tests](http://gh-unit.github.io//gh-unit/docs/index.html)
- [Online documentation](http://gh-unit.github.io/gh-unit/)
- [Google Group (Deprecated - Use Github Issues instead)](http://groups.google.com/group/ghunit)

## Install (Docset)

- Open Xcode, Preferences and select the Documentation tab.
- Select the plus icon (bottom left) and specify: `http://gh-unit.github.io/gh-unit/publish/me.rel.GHUnit.atom`


## Mac OS X

![GHUnit-0.4.18](http://rel.me.s3.amazonaws.com/images/GHUnit-0.4.18.png)

## iOS

![GHUnit-IPhone-0.4.18](http://rel.me.s3.amazonaws.com/images/GHUnit-IPhone-0.4.18.png)

![GHUnit-IPhone-0.4.34](https://johnboiles.s3.amazonaws.com/ghunittestview.png)

![GHUnit-IPhone-0.4.34](https://johnboiles.s3.amazonaws.com/ghunitnewimage.png)

![GHUnit-IPhone-0.4.34](https://johnboiles.s3.amazonaws.com/ghunitdiff.png)
