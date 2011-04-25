//
//  PKJavaScriptParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/22/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJavaScriptParserTest.h"

@implementation TDJavaScriptParserTest

- (void)setUp {
    jsp = [TDJavaScriptParser parser];
}


- (void)tearDown {
    
}


- (void)testStmtParser {
    s = @";";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.stmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[;];^");

    s = @"{}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.stmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[{, }]{/}^");
}


- (void)testFunctionParser {
    s = @"function";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.functionParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function]function^");
}


- (void)testIdentifierParser {
    s = @"foo";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.identifierParser bestMatchFor:a];
    TDEqualObjects([res description], @"[foo]foo^");
}


- (void)testParamListOptParserParser {
    s = @"a, b";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.paramListOptParser bestMatchFor:a];
    TDEqualObjects([res description], @"[a, ,, b]a/,/b^");
}


- (void)testCompoundStmtParserParser {
    s = @"{}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.compoundStmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[{, }]{/}^");
}


- (void)testFuncParser {
    s = @"function foo(a, b) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.funcParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, foo, (, a, ,, b, ), {, }]function/foo/(/a/,/b/)/{/}^");

    s = @"function foo(a, b) { return a + b; }";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.funcParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, foo, (, a, ,, b, ), {, return, a, +, b, ;, }]function/foo/(/a/,/b/)/{/return/a/+/b/;/}^");

    s = @"function foo(a, b) { a++; b--; return a + b; }";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.funcParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, foo, (, a, ,, b, ), {, a, ++, ;, b, --, ;, return, a, +, b, ;, }]function/foo/(/a/,/b/)/{/a/++/;/b/--/;/return/a/+/b/;/}^");

    s = @"function foo(a, b) { a++; b--; return a + b; }";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.elementParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, foo, (, a, ,, b, ), {, a, ++, ;, b, --, ;, return, a, +, b, ;, }]function/foo/(/a/,/b/)/{/a/++/;/b/--/;/return/a/+/b/;/}^");
}


- (void)testBitwiseOrExprParser {
    s = @"true";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.bitwiseOrExprParser bestMatchFor:a];
    TDEqualObjects([res description], @"[true]true^");
}


- (void)testAndBitwiseOrExprParser {
    s = @"&& true";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.andBitwiseOrExprParser bestMatchFor:a];
    TDEqualObjects([res description], @"[&&, true]&&/true^");
}


- (void)testParamListParser {
    s = @"baz, bat";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.paramListParser bestMatchFor:a];
    TDEqualObjects([res description], @"[baz, ,, bat]baz/,/bat^");
    
    s = @"foo,bar,c_str";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.paramListParser bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, ,, bar, ,, c_str]foo/,/bar/,/c_str^");

    s = @"_x, __y";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.paramListParser bestMatchFor:a];
    TDEqualObjects([res description], @"[_x, ,, __y]_x/,/__y^");
}


- (void)testCommaIdentifierParser {
    s = @", foo";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.commaIdentifierParser bestMatchFor:a];
    TDEqualObjects([res description], @"[,, foo],/foo^");

    s = @" ,bar";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.commaIdentifierParser bestMatchFor:a];
    TDEqualObjects([res description], @"[,, bar],/bar^");
}


- (void)testBreakStmtParser {
    s = @"break;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.breakStmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[break, ;]break/;^");
}


- (void)testContinueStmtParser {
    s = @"continue;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.continueStmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[continue, ;]continue/;^");
}


- (void)testAssignmentOpParser {
    s = @"=";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.assignmentOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[=]=^");
    
    s = @"*=";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.assignmentOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[*=]*=^");
    
    s = @"%=";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.assignmentOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[%=]%=^");
    
    s = @">>>=";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.assignmentOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[>>>=]>>>=^");
}


- (void)testRelationalOpParser {
    s = @"<=";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.relationalOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[<=]<=^");

    s = @"instanceof";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.relationalOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[instanceof]instanceof^");
}


- (void)testEqualityOpParser {
    s = @"==";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.equalityOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[==]==^");
    
    s = @"!==";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.equalityOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[!==]!==^");
    
    s = @"===";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.equalityOpParser bestMatchFor:a];
    TDEqualObjects([res description], @"[===]===^");
}


- (void)testForParenParser {
    s = @"for (";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.forParenParser bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (]for/(^");

    s = @"for(";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.forParenParser bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (]for/(^");
}


- (void)testExprOptParser {
    s = @"true";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.exprOptParser bestMatchFor:a];
    TDEqualObjects([res description], @"[true]true^");
}


- (void)testForBeginParenStmtParser {
    s = @"for(1";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.forBeginParser bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, 1]for/(/1^");
    
    s = @";";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.semiParser bestMatchFor:a];
    TDEqualObjects([res description], @"[;];^");
    
    s = @"3<2";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.exprOptParser bestMatchFor:a];
    TDEqualObjects([res description], @"[3, <, 2]3/</2^");
    
    s = @"1";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.exprOptParser bestMatchFor:a];
    TDEqualObjects([res description], @"[1]1^");
    
    s = @")";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.closeParenParser bestMatchFor:a];
    TDEqualObjects([res description], @"[)])^");
    
    s = @"{}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.stmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[{, }]{/}^");    
        
    s = @"for(1; 3<2; 1) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.forBeginStmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, 1, ;, 3, <, 2, ;, 1, ), {, }]for/(/1/;/3/</2/;/1/)/{/}^");
    
    s = @"for(1; 3<2; 1) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, 1, ;, 3, <, 2, ;, 1, ), {, }]for/(/1/;/3/</2/;/1/)/{/}^");

    s = @"for(var i = 0; true; true) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.forBeginStmtParser bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, i, =, 0, ;, true, ;, true, ), {, }]for/(/var/i/=/0/;/true/;/true/)/{/}^");
}


- (void)testUndefinedParser {
    s = @"undefined";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.undefinedParser bestMatchFor:a];
    TDEqualObjects([res description], @"[undefined]undefined^");
}


- (void)testNullParser {
    s = @"null";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.nullParser bestMatchFor:a];
    TDEqualObjects([res description], @"[null]null^");
}


- (void)testFalseParser {
    s = @"false";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.falseParser bestMatchFor:a];
    TDEqualObjects([res description], @"[false]false^");
}


- (void)testTrueParser {
    s = @"true";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.trueParser bestMatchFor:a];
    TDEqualObjects([res description], @"[true]true^");
}


- (void)testNumberParser {
    s = @"47.2";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.numberParser bestMatchFor:a];
    TDEqualObjects([res description], @"[47.2]47.2^");

    s = @"-0.20";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.numberParser bestMatchFor:a];
    TDEqualObjects([res description], @"[-0.20]-0.20^");
    
    s = @"-0.20e6";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.numberParser bestMatchFor:a];
    TDEqualObjects([res description], @"[-0.20e6]-0.20e6^");
}


- (void)testStringParser {
    s = @"'foo'";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.stringParser bestMatchFor:a];
    TDEqualObjects([res description], @"['foo']'foo'^");
}


- (void)testFoo {
    s = @"function() {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.funcLiteralParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, (, ), {, }]function/(/)/{/}^");
    
    s = @"function() {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.primaryExprParser bestMatchFor:a];
    TDEqualObjects([res description], @"[function, (, ), {, }]function/(/)/{/}^");
    
    s = @"var foo =function(a, b) {return a+b;};";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, foo, =, function, (, a, ,, b, ), {, return, a, +, b, ;, }, ;]var/foo/=/function/(/a/,/b/)/{/return/a/+/b/;/}/;^");
    
    s = @"var foo = 'bar';";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, foo, =, 'bar', ;]var/foo/=/'bar'/;^");

    s = @"foo = 'bar';";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, =, 'bar', ;]foo/=/'bar'/;^");
}


- (void)testWhileLoop {
    s = @"while(true) {alert(i++);}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[while, (, true, ), {, alert, (, i, ++, ), ;, }]while/(/true/)/{/alert/(/i/++/)/;/}^");

    s = @"2 < 10;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[2, <, 10, ;]2/</10/;^");

    s = @"while(i<10) {alert(i++);}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[while, (, i, <, 10, ), {, alert, (, i, ++, ), ;, }]while/(/i/</10/)/{/alert/(/i/++/)/;/}^");
}


- (void)testForLoop {
    s = @"for( ; true; true) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, ;, true, ;, true, ), {, }]for/(/;/true/;/true/)/{/}^");
    
    s = @"i++";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.unaryExpr4Parser bestMatchFor:a];
    TDEqualObjects([res description], @"[i, ++]i/++^");
    
    s = @"i++";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp.unaryExprParser bestMatchFor:a];
    TDEqualObjects([res description], @"[i, ++]i/++^");
    
    s = @"i++;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[i, ++, ;]i/++/;^");
    
    s = @"i++";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[i, ++]i/++^");
    
    s = @"for(var i=0; i<10; i++) {alert(i);}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, i, =, 0, ;, i, <, 10, ;, i, ++, ), {, alert, (, i, ), ;, }]for/(/var/i/=/0/;/i/</10/;/i/++/)/{/alert/(/i/)/;/}^");
}


- (void)testForInLoop {
    s = @"for(var p in obj) {alert(p);}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, p, in, obj, ), {, alert, (, p, ), ;, }]for/(/var/p/in/obj/)/{/alert/(/p/)/;/}^");
    
    s = @"for(var p in obj) alert(p);";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, p, in, obj, ), alert, (, p, ), ;]for/(/var/p/in/obj/)/alert/(/p/)/;^");
    
    s = @"for(var p in obj) {}";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, p, in, obj, ), {, }]for/(/var/p/in/obj/)/{/}^");
    
    s = @"for ( var p in obj );";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[for, (, var, p, in, obj, ), ;]for/(/var/p/in/obj/)/;^");
}


- (void)testArrayLiteral {
    s = @"var foo = ['bar'];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, foo, =, [, 'bar', ], ;]var/foo/=/[/'bar'/]/;^");    
}


- (void)testObjectLiteral {
    s = @"var foo = {foo:'bar'};";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, foo, =, {, foo, :, 'bar', }, ;]var/foo/=/{/foo/:/'bar'/}/;^");    
}


- (void)testExecuteAnonFunc {
    s = @"(function() {})();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[(, function, (, ), {, }, ), (, ), ;](/function/(/)/{/}/)/(/)/;^");    

    s = @"(function(a) {alert(a);})();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[(, function, (, a, ), {, alert, (, a, ), ;, }, ), (, ), ;](/function/(/a/)/{/alert/(/a/)/;/}/)/(/)/;^");    
}


- (void)testSemi {
    s = @";";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[;];^");
}


- (void)testString {
    s = @"'bar';";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"['bar', ;]'bar'/;^");
}


- (void)testMember {
    s = @"foo.bar;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, ., bar, ;]foo/./bar/;^");

    s = @"foo.bar();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, ., bar, (, ), ;]foo/./bar/(/)/;^");

    s = @"foo[bar];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, [, bar, ], ;]foo/[/bar/]/;^");
}


- (void)testConstructor {
    s = @"new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, (, ), ;]new/foo/(/)/;^");

    s = @"var bar = new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, bar, =, new, foo, (, ), ;]var/bar/=/new/foo/(/)/;^");
    
    s = @"baz.bar = new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[baz, ., bar, =, new, foo, (, ), ;]baz/./bar/=/new/foo/(/)/;^");
    
    s = @"baz[bar] = new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[baz, [, bar, ], =, new, foo, (, ), ;]baz/[/bar/]/=/new/foo/(/)/;^");
    
    s = @"baz['bar'] = new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[baz, [, 'bar', ], =, new, foo, (, ), ;]baz/[/'bar'/]/=/new/foo/(/)/;^");
    
    s = @"foo.bar.baz;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, ., bar, ., baz, ;]foo/./bar/./baz/;^");

    s = @"foo[bar].baz;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, [, bar, ], ., baz, ;]foo/[/bar/]/./baz/;^");
    
    s = @"foo[bar].baz();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, [, bar, ], ., baz, (, ), ;]foo/[/bar/]/./baz/(/)/;^");
    
    s = @"foo[bar][baz];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, [, bar, ], [, baz, ], ;]foo/[/bar/]/[/baz/]/;^");
    
    s = @"foo(bar);";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, bar, ), ;]foo/(/bar/)/;^");
    
    s = @"foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, ), ;]foo/(/)/;^");
    
    s = @"foo()();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, ), (, ), ;]foo/(/)/(/)/;^");
    
    s = @"foo().bat;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, ), ., bat, ;]foo/(/)/./bat/;^");
    
    s = @"foo().bat();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, ), ., bat, (, ), ;]foo/(/)/./bat/(/)/;^");
    
    s = @"foo().bat()[bar];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[foo, (, ), ., bat, (, ), [, bar, ], ;]foo/(/)/./bat/(/)/[/bar/]/;^");
    
    s = @"new foo();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, (, ), ;]new/foo/(/)/;^");
    
    s = @"new foo;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, ;]new/foo/;^");
    
    s = @"new foo.bar;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, ., bar, ;]new/foo/./bar/;^");
    
    s = @"new foo().bat;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, (, ), ., bat, ;]new/foo/(/)/./bat/;^");
    
    s = @"new String('foo').charAt(0);";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, String, (, 'foo', ), ., charAt, (, 0, ), ;]new/String/(/'foo'/)/./charAt/(/0/)/;^");
    
    s = @"new String('foo').charAt(0) instanceof String;";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, String, (, 'foo', ), ., charAt, (, 0, ), instanceof, String, ;]new/String/(/'foo'/)/./charAt/(/0/)/instanceof/String/;^");
    
    s = @"new foo()[bar];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, (, ), [, bar, ], ;]new/foo/(/)/[/bar/]/;^");
    
    s = @"new foo.bar();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, ., bar, (, ), ;]new/foo/./bar/(/)/;^");
    
    s = @"new this.bar();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, this, ., bar, (, ), ;]new/this/./bar/(/)/;^");
    
    s = @"new foo().bat[bar];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[new, foo, (, ), ., bat, [, bar, ], ;]new/foo/(/)/./bat/[/bar/]/;^");
    
    s = @"var _bar = new _foo_();";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[var, _bar, =, new, _foo_, (, ), ;]var/_bar/=/new/_foo_/(/)/;^");
}    


- (void)testDelete {
    s = @"delete foo[bar];";
    jsp.tokenizer.string = s;
    a = [PKTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
    res = [jsp bestMatchFor:a];
    TDEqualObjects([res description], @"[delete, foo, [, bar, ], ;]delete/foo/[/bar/]/;^");
}    

@end
