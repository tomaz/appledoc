//
//  GBCommentKeywordsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBApplicationSettingsProvider;

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
/// @name Parameters
///---------------------------------------------------------------------------------------

/** Sets cross reference markers.
 
 The given string should include optional prefix, followed by `%@` and lastly optional suffix. If either prefix or suffix isn't allowed, just pass `%@`. At the runtime, `%@` is replaced by the actual regex for mathching particular cross reference type - actually the whole string becomes the regex for matching cross reference, therefore prefix and suffix can be arbitrary regex expressions themselves! On the other hand, this imposes some limitations to what can be used for them: 
 
 - Prefix and suffix must not contain any capturing components as this will break matching code (you can still include groups, but make sure any open parenthesis is marked as non-capturing like this: `(?`!
 - Prefix must not contain any marker used for formatting such as *, _ or combinations. This is actually not checked, but in such case results may be not what you wanted.
 
 @warning *Important:* Failing to include `%@` string in the markers or including the string more than once, will result in run time exception!
 
 @warning *Important:* This message must be sent before accessing any cross reference regex property! The accessors prepare and cache the value on first usage. From then on, cached value is returned, so any change is not propagated!
 
 @param string The string containing cross reference markers.
 @exception NSException Raised if the given string doesn't contain `%@` string.
 */
- (void)setCrossReferenceMarkers:(NSString *)string;

///---------------------------------------------------------------------------------------
/// @name Lists definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching ordered lists with capture 1 containing lists indent and capture 2 string value. */
@property (readonly) NSString *orderedListRegex;

/** Returns the regex used for matching unordered lists with capture 1 containing list indent and capture 2 string value. */
@property (readonly) NSString *unorderedListRegex;

///---------------------------------------------------------------------------------------
/// @name Sections definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching warning section with capture 1 containing description. */
@property (readonly) NSString *warningSectionRegex;

/** Returns the regex used for matching bug section with capture 1 containing description. */
@property (readonly) NSString *bugSectionRegex;

/** Returns the regex used for matching example section with capture 1 containing whitespace prefix and capture 2 example text. */
@property (readonly) NSString *exampleSectionRegex;

///---------------------------------------------------------------------------------------
/// @name Method specific definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching method groups with capture 1 containing section name. */
@property (readonly) NSString *methodGroupRegex;

/** Returns the regex used for matching different method parameter descriptions within the paragraph. */
@property (readonly) NSString *argumentsMatchingRegex;

/** Returns the regex used for finding next method parameter description within the paragraph. */
@property (readonly) NSString *nextArgumentRegex;

/** Returns the regex used for matching method parameter description with capture 1 containing parameter name and capture 2 description. */
@property (readonly) NSString *parameterDescriptionRegex;

/** Returns the regex used for matching method return description with capture 1 containing description. */
@property (readonly) NSString *returnDescriptionRegex;

/** Returns the regex used for matching method exception description with capture 1 containing exception name and capture 2 description. */
@property (readonly) NSString *exceptionDescriptionRegex;

/** Returns the regex used for matching cross reference directive with capture 1 containing link. */
@property (readonly) NSString *crossReferenceRegex;

///---------------------------------------------------------------------------------------
/// @name Cross references definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching (possible) remote member cross references with capture 1 containing object name and capture 2 member name. */
@property (readonly) NSString *remoteMemberCrossReferenceRegex;

/** Returns the regex used for matching (possible) local member cross reference with capture 1 containing member name. */
@property (readonly) NSString *localMemberCrossReferenceRegex;

/** Returns the regex used for matching (possible) category cross reference with capture 1 containing category name. */
@property (readonly) NSString *categoryCrossReferenceRegex;

/** Returns the regex used for matching (possible) class or protocol cross reference with capture 1 containing object name. */
@property (readonly) NSString *objectCrossReferenceRegex;

/** Returns the regex used for matching URL cross reference with caption 1 contining the URL itself. */
@property (readonly) NSString *urlCrossReferenceRegex;

///---------------------------------------------------------------------------------------
/// @name Common definitions
///---------------------------------------------------------------------------------------

/** Returns the regex containing all possible symbols for matching new lines. */
@property (readonly) NSString *newLineRegex;

@end
