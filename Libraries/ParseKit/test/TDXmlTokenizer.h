//
//  PKXmlTokenizer.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDXmlToken;
@class XMLReader;

@interface TDXmlTokenizer : NSObject {
    XMLReader *reader;
}
+ (id)tokenizerWithContentsOfFile:(NSString *)path;

- (id)initWithContentsOfFile:(NSString *)path;
- (TDXmlToken *)nextToken;
@end
