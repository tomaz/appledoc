//
//  GBCommentKeywordsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Provides comment keywords and helpers for the rest of the application.
 
 The main responsibility of the class is to determine if a string contains special section definition. In addition, they also return section parameters. This encapsulates keywords and sections handling and simplifies the rest of the application.
 */
@interface GBCommentComponentsProvider : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBCommentComponentsProvider` instance.
 */
+ (id)provider;

///---------------------------------------------------------------------------------------
/// @name Sections testing
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching ordered lists with capture 1 containing list text. */
@property (readonly) NSString *orderedListRegex;

/** Returns the regex used for matching ordered list prefix. */
@property (readonly) NSString *orderedListPrefixRegex;

/** Returns the regex used for matching unordered lists with capture 1 containing list text. */
@property (readonly) NSString *unorderedListRegex;

/** Returns the regex used for matching unordered list prefix. */
@property (readonly) NSString *unorderedListPrefixRegex;

/** Returns the regex used for matching warning section with capture 1 containing description. */
@property (readonly) NSString *warningSectionRegex;

/** Returns the regex used for matching bug section with capture 1 containing description. */
@property (readonly) NSString *bugSectionRegex;

/** Returns the regex used for matching example section with capture 1 containing example text. */
@property (readonly) NSString *exampleSectionRegex;

/** Returns the regex used for matching example lines with capture 1 containing example lines texts. */
@property (readonly) NSString *exampleLinesRegex;

/** Returns the regex used for matching method parameter description with capture 1 containing parameter name and capture 2 description. */
@property (readonly) NSString *parameterDescriptionRegex;

/** Returns the regex used for matching method return description with capture 1 containing description. */
@property (readonly) NSString *returnDescriptionRegex;

/** Returns the regex used for matching method exception description with capture 1 containing exception name and capture 2 description. */
@property (readonly) NSString *exceptionDescriptionRegex;

/** Returns the regex used for matching cross reference directive with capture 2 containing link. */
@property (readonly) NSString *crossReferenceRegex;

@end
