//
//  GBCommentsProcessor+CodeBlockProcessing.h
//  appledoc
//
//  Created by Jody Hagins on 9/6/15.
//  Copyright (c) 2015 Gentle Bytes. All rights reserved.
//

#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor (CodeBlockProcessing)

/**
 Get a collection of components contained in the @a string

 Specifically, this method searches for source-code-block components and reference-link components.

 No two components will overlap, and the resulting array will be sorted, relative to the range location

 @param string the text to search

 @return a sorted array of dictionaries, where each dictionary represents either a reference-link component or a source-code-block component.

     - If the component is a reference-link component, the dictionary will contain these keys
         - "link" (NSString) will contain all the text matching as a link reference - of the form [foo](bar)
         - "range" (NSRange wrapped in NSValue) will be the range for the link text, relative to the original @a string

     - If the component is a source-code-link component, the dictionary will contain these keys
         - "begin" (NSString) the token marking the beginning of the code block
         - "end" (NSString) the token marking the end of the code block
         - "prefix" (NSString) all the text before the start of the code block, including the line containing the begining marker
         - "postfix" (NSString) all the text after the code block, including the line containing the ending marker
         - "code" (NSString) all the text between the begining and ending markers
         - "range" (NSRange wrapped in NSValue) the range for the code text, relative to the original @a string
 */
- (NSArray*)codeAndLinkComponentsInString:(NSString*)string;

@end
