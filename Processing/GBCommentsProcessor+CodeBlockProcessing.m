//
//  GBCommentsProcessor+CodeBlockProcessing.m
//  appledoc
//
//  Created by Jody Hagins on 9/6/15.
//  Copyright (c) 2015 Gentle Bytes. All rights reserved.
//

#import "GBCommentsProcessor+CodeBlockProcessing.h"
#import <RegexKitLite/RegexKitLite.h>

@implementation GBCommentsProcessor (CodeBlockProcessing)

/**
 Fetch any source-code-block components from @a string

 This method will search @a string for any recognized source-code-blocks.  A block will be any text between doxygen style @code/@endcode markers or any text between markdown markers ``` or ~~~.

 This is not a top-level marker, and will be parsed from within another comment block.

 The beginning and ending markers must each be on a new line, with nothing else but whitespace on that line.

 @param string the text in which to search for source-code-blocks

 @return an array of dictionaries, where each dictionary contains six key-value pairs.

 - begin the token marking the beginning of the code block
 - end the token marking the end of the code block
 - prefix all the text before the start of the code block, including the line containing the begining marker
 - postfix all the text after the code block, including the line containing the ending marker
 - code all the text between the begining and ending markers
 - range the range for the code text, relative to the original @a string
 */
- (NSArray*)codeComponentsInString:(NSString*)string {
    NSString *pattern = @"\\r?\\n(([ \\t]*(~~~|```|@code)[ \\t]*)\\r?\\n[\\s\\S]*?\\r?\\n([ \\t]*(\\3|@endcode)[ \\t]*)\\r?\\n)";
    NSUInteger stringLength = [string length];
    NSRange searchRange = NSMakeRange(0, stringLength);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while (searchRange.length > 0) {
        NSArray *captured = [string captureComponentsMatchedByRegex:pattern range:searchRange];
        if ([captured count] > 0) {
            NSAssert([captured count] == 6, @"Match didn't produce right number of components");
            NSString *code = captured[1];
            NSRange codeRange = [string rangeOfString:code options:0 range:searchRange];
            NSAssert(codeRange.location != NSNotFound, @"Matched code string should be in original");

            NSString *begin = captured[3];
            NSString *end = captured[5];
            if (([begin isEqualToString:@"@code"] && [end isEqualToString:@"@endcode"]) || [begin isEqualToString:end]) {
                NSDictionary *component = @{@"code": code,
                                            @"prefix": captured[2],
                                            @"begin": begin,
                                            @"postfix": captured[4],
                                            @"end": end,
                                            @"range": [NSValue valueWithRange:codeRange]};
                [result addObject:component];
            }

            NSString *matchedString = captured[0];
            NSRange matchedRange = [string rangeOfString:matchedString options:0 range:searchRange];
            NSAssert(matchedRange.location != NSNotFound, @"Matched string should be in original");
            searchRange.location = matchedRange.location + matchedRange.length;
            searchRange.length = stringLength - searchRange.location;
        } else {
            searchRange = NSMakeRange(NSNotFound, 0);
        }
    }
    return result;    return [result copy];
}

/**
 Do the link component and the code component overlap?

 @param link a reference-link component
 @param a source-code-block component

 @return YES if the link component shares any text in common with the source-code-block component.
 */
- (BOOL)linkComponent:(NSDictionary*)link overlapsCodeComponent:(NSDictionary*)code {
    NSRange linkRange = [link[@"range"] rangeValue];
    NSUInteger linkBegin = linkRange.location;
    NSUInteger linkEnd = linkRange.location + linkRange.length;

    NSRange codeRange = [code[@"range"] rangeValue];
    NSUInteger codeBegin = codeRange.location;
    NSUInteger codeEnd = codeRange.location + codeRange.length;
    return (linkBegin >= codeBegin && linkBegin < codeEnd) || (linkEnd > codeBegin && linkEnd <= codeEnd);
}

/**
 Does the link component and any of the code components overlap?

 @param link a reference-link component
 @param codeComponents An array of source-code-block component

 @return YES if the link component shares any text in common with the source-code-block component.
 */
- (BOOL)linkComponent:(NSDictionary*)link overlapsAnyCodeComponent:(NSArray*)codeComponents {
    for (NSDictionary *code in codeComponents) {
        if ([self linkComponent:link overlapsCodeComponent:code]) {
            return YES;
        }
    }
    return NO;
}

/**
 Fetch any reference link components from @a string

 This method will search @a string for any recognized reference links - something roughly of the form [foo](bar).

 @param string the text in which to search for reference links
 @param codeComponents the source-code-block component that have already been found for this same @a string.  Any link found within the known soucre-code blocks will be ignored and not included in the resulting array of components.

 @return an array of dictionaries, where each dictionary contains two key-value pairs.

 - "link" all the text matching as a link reference
 - "range" the range for the link text, relative to the original @a string
 */
- (NSArray*)linkComponentsInString:(NSString*)string withCodeComponents:(NSArray*)codeComponents {
    static NSString *pattern;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *brackets = @"(?:\\[[^]]+?\\])";
        NSString *doubleBrackets = @"(?:\\[\\[[^]]+?\\]\\])";
        NSString *parens = @"(?:\\([^)\\s]+?(?:\\s*\"[^\"]+?\")*\\))";
        NSString *simpleLink = [NSString stringWithFormat:@"(?:!?(?:%@|%@)%@)", brackets, doubleBrackets, parens];
        NSString *nestedLink = [NSString stringWithFormat:@"(?:\\[%@\\]%@)", simpleLink, parens];
        pattern = [NSString stringWithFormat:@"(%@|%@)", nestedLink, simpleLink];
    });

    NSUInteger stringLength = [string length];
    NSRange searchRange = NSMakeRange(0, stringLength);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while (searchRange.length > 0) {
        NSRange found = [string rangeOfRegex:pattern inRange:searchRange];
        if (found.length) {
            searchRange.location = found.location + found.length;
            searchRange.length = stringLength - searchRange.location;
            NSDictionary *component = @{@"link":[string substringWithRange:found],
                                        @"range":[NSValue valueWithRange:found]};
            if (![self linkComponent:component overlapsAnyCodeComponent:codeComponents]) {
                [result addObject:component];
            }
        } else {
            searchRange = found;
        }
    }

    return result;
}

/**
 Merge the two sets of components so that they are in sorted order, relative to their range location

 @param codeComponents the array of soucrec-code-block components
 @param linkComponents the array of reference-link components

 @return An array containing both code and link components, sorted by range location
 */
- (NSArray*)mergeCodeComponents:(NSArray*)codeComponents linkComponents:(NSArray*)linkComponents {
    return [[codeComponents arrayByAddingObjectsFromArray:linkComponents] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSRange range1 = [[obj1 objectForKey:@"range"] rangeValue];
        NSRange range2 = [[obj2 objectForKey:@"range"] rangeValue];
        return (range1.location < range2.location
                ? NSOrderedAscending
                : (range1.location == range2.location
                   ? NSOrderedSame
                   : NSOrderedDescending));
    }];
}


// See header file for documenetation
- (NSArray*)codeAndLinkComponentsInString:(NSString*)string {
    NSArray *codeComponents = [self codeComponentsInString:string];
    NSArray *linkComponents = [self linkComponentsInString:string withCodeComponents:codeComponents];
    return [self mergeCodeComponents:codeComponents linkComponents:linkComponents];
}

@end
