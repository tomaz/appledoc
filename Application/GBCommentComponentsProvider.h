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

/** Determines if the given string defines a warning section.
 
 Warning sections are specially formatted paragraphs that are emphasized so the user can quickly see them. They are similar to bugs, but are formatted to be less apparent to the user.
 
 Syntactically warnings are part of previous paragraph, or if no paragraph is defined, they are contained in their own paragraph. They can be composed from any number of lines and end with an empty line. They are only identified when the warning keyword is found on the start of the line. Warning description requires a single argument - a paragraph containing bug description - which can be separated with any whitespace.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a warning, `NO` otherwise.
 @see stringDefinesBug:
 */
- (BOOL)stringDefinesWarning:(NSString *)string;

/** Determines if the given string defines a bug section.
 
 Bug sections define specially formatted parts that are emphasized so the user can quickly see them. They are similar to warnings but are formatted to be more apparent to the user.
 
 Syntacticaly bugs are part of previous paragraph, or if no paragraph is defined, they are contained in their own paragraph. They can be composed from any number of lines and end with an empty line. They are only identified when the bug keyword is found on the start of the line. Bug description requires a single argument - a paragraph containing bug description - which can be separated with any whitespace.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a bug, `NO` otherwise.
 @see stringDefinesWarning:
 */
- (BOOL)stringDefinesBug:(NSString *)string;

/** Determines if the given string defines method parameter description.
 
 Each parameter description describes individual method parameter. It is only applicable for methods with arguments.
 
 Parameter description requires two arguments separated by whitespace or newline: first argument is parameter name, second is a paragraph describing the parameter. Arguments can be separated by any whitespace.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a parameter, `NO` otherwise.
 @see stringDefinesReturn:
 @see stringDefinesException:
 @see stringDefinesCrossReference:
 */
- (BOOL)stringDefinesParameter:(NSString *)string;

/** Determines if the given string defines method return description.
 
 Return description describes method return value. It is only applicable for methods with results.
 
 Result description requires a single arguments - a paragraph containing result value description - which can be separeted with any whitespace.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a return, `NO` otherwise.
 @see stringDefinesParameter:
 @see stringDefinesException:
 @see stringDefinesCrossReference:
 */
- (BOOL)stringDefinesReturn:(NSString *)string;

/** Determines if the given string defines method exception description.
 
 Each exception description describes a possible exception thrown by the method. It is only applicable for methods.
 
 Exception description requires two arguments separated by whitespace or newline: first argument is the name of the exception class (although this can be anything as it's not validated), second is a paragraph describing the conditions which lead to exception. Arguments can be separated by any whitespace.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a parameter, `NO` otherwise.
 @see stringDefinesParameter:
 @see stringDefinesReturn:
 @see stringDefinesCrossReference:
 */
- (BOOL)stringDefinesException:(NSString *)string;

/** Determines if the given string defines cross reference link.
 
 Cross reference links can be used to provide links to other documented entities or their methods.
 
 Cross reference description requires a single parameter - the link description - which can be separated with whitespace or newline. There are several possible cross-reference link types:
 
 - Links to other classes or protocols: Write the name of the class or protocol. Example `GBApplicationSettingsProvider`.
 - Links to other categories: Write the name of the class, followed by name of category within parenthesis without any whitespace. Example `NSObject(GBObject)`.
 - Links to methods or properties of the same object: Write method selector or property accessor. Example `stringDefinesException:`.
 
 @param string The string to check, ussually a single line from a comment.
 @return Returns `YES` if given string defines a parameter, `NO` otherwise.
 @see stringDefinesParameter:
 @see stringDefinesReturn:
 @see stringDefinesException:
 */
- (BOOL)stringDefinesCrossReference:(NSString *)string;

@end
