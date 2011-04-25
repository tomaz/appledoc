//
//  PKXMLParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXMLParserTest.h"

@implementation TDXMLParserTest

- (void)setUp {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"xml" ofType:@"grammar"];
    g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    factory = [PKParserFactory factory];
    p = [factory parserFromGrammar:g assembler:self];
    t = p.tokenizer;
}


- (void)testSTag {
    PKParser *sTag = [p parserNamed:@"sTag"];
    
    t.string = @"<foo>";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >]</foo/>^", [res description]);

    t.string = @"<foo >";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  , >]</foo/ />^", [res description]);
    
    t.string = @"<foo \t>";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  \t, >]</foo/ \t/>^", [res description]);
    
    t.string = @"<foo \n >";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  \n , >]</foo/ \n />^", [res description]);
    
    t.string = @"<foo bar='baz'>";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  , bar, =, 'baz', >]</foo/ /bar/=/'baz'/>^", [res description]);

    t.string = @"<foo bar='baz' baz='bat'>";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  , bar, =, 'baz',  , baz, =, 'bat', >]</foo/ /bar/=/'baz'/ /baz/=/'bat'/>^", [res description]);
    
    t.string = @"<foo bar='baz' baz=\t'bat'>";
    res = [sTag bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo,  , bar, =, 'baz',  , baz, =, \t, 'bat', >]</foo/ /bar/=/'baz'/ /baz/=/\t/'bat'/>^", [res description]);
    
    t.string = @"<foo/>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    TDEqualObjects(@"[<, foo, />]</foo//>^", [res description]);
    
    t.string = @"<foo></foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, </, foo, >]</foo/>/<//foo/>^", [res description]);
    
    t.string = @"<foo> </foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >,  , </, foo, >]</foo/>/ /<//foo/>^", [res description]);
    
    t.string = @"<foo>&bar;</foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &, bar, ;, </, foo, >]</foo/>/&/bar/;/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#20;</foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#, 20, ;, </, foo, >]</foo/>/&#/20/;/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#xFF20;</foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;, </, foo, >]</foo/>/&#x/FF20/;/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#xFF20; </foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;,  , </, foo, >]</foo/>/&#x/FF20/;/ /<//foo/>^", [res description]);
    
    t.string = @"<foo><![CDATA[bar]]></foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, <![CDATA[bar]]>, </, foo, >]</foo/>/<![CDATA[bar]]>/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#xFF20;<![CDATA[bar]]></foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;, <![CDATA[bar]]>, </, foo, >]</foo/>/&#x/FF20/;/<![CDATA[bar]]>/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#xFF20; <![CDATA[bar]]></foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;,  , <![CDATA[bar]]>, </, foo, >]</foo/>/&#x/FF20/;/ /<![CDATA[bar]]>/<//foo/>^", [res description]);    
}


- (void)testSmallSTagGrammar {
    g = @"@delimitState='<';@reportsWhitespaceTokens=YES;@start=sTag;sTag='<' name (S attribute)* S? '>';name=/[^-:\\.]\\w+/;attribute=name eq attValue;eq=S? '=' S?;attValue=QuotedString;";
    PKParser *sTag = [factory parserFromGrammar:g assembler:nil];
    t = sTag.tokenizer;

    t.string = @"<foo>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [sTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo, >]</foo/>^", [res description]);

    t.string = @"<foo >";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [sTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo,  , >]</foo/ />^", [res description]);

    t.string = @"<foo \n>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [sTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo,  \n, >]</foo/ \n/>^", [res description]);

    t.string = @"< foo>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [sTag bestMatchFor:a];
    TDNil(res);
}


- (void)testSmallETagGrammar {
    g = @"@symbols = '&#' '&#x' '</' '/>' '<![' '<?xml' '<!DOCTYPE' '<!ELEMENT' '<!ATTLIST' '#PCDATA' '#REQUIRED' '#IMPLIED' '#FIXED' ')*';"
        @"@delimitState = '<';"
        @"@delimitedString='<!--' '-->' nil; @delimitedString='<?' '?>' nil; @delimitedString='<![CDATA[' ']]>' nil;"
        @"@reportsWhitespaceTokens = YES;"
        @"@start = eTag;"
        @"eTag='</' name S? '>';"
        @"name=/[^-:\\.]\\w+/;";
    
    PKParser *eTag = [factory parserFromGrammar:g assembler:nil];
    t = eTag.tokenizer;
    
    t.string = @"</foo>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eTag bestMatchFor:a];
    TDEqualObjects(@"[</, foo, >]<//foo/>^", [res description]);
    
    t.string = @"</foo >";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eTag bestMatchFor:a];
    TDEqualObjects(@"[</, foo,  , >]<//foo/ />^", [res description]);
    
    t.string = @"</ foo>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eTag bestMatchFor:a];
    TDNil(res);

    t.string = @"< /foo>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [eTag bestMatchFor:a];
    TDNil(res);
}
    
    
- (void)testETag {
    t.string = @"</foo>";
    res = [[p parserNamed:@"eTag"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[</, foo, >]<//foo/>^", [res description]);
}


- (void)test1 {
    t.string = @"<foo></foo>";
    res = [[p parserNamed:@"element"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, </, foo, >]</foo/>/<//foo/>^", [res description]);
    
    t.string = @"<foo/>";
    res = [[p parserNamed:@"emptyElemTag"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, />]</foo//>^", [res description]);
}


- (void)testSmallEmptyElemTagGrammar {
    g = @"@delimitState='<';@symbols='/>';@reportsWhitespaceTokens=YES;@start=emptyElemTag;emptyElemTag='<' name (S attribute)* S? '/>';name=/[^-:\\.]\\w+/;attribute=name eq attValue;eq=S? '=' S?;attValue=QuotedString;";
    PKParser *emptyElemTag = [factory parserFromGrammar:g assembler:nil];
    t = emptyElemTag.tokenizer;
    
    t.string = @"<foo/>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [emptyElemTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo, />]</foo//>^", [res description]);
    
    t.string = @"<foo />";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [emptyElemTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo,  , />]</foo/ //>^", [res description]);
    
    t.string = @"<foo bar='baz'/>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [emptyElemTag bestMatchFor:a];
    TDEqualObjects(@"[<, foo,  , bar, =, 'baz', />]</foo/ /bar/=/'baz'//>^", [res description]);
}


- (void)testSmallCharDataGrammar {
    g = @"@symbols = '&#' '&#x' '</' '/>' '<![' '<?xml' '<!DOCTYPE' '<!ELEMENT' '<!ATTLIST' '#PCDATA' '#REQUIRED' '#IMPLIED' '#FIXED' ')*';"
        @"@delimitState = '<';"
        @"@delimitedString='<!--' '-->' nil '<?' '?>' nil '<![CDATA[' ']]>' nil;"
        @"@reportsWhitespaceTokens = YES;"
        @"@start = charData+;"
        @"charData = /[^<\\&]+/ - (/[^\\]]*\\]\\]>[^<\\&]*/);";

    PKParser *charData = [factory parserFromGrammar:g assembler:nil];
    t = charData.tokenizer;

    t.string = @" ";
    res = [charData bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[ ] ^", [res description]);

    t.string = @"foo % 1";
    res = [charData bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo,  , %,  , 1]foo/ /%/ /1^", [res description]);

    t.string = @"foo & 1";
    res = [charData bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo,  ]foo/ ^&/ /1", [res description]);
}


- (void)testSmallElementGrammar {
    g = @"@symbols = '&#' '&#x' '</' '/>' '<![' '<?xml' '<!DOCTYPE' '<!ELEMENT' '<!ATTLIST' '#PCDATA' '#REQUIRED' '#IMPLIED' '#FIXED' ')*';"
        @"@delimitState = '<';"
        @"@delimitedStrings = '<!--' '-->' nil  '<?' '?>' nil  '<![CDATA[' ']]>' nil;"
        @"@reportsWhitespaceTokens = YES;"
        @"@start = element;"
        @"element = emptyElemTag | sTag content eTag;"
        @"eTag = '</' name S? '>';"
        @"sTag = '<' name (S attribute)* S? '>';"
        @"emptyElemTag = '<' name (S attribute)* S? '/>';"
        //@"content = Empty | (element | reference | cdSect | pi | comment | charData)+;"
        @"content = Empty | (element | reference | cdSect | charData)+;"
        @"name = /[^-:\\.]\\w+/;"
        @"attribute = name eq attValue;"
        @"eq=S? '=' S?;"
        @"attValue = QuotedString;"
        @"charData = /[^<\\&]+/ - (/[^\\]]*\\]\\]>[^<\\&]*/);"
        @"reference = entityRef | charRef;"
        @"entityRef = '&' name ';';"
        @"charRef = '&#' /[0-9]+/ ';' | '&#x' /[0-9a-fA-F]+/ ';';"
        @"cdSect = DelimitedString('<![CDATA[', ']]>');"
    ;
    
    PKParser *element = [factory parserFromGrammar:g assembler:nil];
    t = element.tokenizer;
    
    t.string = @"<foo/>";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [element bestMatchFor:a];
    TDEqualObjects(@"[<, foo, />]</foo//>^", [res description]);

    t.string = @"<foo></foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, </, foo, >]</foo/>/<//foo/>^", [res description]);
    
    t.string = @"<foo> </foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >,  , </, foo, >]</foo/>/ /<//foo/>^", [res description]);
    
    t.string = @"<foo>&bar;</foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &, bar, ;, </, foo, >]</foo/>/&/bar/;/<//foo/>^", [res description]);

    t.string = @"<foo>&#20;</foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#, 20, ;, </, foo, >]</foo/>/&#/20/;/<//foo/>^", [res description]);
    
    t.string = @"<foo>&#xFF20;</foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;, </, foo, >]</foo/>/&#x/FF20/;/<//foo/>^", [res description]);

    t.string = @"<foo>&#xFF20; </foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;,  , </, foo, >]</foo/>/&#x/FF20/;/ /<//foo/>^", [res description]);
    
    t.string = @"<foo><![CDATA[bar]]></foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, <![CDATA[bar]]>, </, foo, >]</foo/>/<![CDATA[bar]]>/<//foo/>^", [res description]);

    t.string = @"<foo>&#xFF20;<![CDATA[bar]]></foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;, <![CDATA[bar]]>, </, foo, >]</foo/>/&#x/FF20/;/<![CDATA[bar]]>/<//foo/>^", [res description]);

    t.string = @"<foo>&#xFF20; <![CDATA[bar]]></foo>";
    res = [element bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<, foo, >, &#x, FF20, ;,  , <![CDATA[bar]]>, </, foo, >]</foo/>/&#x/FF20/;/ /<![CDATA[bar]]>/<//foo/>^", [res description]);
}


// [1]
- (void)testDocument {
    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    t.string = @"<?xml version='1.0' encoding='utf-8' standalone='no'?><foo></foo>";
    res = [[p parserNamed:@"document"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?xml,  , version, =, '1.0',  , encoding, =, 'utf-8',  , standalone, =, 'no', ?>, <, foo, >, </, foo, >]<?xml/ /version/=/'1.0'/ /encoding/=/'utf-8'/ /standalone/=/'no'/?>/</foo/>/<//foo/>^", [res description]);    

    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    t.string = @"<?xml version='1.0' encoding='utf-8' standalone='no'?><foo></foo>";
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?xml,  , version, =, '1.0',  , encoding, =, 'utf-8',  , standalone, =, 'no', ?>, <, foo, >, </, foo, >]<?xml/ /version/=/'1.0'/ /encoding/=/'utf-8'/ /standalone/=/'no'/?>/</foo/>/<//foo/>^", [res description]);    

    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"xml"];
    t.string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDate *d = [NSDate date];
    res = [p bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    NSLog(@"time: %d", [d timeIntervalSinceNow]);
    TDNotNil(res);
    TDTrue([[res description] hasSuffix:@"^"]);
}


// [2]
- (void)test {
    
}


// [14]       CharData       ::=       [^<&]* - ([^<&]* ']]>' [^<&]*)
// charData = /[^<\&]+/ - (/[^\]]*\]\]>[^<\&]*/);
- (void)testCharData {
    t.string = @"foo";
    res = [[p parserNamed:@"charData"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);    
    
    t.string = @"fo<o";
    res = [[p parserNamed:@"charData"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[fo]fo^</o", [res description]);    
    
    t.string = @"fo&o";
    res = [[p parserNamed:@"charData"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[fo]fo^&/o", [res description]);    
    
}


// [15]       Comment       ::=       '<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
// comment = DelimitedString('<!--', '-->');
- (void)testComment {
    t.string = @"<!-- bar -->";
    res = [[p parserNamed:@"comment"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<!-- bar -->]<!-- bar -->^", [res description]);    
    
    
}


// [16]       PI       ::=       '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
// [17]       PITarget       ::=        Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))
// pi = '<?' piTarget ~/?>/* '?>';
// piTarget = name - /xml/i;

- (void)testPI {
    NSString *gram = 
        @"@reportsWhitespaceTokens=YES;"
        @"@symbols='<?' '?>';"
        @"@symbolState = '<';"
        @"name=/[^-:\\.]\\w+/;"
        @"piTarget = name - /xml/i;"
        @"@wordState = ':' '.' '-' '_';"
        @"@wordChars = ':' '.' '-' '_';"
        @"pi = '<?' piTarget ~/?>/* '?>';"
        @"@start = pi;";
    PKParser *pi = [[PKParserFactory factory] parserFromGrammar:gram assembler:nil];
    pi.tokenizer.string = @"<?foo bar='baz'?>";
    res = [pi bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:pi.tokenizer]];
    TDEqualObjects(@"[<?, foo,  , bar, =, 'baz', ?>]<?/foo/ /bar/=/'baz'/?>^", [res description]);    
    
    t.string = @"<?foo bar='baz'?>";
    res = [[p parserNamed:@"pi"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?, foo,  , bar, =, 'baz', ?>]<?/foo/ /bar/=/'baz'/?>^", [res description]);    
    
    t.string = @"<?f bar='baz'?>";
    res = [[p parserNamed:@"pi"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?, f,  , bar, =, 'baz', ?>]<?/f/ /bar/=/'baz'/?>^", [res description]);    
    
}


// [23]       XMLDecl       ::=       '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'
// xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
- (void)testXmlDecl {
//    versionNum = /(['"])1\.[0-9]\1/;
//    versionInfo = S 'version' eq versionNum;
    
    t.string = @" version='1.0'";
    res = [[p parserNamed:@"versionInfo"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[ , version, =, '1.0'] /version/=/'1.0'^", [res description]);
    
    // encodingDecl = S 'encoding' eq QuotedString; # TODO
    t.string = @" encoding='UTF-8'";
    res = [[p parserNamed:@"encodingDecl"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[ , encoding, =, 'UTF-8'] /encoding/=/'UTF-8'^", [res description]);
    
    // sdDecl = S 'standalone' eq QuotedString; # /(["'])(yes|no)\1/; # TODO
    t.string = @" standalone='no'";
    res = [[p parserNamed:@"sdDecl"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[ , standalone, =, 'no'] /standalone/=/'no'^", [res description]);
    
    t.string = @"<?xml";
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"<?xml", tok.stringValue);
    
    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    t.string = @"<?xml version='1.0'?>";
    res = [[p parserNamed:@"xmlDecl"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?xml,  , version, =, '1.0', ?>]<?xml/ /version/=/'1.0'/?>^", [res description]);
    
    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    t.string = @"<?xml version='1.0' encoding='utf-8'?>";
    res = [[p parserNamed:@"xmlDecl"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?xml,  , version, =, '1.0',  , encoding, =, 'utf-8', ?>]<?xml/ /version/=/'1.0'/ /encoding/=/'utf-8'/?>^", [res description]);
    
    // xmlDecl = '<?xml' versionInfo encodingDecl? sdDecl? S? '?>';
    t.string = @"<?xml version='1.0' encoding='utf-8' standalone='no'?>";
    res = [[p parserNamed:@"xmlDecl"] bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[<?xml,  , version, =, '1.0',  , encoding, =, 'utf-8',  , standalone, =, 'no', ?>]<?xml/ /version/=/'1.0'/ /encoding/=/'utf-8'/ /standalone/=/'no'/?>^", [res description]);    
    
}


@end
