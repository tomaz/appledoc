# Include companion guides and other documentation

Appledoc can include arbitrary documentation from anywhere on your computer using `--include` command line switch(es) like this:

```
appledoc
	--project-name appledoc
	--project-company "Gentle Bytes"
	--company-id com.gentlebytes
	--output ~/help
	--include ~/docs/eula.html
	--include ./docs/companion
	.
```

In this example, appledoc will copy file `eula.html` from `~/docs` directory and all files and subdirectories of `docs/companion` directory from current path to the resulting HTML and documentation set. You can give it as many `--include` switches as you'd like, each "points" to a file or directory. In any case, the file or the whole directory structure is copied over.

## Directory Structure					

**Important:** All included documentation is copied inside `docs` subdirectory within the output path (the same path where the index and hierarchy files are generated). If the path given with `--include` switch is a file, the file is copied directly inside `docs` folder. If the path is directory, a subdirectory with the name of last path component is created and contents are copied there. So if the `./docs/companion` directory from the above example contains a single file `somefile.html`, the above command line will result in the following directory structure at `~/help`:

<pre>
~/help/
    index.html
    hierarchy.html
    ...
    <strong>docs/
        eula.html
        companion/
            somefile.html</strong>
</pre>

If above example would use another include switch, let's say `--include ./docs/something/else`, the above directory structure would also include contents of `else` directory as the subdirectory of `docs`:

<pre>
~/help/
    index.html
    hierarchy.html
    ...
    docs/
        eula.html
        companion/
            somefile.html
        <strong>else/</strong>
</pre>
					
This is important to keep in mind, so that you can properly setup stuff like cross references in html files and similar! It also requires you to use unique names for every file or directory from `--include` switch!
					
**Note:** Although it's completely up to your preference where the files are stored, in most cases it makes sense to include project related documentation in project's subdirectory and also keep it under versioning system.
				
# Using appledoc documentation style

As above example demonstrated, you can easily create companion guides in the form of html files which are included in generated documentation. This is quite powerful by itself, but it's still lacking stuff like simple cross referencing from documents to source [code documentation](CommentsFormattingStyle.markdown) and vice versa. Although absolutely doable, it requires manually knowing exact paths to individual entities and this is error prone and can easily break if appledoc changes the way it generates output in the future. To overcome this, appledoc allows you to write documentation using the same syntax as the rest of the code documentation, including formatting directives, cross references and the rest of it!
					
These files should be plain text documents and must use the same Markdown-like formatting as standard source code comments. As appledoc supports full Markdown syntax ([extended actually](http://www.pell.portland.or.us/~orc/Code/discount/)), you can use headings, include images (as long as they are stored within one of the included paths, they are copied over to the output, [see here](#directory-structure) for details of how files are copied, so you can determine the path). Of course you can include any valid html tag and it will be properly picked up for you! Because these files don't contain actual representation, but rather template which is used to generate actual output HTML, they are referred to as "template documents". Here's an example of such document:

~~~
Main title
==========
 
Some paragraph with *formatted* text.
 
- list
    1. sublist
    2. anoter item
- and another one
 
You can include example blocks:
 
    NSString *string;
    string = @"hello";
 
etc. etc. etc. - you get the point :)
~~~ 
					
**Note:** In order to achieve this, appledoc needs to post-process these files using the same logic used for post-processing "normal" source code comments. To give you control over which files need post-processing, you need to use special file names - specifically, you need to use `-template` suffix in the file name, for example `document1-template.html`. You don't have to explicitly include these files using `--include` switches, appledoc will recursively parse any directory you include for these files! For example, if you have:

```
~/documentation
    document1-template.html
    something.css
    subdir/
        document2-template.markdown
        another-file.html
```

and use `--include ~/documentation` in command line, appledoc will automatically pick up `document1-template.html` and `document2-template.markdown` and process them. Each template file is then copied to the same subdirectory as expected except that generated filename doesn't have `-template` suffix and always uses .html extension, regardless of the original file extension! So above would result in this structure inside output directory:</p>

<pre>
~/help/
    index.html
    hierarchy.html
    ...
    docs/
        documentation/
            <strong>document1.html</strong> 
            something.css
            subdir/
                <strong>document2.html</strong> 
                another-file.html
</pre>
					
**Important:** Although you can include template documents anywhere in the directory structure, you must use unique names for all of them, so you can't have two `document1-template.html` files, even if you use different extension! Even if you include them with different `--include` switches! The reason is [explained below](#cross-referencing-documents) :)

# Cross referencing documents

If you want to cross reference included documentation from your source code comments, just remember above mentioned [generated directory structure](#directory-structure) and use `<a>` tags to get to the desired file (an image for example).
					
While this would work great, there's even simpler alternative for cross referencing [template documents](#using-appledoc-documentation-style): if any word matches document name without `-template` suffix and extension, it's automatically converted to cross reference to that document! To use above example, any `document1` word will be converted to cross reference to `docs/documentation.document1.html` and so on. This frees you from changing directory structure (appledoc will automatically prepare proper href address!) and makes your source code comments more readable! Cross referencing documents works the same from source code comments or other documents!
					
Needless to say, you can also cross reference any class, category, protocol, method, property or arbitrary URL from your documents! Just use [the same syntax as normally](CommentsFormattingStyle.markdown)! Of course you can also use custom names and still keep simple cross referencing using Markdown syntax: `[my description](document1)`.

**Important:** Template documents are very powerful mechanism of quickly preparing static content with the same simplicity and style as "normal" source code comments. And cross referencing them from other documents or comments is incredibly simple. However there's one caveat - in order to allow appledoc linking to proper file, each template document name must be unique, even if placed in a different path or even included with different `--include` switch!
				
# Injecting documention to main index

Appledoc also allows you to inject arbitrary description to auto-generated main `index.html` file. This is useful if you'd like to include static text to your framework or library main index file or links to static documentation such as companion guides etc. To do it, use `--index-desc` switch describing the path to the document that contains this description:

```
appledoc
	--project-name appledoc
	--project-company "Gentle Bytes"
	--company-id com.gentlebytes
	--output ~/help
	--index-desc ./docs/index.markdown
.
```

This command line instructs appledoc to read the contents of `index.markdown` file and inject it inside the main index file when generating output. You can use any extension you want, it doesn't matter, but the path must point to an existing filename - if you point it to a directory or nonexisting path, an error will be reported! 
					
The contents of the file are processed using the same rules as any other [template document](#using-appledoc-documentation-style). For example, you can cross reference any object or other document or use images (these should be included with one of the `--include` switches!) etc. Just keep in mind the contents of the index description document are going to be injected into the main `index.html` file, so use relative paths starting from the root of the documentation (and again, [remember](#directory-structure) that all included files are copied inside `docs` subdirectory). Of course, you can cross reference template documents using simple links as described [above](#cross-referencing-documents)!
					
**Note:** The only visual difference with regular document and the one injected into main index is how `<h1>` tags are handled: to make them visually closer to what Apple uses, all h1 headings use blue/underline style, the same as for Overview, Tasks and other main titles for objects. This is handled inside the generated CSS file.
