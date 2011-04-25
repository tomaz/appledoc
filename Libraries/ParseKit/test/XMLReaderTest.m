//
//  XMLReaderTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/18/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "XMLReaderTest.h"

@implementation XMLReaderTest

- (void)test {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"xml"];
    
    NSLog(@"\n\npath: %@\n\n", path);

    XMLReader *p = [XMLReader parserWithContentsOfFile:path];
    NSInteger ret = [p read];
    while (ret == 1) {
        //NSLog(@"nodeType: %d, name: %@", p.nodeType, p.name);
        ret = [p read];
        
    }
}

@end
