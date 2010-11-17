//
//  NSString+GBString.h
//  appledoc
//
//  Created by Tomaz Kragelj on 31.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Provides string extensions that make the rest of parsing code simpler. */
@interface NSString (GBString)

///---------------------------------------------------------------------------------------
/// @name Simplifying strings
///---------------------------------------------------------------------------------------

/** Trims all characters from the given set from the string end.
 
 Works the same way as `[NSString stringByTrimmingCharactersInSetFromEnd:]` except it trims from end only.
 
 @param set The set of characters to trim.
 @return Returns trimmed string.
 @exception NSException Thrown if the given set is `nil`.
 */
- (NSString *)stringByTrimmingCharactersInSetFromEnd:(NSCharacterSet *)set;

/** Splits the string to words and returns all words separed by single space.
 
 @return Returns wordified string.
 */
- (NSString *)stringByWordifyingWithSpaces;

/** Trims all whitespace from the start and end of the string and returns trimmed value.
 
 @return Returns trimmed string.
 */
- (NSString *)stringByTrimmingWhitespace;

///---------------------------------------------------------------------------------------
/// @name Preparing nice descriptions
///---------------------------------------------------------------------------------------

/** Returns normalized description from the receiver.
 
 The main purpose of this method is to strip and wordifiy long descriptions by making them suitable for logging and debug messages.
 
 @return Returns stripped description.
 @see normalizedDescriptionWithMaxLength:
 @see maxNormalizedDescriptionLength
 */
- (NSString *)normalizedDescription;

/** Returns normalized description from the receiver.
 
 The main purpose of this method is to strip and wordifiy long descriptions by making them suitable for logging and debug messages.
  
 @param length Maximum length of the description.
 @return Returns stripped description.
 @see normalizedDescriptionWithMaxLength:
 @see maxNormalizedDescriptionLength
 */
- (NSString *)normalizedDescriptionWithMaxLength:(NSUInteger)length;

/** Returns default maximum length of normalized string.
 */
+ (NSUInteger)defaultNormalizedDescriptionLength;

///---------------------------------------------------------------------------------------
/// @name Getting information
///---------------------------------------------------------------------------------------

/** Returns the number of all lines in the receiver.
 
 @return Returns the number of all lines in the receiver.
 @see numberOfLinesInRange:
 */
- (NSUInteger)numberOfLines;

/** Calculates the numer of lines in the given range of the receiver.
 
 @param range The range to use for calculation.
 @return Returns the number of lines in the given range.
 @exception NSException Thrown if the given range is invalid.
 @see numberOfLines
 */
- (NSUInteger)numberOfLinesInRange:(NSRange)range;

@end
