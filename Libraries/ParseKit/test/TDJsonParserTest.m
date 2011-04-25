//
//  PKJsonParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJsonParserTest.h"
#import "TDJsonParser.h"
#import "TDFastJsonParser.h"

@implementation TDJsonParserTest

- (void)setUp {
    p = [TDJsonParser parser];
}


- (void)testForAppleBossResultTokenization {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    PKTokenizer *t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    while (eof != (tok = [t nextToken])) {
        //NSLog(@"tok: %@", tok);
    }
}


- (void)testForAppleBossResult {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    @try {
        result = [p parse:s];
    }
    @catch (NSException *e) {
        //NSLog(@"\n\n\nexception:\n\n %@", [e reason]);
    }
    
    //NSLog(@"result %@", result);
}


- (void)testEmptyString {
    s = @"";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testNum {
    s = @"456";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p numberParser] bestMatchFor:a];
    TDNotNil(result);

    TDEqualObjects(@"[456]456^", [result description]);
    id obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects([NSNumber numberWithFloat:456], obj);

    
    s = @"-3.47";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p numberParser] bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[-3.47]-3.47^", [result description]);
    obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects([NSNumber numberWithFloat:-3.47], obj);
}


- (void)testString {
    s = @"'foobar'";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p stringParser] bestMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[foobar]'foobar'^", [result description]);
    id obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects(@"foobar", obj);

    s = @"\"baz boo boo\"";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p stringParser] bestMatchFor:a];
    TDNotNil(result);
    
    TDEqualObjects(@"[baz boo boo]\"baz boo boo\"^", [result description]);
    obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects(@"baz boo boo", obj);
}


- (void)testBoolean {
    s = @"true";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p booleanParser] bestMatchFor:a];
    TDNotNil(result);

    TDEqualObjects(@"[1]true^", [result description]);
    id obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects([NSNumber numberWithBool:YES], obj);

    s = @"false";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p booleanParser] bestMatchFor:a];
    TDNotNil(result);

    TDEqualObjects(@"[0]false^", [result description]);
    obj = [result pop];
    TDNotNil(obj);
    TDEqualObjects([NSNumber numberWithBool:NO], obj);
}


- (void)testArray {
    s = @"[1, 2, 3]";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p arrayParser] bestMatchFor:a];
    
    NSLog(@"result: %@", result);
    TDNotNil(result);
    id obj = [result pop];
    TDEquals((int)3, (int)[obj count]);
    TDEqualObjects([NSNumber numberWithInteger:1], [obj objectAtIndex:0]);
    TDEqualObjects([NSNumber numberWithInteger:2], [obj objectAtIndex:1]);
    TDEqualObjects([NSNumber numberWithInteger:3], [obj objectAtIndex:2]);
    TDEqualObjects(@"[][/1/,/2/,/3/]^", [result description]);

    s = @"[true, 'garlic jazz!', .888]";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p arrayParser] bestMatchFor:a];
    TDNotNil(result);
    
    //TDEqualObjects(@"[true, 'garlic jazz!', .888]true/'garlic jazz!'/.888^", [result description]);
    obj = [result pop];
    TDEqualObjects([NSNumber numberWithBool:YES], [obj objectAtIndex:0]);
    TDEqualObjects(@"garlic jazz!", [obj objectAtIndex:1]);
    TDEqualObjects([NSNumber numberWithFloat:.888], [obj objectAtIndex:2]);

    s = @"[1, [2, [3, 4]]]";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p arrayParser] bestMatchFor:a];
    TDNotNil(result);
    //NSLog(@"result: %@", [a stack]);
    TDEqualObjects([NSNumber numberWithInteger:1], [obj objectAtIndex:0]);
}


- (void)testObject {
    s = @"{'key': 'value'}";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p objectParser] bestMatchFor:a];
    TDNotNil(result);
    
    id obj = [result pop];
    TDEqualObjects([obj objectForKey:@"key"], @"value");

    s = @"{'foo': false, 'bar': true, \"baz\": -9.457}";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p objectParser] bestMatchFor:a];
    TDNotNil(result);
    
    obj = [result pop];
    TDEqualObjects([obj objectForKey:@"foo"], [NSNumber numberWithBool:NO]);
    TDEqualObjects([obj objectForKey:@"bar"], [NSNumber numberWithBool:YES]);
    TDEqualObjects([obj objectForKey:@"baz"], [NSNumber numberWithFloat:-9.457]);

    s = @"{'baz': {'foo': [1,2]}}";
    a = [PKTokenAssembly assemblyWithString:s];
    result = [[p objectParser] bestMatchFor:a];
    TDNotNil(result);
    
    obj = [result pop];
    NSDictionary *dict = [obj objectForKey:@"baz"];
    TDTrue([dict isKindOfClass:[NSDictionary class]]);
    NSArray *arr = [dict objectForKey:@"foo"];
    TDTrue([arr isKindOfClass:[NSArray class]]);
    TDEqualObjects([NSNumber numberWithInteger:1], [arr objectAtIndex:0]);
    
    //    TDEqualObjects(@"['baz', 'foo', 1, 2]'baz'/'foo'/1/2^", [result description]);
}


- (void)testCrunchBaseJsonParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDJsonParser *parser = [[[TDJsonParser alloc] init] autorelease];
    [parser parse:s];
//    id res = [parser parse:s];
    //NSLog(@"res %@", res);
}


- (void)testCrunchBaseJsonParserTokenization {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    PKTokenizer *t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    while (eof != (tok = [t nextToken])) {
        //NSLog(@"tok: %@", tok);
    }    
}


- (void)testCrunchBaseJsonTokenParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDFastJsonParser *parser = [[[TDFastJsonParser alloc] init] autorelease];
    [parser parse:s];
    //    id res = [parser parse:s];
    //NSLog(@"res %@", res);
}


- (void)testYahoo1 {
    s = 
    @"{"
        @"\"name\": \"Yahoo!\","
        @"\"permalink\": \"yahoo\","
        @"\"homepage_url\": \"http://www.yahoo.com\","
        @"\"blog_url\": \"http://yodel.yahoo.com/\","
        @"\"blog_feed_url\": \"http://ycorpblog.com/feed/\","
        @"\"category_code\": \"web\","
        @"\"number_of_employees\": 13600,"
        @"\"founded_year\": 1994,"
        @"\"founded_month\": null,"
        @"\"founded_day\": null,"
        @"\"deadpooled_year\": null,"
        @"\"deadpooled_month\": null,"
        @"\"deadpooled_day\": null,"
        @"\"deadpooled_url\": null,"
        @"\"tag_list\": \"search, portal, webmail, photos\","
        @"\"email_address\": \"\","
        @"\"phone_number\": \"(408) 349-3300\""
    @"}";
    result = [p parse:s];
    //NSLog(@"result %@", result);
    TDNotNil(result);
    id d = result;
    TDNotNil(d);
    TDTrue([d isKindOfClass:[NSDictionary class]]);
    TDEqualObjects([d objectForKey:@"name"], @"Yahoo!");
    TDEqualObjects([d objectForKey:@"permalink"], @"yahoo");
    TDEqualObjects([d objectForKey:@"homepage_url"], @"http://www.yahoo.com");
    TDEqualObjects([d objectForKey:@"blog_url"], @"http://yodel.yahoo.com/");
    TDEqualObjects([d objectForKey:@"blog_feed_url"], @"http://ycorpblog.com/feed/");
    TDEqualObjects([d objectForKey:@"category_code"], @"web");
    TDEqualObjects([d objectForKey:@"number_of_employees"], [NSNumber numberWithInteger:13600]);
    TDEqualObjects([d objectForKey:@"founded_year"], [NSNumber numberWithInteger:1994]);
    TDEqualObjects([d objectForKey:@"founded_month"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"founded_day"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"deadpooled_year"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"deadpooled_month"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"deadpooled_day"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"deadpooled_url"], [NSNull null]);
    TDEqualObjects([d objectForKey:@"tag_list"], @"search, portal, webmail, photos");
    TDEqualObjects([d objectForKey:@"email_address"], @"");
    TDEqualObjects([d objectForKey:@"phone_number"], @"(408) 349-3300");
}


- (void)testYahoo2 {
    s = @"{\"image\":"
        @"    {\"available_sizes\":"
        @"        [[[150, 37],"
        @"        \"assets/images/resized/0001/0836/10836v1-max-250x150.png\"],"
        @"        [[200, 50],"
        @"        \"assets/images/resized/0001/0836/10836v1-max-250x250.png\"],"
        @"        [[200, 50],"
        @"        \"assets/images/resized/0001/0836/10836v1-max-450x450.png\"]],"
        @"    \"attribution\": null}"
        @"}";
    result = [p parse:s];
    //NSLog(@"result %@", result);

    TDNotNil(result);

    id d = result;
    TDNotNil(d);
    TDTrue([d isKindOfClass:[NSDictionary class]]);
    
    id image = [d objectForKey:@"image"];
    TDNotNil(image);
    TDTrue([image isKindOfClass:[NSDictionary class]]);

    NSArray *sizes = [image objectForKey:@"available_sizes"];
    TDNotNil(sizes);
    TDTrue([sizes isKindOfClass:[NSArray class]]);
    
    TDEquals(3, (int)[sizes count]);
    
    NSArray *first = [sizes objectAtIndex:0];
    TDNotNil(first);
    TDTrue([first isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[first count]);
    
    NSArray *firstKey = [first objectAtIndex:0];
    TDNotNil(firstKey);
    TDTrue([firstKey isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[firstKey count]);
    TDEqualObjects([NSNumber numberWithInteger:150], [firstKey objectAtIndex:0]);
    TDEqualObjects([NSNumber numberWithInteger:37], [firstKey objectAtIndex:1]);
    
    NSArray *second = [sizes objectAtIndex:1];
    TDNotNil(second);
    TDTrue([second isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[second count]);
    
    NSArray *secondKey = [second objectAtIndex:0];
    TDNotNil(secondKey);
    TDTrue([secondKey isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[secondKey count]);
    TDEqualObjects([NSNumber numberWithInteger:200], [secondKey objectAtIndex:0]);
    TDEqualObjects([NSNumber numberWithInteger:50], [secondKey objectAtIndex:1]);
    
    NSArray *third = [sizes objectAtIndex:2];
    TDNotNil(third);
    TDTrue([third isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[third count]);
    
    NSArray *thirdKey = [third objectAtIndex:0];
    TDNotNil(thirdKey);
    TDTrue([thirdKey isKindOfClass:[NSArray class]]);
    TDEquals(2, (int)[thirdKey count]);
    TDEqualObjects([NSNumber numberWithInteger:200], [thirdKey objectAtIndex:0]);
    TDEqualObjects([NSNumber numberWithInteger:50], [thirdKey objectAtIndex:1]);
    
    
//    TDEqualObjects([d objectForKey:@"name"], @"Yahoo!");
}


- (void)testYahoo3 {
    s = 
    @"{\"products\":"
        @"["
            @"{\"name\": \"Yahoo.com\", \"permalink\": \"yahoo-com\"},"
            @"{\"name\": \"Yahoo! Mail\", \"permalink\": \"yahoo-mail\"},"
            @"{\"name\": \"Yahoo! Search\", \"permalink\": \"yahoo-search\"},"
            @"{\"name\": \"Yahoo! Directory\", \"permalink\": \"yahoo-directory\"},"
            @"{\"name\": \"Yahoo! Finance\", \"permalink\": \"yahoo-finance\"},"
            @"{\"name\": \"My Yahoo\", \"permalink\": \"my-yahoo\"},"
            @"{\"name\": \"Yahoo! News\", \"permalink\": \"yahoo-news\"},"
            @"{\"name\": \"Yahoo! Groups\", \"permalink\": \"yahoo-groups\"},"
            @"{\"name\": \"Yahoo! Messenger\", \"permalink\": \"yahoo-messenger\"},"
            @"{\"name\": \"Yahoo! Games\", \"permalink\": \"yahoo-games\"},"
            @"{\"name\": \"Yahoo! People Search\", \"permalink\": \"yahoo-people-search\"},"
            @"{\"name\": \"Yahoo! Movies\", \"permalink\": \"yahoo-movies\"},"
            @"{\"name\": \"Yahoo! Weather\", \"permalink\": \"yahoo-weather\"},"
            @"{\"name\": \"Yahoo! Video\", \"permalink\": \"yahoo-video\"},"
            @"{\"name\": \"Yahoo! Music\", \"permalink\": \"yahoo-music\"},"
            @"{\"name\": \"Yahoo! Sports\", \"permalink\": \"yahoo-sports\"},"
            @"{\"name\": \"Yahoo! Maps\", \"permalink\": \"yahoo-maps\"},"
            @"{\"name\": \"Yahoo! Auctions\", \"permalink\": \"yahoo-auctions\"},"
            @"{\"name\": \"Yahoo! Widgets\", \"permalink\": \"yahoo-widgets\"},"
            @"{\"name\": \"Yahoo! Shopping\", \"permalink\": \"yahoo-shopping\"},"
            @"{\"name\": \"Yahoo! Real Estate\", \"permalink\": \"yahoo-real-estate\"},"
            @"{\"name\": \"Yahoo! Travel\", \"permalink\": \"yahoo-travel\"},"
            @"{\"name\": \"Yahoo! Classifieds\", \"permalink\": \"yahoo-classifieds\"},"
            @"{\"name\": \"Yahoo! Answers\", \"permalink\": \"yahoo-answers\"},"
            @"{\"name\": \"Yahoo! Mobile\", \"permalink\": \"yahoo-mobile\"},"
            @"{\"name\": \"Yahoo! Buzz\", \"permalink\": \"yahoo-buzz\"},"
            @"{\"name\": \"Yahoo! Open Search Platform\", \"permalink\": \"yahoo-open-search-platform\"},"
            @"{\"name\": \"Fire Eagle\", \"permalink\": \"fireeagle\"},"
            @"{\"name\": \"Shine\", \"permalink\": \"shine\"},"
            @"{\"name\": \"Yahoo! Shortcuts\", \"permalink\": \"yahoo-shortcuts\"}"
        @"]"
    @"}";
    result = [p parse:s];
    //NSLog(@"result %@", result);
    
    TDNotNil(result);

    id d = result;
    TDNotNil(d);
    TDTrue([d isKindOfClass:[NSDictionary class]]);
    
    NSArray *products = [d objectForKey:@"products"];
    TDNotNil(products);
    TDTrue([products isKindOfClass:[NSArray class]]);
}


- (void)testYahoo4 {
    s = @"["
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
        @"1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"
        @"]";

    p = [[[TDFastJsonParser alloc] init] autorelease];
    result = [p parse:s];
    //NSLog(@"result %@", result);
    
    TDNotNil(result);

    id d = result;
    TDNotNil(d);
    TDTrue([d isKindOfClass:[NSArray class]]);
    
//    NSArray *products = [d objectForKey:@"products"];
//    TDNotNil(products);
//    TDTrue([products isKindOfClass:[NSArray class]]);
}
@end
