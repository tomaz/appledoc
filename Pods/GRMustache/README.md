GRMustache
==========

GRMustache is a flexible and production-ready implementation of [Mustache templates](http://mustache.github.io/) for MacOS Cocoa and iOS.

**March 25, 2014: GRMustache 7.0.2 is out.** [Release notes](RELEASE_NOTES.md)

**System requirements**: GRMustache targets iOS down to version 4.3, MacOS down to 10.6 Snow Leopard (without garbage collection), and only depends on the Foundation framework.

Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).


How To
------

### 1. Setup your Xcode project

You have three options, from the simplest to the hairiest:

- [CocoaPods](Guides/installation.md#option-1-cocoapods)
- [Static Library](Guides/installation.md#option-2-static-library)
- [Compile the raw sources](Guides/installation.md#option-3-compiling-the-raw-sources)


### 2. Start rendering templates

```objc
#import "GRMustache.h"
```

One-liners:

```objc
// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" } fromString:@"Hello {{name}}!" error:NULL];
```

```objc
// Renders the `Profile.mustache` resource of the main bundle
NSString *rendering = [GRMustacheTemplate renderObject:user fromResource:@"Profile" bundle:nil error:NULL];
```

Reuse templates in order to avoid parsing the same template several times:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:nil];
rendering = [template renderObject:arthur error:NULL];
rendering = [template renderObject:barbara error:NULL];
rendering = ...
```

[GRMustachio](https://github.com/mugginsoft/GRMustachio) by Jonathan Mitchell is "A super simple, interactive GRMustache based application". It can help you design and test your templates.


Documentation
-------------

If you don't know Mustache, start here: http://mustache.github.io/mustache.5.html

- [Guides](Guides/README.md): a guided tour of GRMustache
- [Reference](http://groue.github.io/GRMustache/Reference/): all classes & protocols
- [Troubleshooting](Guides/troubleshooting.md)
- [FAQ](Guides/faq.md)


License
-------

Released under the [MIT License](LICENSE).
