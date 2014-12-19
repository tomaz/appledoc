#Appledoc comments formatting style

Appledoc extracts documentation from specially formatted comments, giving you freedom to choose which comments will be parsed and which not. To make porting old documentation simpler, it allows you to use either doxygen or headerdoc style comments.


## Multiple line comments:

Appledoc only handles multiple line comments if they start with slash and double star and end with standard star and slash:

```objc
/** Some comment */
```

Lines may optionally start with whitespace and a single star char and appledoc will ignore the prefix star, like this:

```objc
/** Star prefixed comment
 * spreading over multiple 
 * lines
 */
```
      
To make transition from headerdoc a bit simpler, appledoc also accepts headerdoc style multiline comments:

```objc
/*! Comment */
```

## Single line comments:

appledoc also handles single line comments that start with three slashes. Two or more single line comments in consecutive lines are grouped together into a single comment:

```objc
/// Single line comment spreading
/// over multiple lines
```

#Laying out comments

Appledoc has been designed to keep comments in source code as readable as possible. In order to achieve this, it uses [Markdown](http://daringfireball.net/projects/markdown/)-like syntax. Specifically, it uses [Discount](http://www.pell.portland.or.us/~orc/Code/discount/) library for processing Markdown, which supports a set of extensions to original Markdown; check the [link](http://www.pell.portland.or.us/~orc/Code/discount/) for more details. Furthermore, it extracts as much information from the comment surrounding context which allows you to focus on documenting entities, instead of polluting comments with tagging which class or method a comment belongs to.


##Paragraphs

Paragraphs are simply any number of consecutive rows of text separated by one or more empty (or tab and space only) lines:

```
First paragraph.
 
Second paragraph with lots of
text spread accross multiple lines.
 
And another paragraph.
```
    
The first paragraph of the comment is automatically used as short description and remaining as long description or discussion. You can change default behavior via command line switches.

##Unordered lists

Unordered lists use -, + or * markers in front of each item:

```
- First item.
- Second item with lot's of text
  spread across multiple lines.
- Third item.
```

The list must be delimited from surrounding paragraphs by empty lines at the top and bottom. You can nest lists by prefixing them with tabs or spaces like this:

```
- Item 1
  - Item 1.1
  - Item 1.2
	- Item 1.2.1
  - Item 1.3
- Item 2
```
    
Note that you can combine ordered and unordered lists when nesting.

##Ordered lists

Ordered lists use a number followed by a dot as a marker in front of each item:

```
1. First item
2. Second item
```

Numbers don't need to be consecutive, you can even use the same number for all items; appledoc will simply number the items by their order. All rules for unordered lists also apply for ordered lists: separation with empty lines, nesting etc., so it won't be repeated here.

##Examples and code blocks

If you want to mark a block of text as an example, simply prefix each line with a tab or 4 (or more) spaces. Appledoc will automatically convert consecutive blocks of prefixed lines into a single code block. Similar to lists and other paragraph blocks, example section needs to be delimited from preceding and following paragraph with an empty line:

```
Normal paragraph text
	 
	First line of example
	Second line of example
	 
Next paragraph.
```
	
##Important information blocks

You mark a paragraph as important by prefixing it's first line with @warning directive. For example, this is how you can achieve effect Apple uses for these blocks:

```
@warning *Important:* Sending this message before `readValues:fromFile:` will result in unpredicted results, most likely as runtime exception!
```

*Important*: All text after `@warning` directive, up to next `"@"` directive will become part of the block - currently it's not possible to terminate warning block manually and continue with normal paragraphs! This allows you nesting lists and multiple paragraphs, but may come as surprise when not expected. Therefore it's recommended to use warning blocks at the end of "normal" paragraphs (and as any "@" directive will end previous block or paragraph, you can put them above method directives). Something to keep in mind!

##Bug information blocks

If you'd like to make a paragraph even more emphasized than a `@warning`, you can use `@bug` directive. It works just like `@warning`, so see description there for details. Not so much used, but may come handy under certain circumstances.

#Formatting text

Appledoc has been designed to keep comments in source code as readable as possible. In order to achieve this, it uses [Markdown](http://daringfireball.net/projects/markdown/)-like syntax. Specifically, it uses [Discount](http://www.pell.portland.or.us/~orc/Code/discount/) library for processing Markdown, which supports a set of extensions to original Markdown; check the [link](http://www.pell.portland.or.us/~orc/Code/discount/) for more details. Furthermore, it extracts as much information from the comment surrounding context which allows you to focus on documenting entities, instead of polluting comments with tagging which class or method a comment belongs to.


##Emphasis

Text can be emphasized with the following syntax:

- Text wrapped within stars (\*text\*) becomes strong: *text*.

- Text wrapped within underscodes (\_text\_) becomes emphasized: _text_.

You can include the marker itself in the middle of the text, so this \*some * text\* is converted to: *some * text*. You can nest strong and emphasized formatting directives, so \_\*text\*\_ or \*\_text\_\* becomes emphasized strong text like this: *_text_*.

Note: you can also use standard Markdown formatting: \*\*text\*\* or \_\_text\_\_ for **bold** and \*\*\*text\*\*\* or \_\_\_text\_\_\_ for ***emphasized strong***.

##Code spans

As you're documenting source code, chance is you might want to format text as code. Any text wrapped within backtick quotes (\`text\`) is converted into `code span`. Note that you can't nest emphasis within code spans!

##Headers and the rest

Appledoc supports full Markdown, therefore you can include headers, line breaks, block quotes, horizontal rules etc. However, there's rarely a need for many of these features and using them may result in odd looking documentation. If you need any of these, go experiment and see if you like results or not.


#Links and cross references

You can easily link to any other documented entity or URL. Note that there are command line options that change how links are parsed, examples below assume you're using default settings.


##Links to web pages and other URLs

Any valid URL address starting with `http://`, `https://`, `ftp://`, `file://` or `mailto:` is automatically converted to a link in generated HTML.

##Links to classes, categories and protocols

Any word that matches known class, category or protocol name is automatically converted to cross reference link to that object. Assuming complete documentation contains class GBClass, it's extension GBClass(), category NSError(GBError) and protocol GBProtocol, the following text will automatically convert text:

```
This text contains links to: class GBClass, its extension GBClass(), 
category NSError(GBError) and protocol GBProtocol.
```
    
into something like:

This text contains links to: class [GBClass](http://), it's extension [GBClass()](http://), category [NSError(GBError)](http://) and protocol [GBProtocol](http://).

##Links to local members

Any word that matches method or property selector name of "current" class, category or protocol is automatically converted to cross reference link to that member. Assuming current object contains method runWithValue:afterDelay: and property value, the following text:

```
This text contains links to:
method runWithValue:afterDelay: and
property value.
```

will automatically convert to something like:

This text contains links to: method [runWithValue:afterDelay:](http://) and property [value](http://).

##Links to remote members

Creating cross reference links to members of other classes, categories or protocols requires a bit more effort as you need to state the class and the method, but still follows the same principle. Assuming complete documentation contains class GBClass which has method runWithValue:afterDelay: and property value, the following text:

```
This text contains links to:
method [GBClass runWithValue:afterDelay] and
property [GBClass value]
```

will convert to something like:

This text contains links to: method [[GBClass runWithValue:afterDelay:](http://)] and property [[GBClass value](http://)]

##Custom link descriptions

As appledoc parses Markdown links for known objects, you can take advantage of link descriptions and even reference-type links to add that fine touch to generated documentation. For example:

```
For more info check [this page](http://gentlebytes.com), 
also take a look at [this class](GBClass) 
and [this method]([GBClass method:]).

For referring to common object multiple times,
use this [class][1]. And [repeat again][1].

[1] GBClass
```
	
As long as `GBClass` and `[GBClass method:]` are recognized as valid cross references, the above example is converted to something like:

For more info check [this page](http://), also take a look at [this class](http://) and [this method](http://).

For referring to common object multiple times, use this [class](http://). And [repeat again](http://).


#Methods and properties description

For methods and properties you may want to document their parameters, results or exceptions they may raise. To do that, there are a number of "@" directives you can use:

- `@return <description>`: Provides the description of method or property result. Alternatives: `@returns` or `@result`.
- `@param <name> <description>`: Provides the description of method parameter with the given name. You need to provide description for each parameter or appledoc will log a warning (you can suppress these warnings through command line switch).
- `@exception <name> <description>`: Provides the description of an exception that may be raised by a method. The name of the exception is given with the first parameter and description with the second.

*Note*: All of the text following the directive, up to the next directive is considered as part of the directive description. This allows you to include multiple paragraphs, unordered or ordered lists, warnings, bugs and the rest, but may come as surprise if not expected! To compensate, it's recommended to enter all these directives at the bottom of the comment text. In fact, because of this, all directives are formatted so that you enter the description as the last directive "parameter".


#Various bits and pieces

- **Generating related links**: `@see <name>` or `@sa <name>`. Although you can provide cross reference links anywhere within the paragraph text, as described above, you need to use @see directives to provide related context links for documentation sets. The name should follow cross reference guidelines described above.

  **Note**: Methods and properties keep all cross references in generated HTML, regardless of the referenced object. But when `@see` is used within class, category or protocol comment, only cross references to template documents are preserved and converted to companion guide links (generated in the table below the title). All other cross references - i.e. to other objects or members - are ignored. Oh, and remember, you can use nice descriptions using Markdown syntax, for example:

  ```
  @see [String Programming Guide](document1).
  ```
     
- **Grouping methods**: `@name <title>`. All methods and properties declared after @name directive will be stored into a group with the given title. These groups are then extracted as tasks in generated HTML. Important: @name must be specified in it's own separate comment preceeding the first group method or property comment for which the task is specified! So this would work:

  ```objc
  /** @name Section title */

  /** Method description */
  - (void)someMethod;
  ```
	  
  and this wouldn't:
	
  ```objc
  /** @name Section title

  Method description */
  - (void)someMethod;
  ```
      
- **Comment delimiters**: Any comment may optionally include delimiter lines. A delimiter line is any combination of 3 or more chars from the following set: `"!@#$%^&*()_=``~,<.>/?;:'\\"-"`. Such lines are ignored, so given a comment like this:

  ```objc
  /// ---------------------------------
  /// comment
  /// ---------------------------------
  ```

  will automatically strip first and last line. This is mostly used for making `@name` sections more stand out.

- **Directives prefix**: Although all directives in examples above use "@" sign as a prefix, you can actually use any non-whitespace char instead, for example `\param`, `$param`, `%param` and so on...

And last, but not least, as appledoc uses standard Markdown rules, take a look at [Markdown documentation](http://daringfireball.net/projects/markdown/) and [Discount library ](http://www.pell.portland.or.us/~orc/Code/discount/)for more details and possibilities. This doc is only meant as a quick guide to general formatting and all appledoc specifics, not as comprehensive documentation of all supported Markdown features. Also take a look at [appledoc source code](https://github.com/tomaz/appledoc/) for examples of how it fits together.
