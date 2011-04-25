//
//  XPathContext.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/17/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPathContext : NSObject {
    // static context
    NSString *baseURIString;
    NSMutableDictionary *namespaces;
    NSMutableDictionary *variables;
    NSMutableDictionary *functions;
    
    // dynamic context
    NSXMLNode *currentNode;
    NSXMLNode *contextNode;
    NSArray *contextNodeSet;
    
    // 
}
- (void)resetWithCurrentNode:(NSXMLNode *)n;
@property (retain) NSXMLNode *currentNode;
@property (retain) NSXMLNode *contextNode;
@property (retain) NSArray *contextNodeSet;
@end
