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
 
 - Prefix and suffix must not contain any capturing components as this will break matching code (you can still include groups, but make sure any open parenthesis is marked as non-capturing like this: `(?:...)`!
 - Prefix must not contain any marker used for formatting such as *, _ or combinations. This is actually not checked, but in such case results may be not what you wanted.
 
 @warning *Important:* Note that the given string must contain exactly one `%@` marker. If none is included cross references will not be matched during runtime. If more than one is included, unpredicted behavior may occur. So take care!
 
 @warning *Important:* This value must be set before accessing any cross reference regex property! The accessors prepare and cache the value on first usage. From then on, cached value is returned, so any change is not propagated!
 */
@property (copy) NSString *crossReferenceMarkersTemplate;

///---------------------------------------------------------------------------------------
/// @name Sections definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching warning section with capture 1 containing directive and capture 2 description text. */
@property (readonly) NSString *warningSectionRegex;

/** Returns the regex used for matching bug section with capture 1 containing directive and capture 2 description text. */
@property (readonly) NSString *bugSectionRegex;

/** Returns the regex used for matching deprecated section with capture 1 containing directive and capture 2 description text. */
@property (readonly) NSString *deprecatedSectionRegex;

/** Returns the regex used for matching note section with capture 1 containing directive and capture 2 description text. */
@property (readonly) NSString *noteSectionRegex;


///---------------------------------------------------------------------------------------
/// @name Method specific definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching method groups with capture 1 containing section name. */
@property (readonly) NSString *methodGroupRegex;

/** Returns the regex used for matching method parameter description with capture 1 containing directive, capture 2 parameter name and capture 3 description text. */
@property (readonly) NSString *parameterDescriptionRegex;

/** Returns the regex used for matching method return description with capture 1 containing directive and capture 2 description text. */
@property (readonly) NSString *returnDescriptionRegex;

/** Returns the regex used for matching method exception description with capture 1 containing directive, capture 2 exception name and capture 3 description text. */
@property (readonly) NSString *exceptionDescriptionRegex;

/** Returns the regex used for matching cross reference directive with capture 1 containing directive, capture 3 link. */
@property (readonly) NSString *relatedSymbolRegex;

/** Returns the regex used for matching cross reference directive with capture 1 containing directive, capture 2 description text. */
@property (readonly) NSString *availabilityRegex;

@property (readonly) NSString *abstractRegex;
@property (readonly) NSString *discussionRegex;

///---------------------------------------------------------------------------------------
/// @name Markdown specific definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching Markdown inline style links with capture 1 containing link description part without brackets, 2 the address and 3 optional title.
 
 Here's a diagram of captures for better orientation:
 
	[ description ]( address " title " )
	  ^^^^^^^^^^^    ^^^^^^^   ^^^^^
	   |              |         |
	   |              |         +-- capture3
	   |              +-- capture2
	   +-- capture1
 
 @see markdownReferenceLinkRegex
 */
@property (readonly) NSString *markdownInlineLinkRegex;

/** Returns the regex used for matching Markdown reference style links with capture 1 reference ID, 2 address and 3 optional title.
 
 Here's a diagram of captures for better orientation:
 
	[ ID ]: address " title "
	  ^^    ^^^^^^^   ^^^^^
	  |      |         |
	  |      |         +-- capture3
	  |      +-- capture2
	  +-- capture1
 
 @see markdownInlineLinkRegex
 */
@property (readonly) NSString *markdownReferenceLinkRegex;

///---------------------------------------------------------------------------------------
/// @name Cross references definitions
///---------------------------------------------------------------------------------------

/** Returns the regex used for matching (possible) remote member cross references with capture 1 containing optional - or + prefix, capture 2 object name and capture 3 member selector. 
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)remoteMemberCrossReferenceRegex:(BOOL)templated;

/** Returns the regex used for matching (possible) local member cross reference with capture 1 containing optional - or + prefix and capture 2 member selector.
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)localMemberCrossReferenceRegex:(BOOL)templated;

/** Returns the regex used for matching (possible) category cross reference with capture 1 containing category name.
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)categoryCrossReferenceRegex:(BOOL)templated;

/** Returns the regex used for matching (possible) class or protocol cross reference with capture 1 containing object name.
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)objectCrossReferenceRegex:(BOOL)templated;

/** Returns the regex used for matching (possible) static document cross reference with capture 1 containing document name.
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)documentCrossReferenceRegex:(BOOL)templated;

/** Returns the regex used for matching URL cross reference with caption 1 contining the URL itself.
 
 The result of the method depends on the templated value: if the value is `YES`, the string includes template from `crossReferenceMarkersTemplate`, otherwise it only contains "pure" regex. The first option should be used for in-text cross references detection, while the second for `crossReferenceRegex` matching.
 
 @param templated If `YES` templated regex is returned, otherwise pure one.
 @return Returns the regex used for matching cross reference.
 */
- (NSString *)urlCrossReferenceRegex:(BOOL)templated;

///---------------------------------------------------------------------------------------
/// @name Common definitions
///---------------------------------------------------------------------------------------

/** Returns the regex containing all possible symbols for matching new lines. */
@property (readonly) NSString *newLineRegex;

/** Our custom code span start marker. */
@property (readonly) NSString *codeSpanStartMarker;

/** Our custom code span end marker. */
@property (readonly) NSString *codeSpanEndMarker;

/** Our custom appledoc style bold start marker. */
@property (readonly) NSString *appledocBoldStartMarker;

/** Our custom appledoc style bold end marker. */
@property (readonly) NSString *appledocBoldEndMarker;

@end
