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

/** Returns normalized description from the receiver.
 
 The main purpose of this method is to strip and wordifiy long descriptions by making them suitable for logging and debug messages.
 
 @param string String to strip.
 @return Returns stripped description.
 @see normalizedDescriptionFromString:
 @see maxNormalizedDescriptionLength
 */
- (NSString *)normalizedDescription;

/** Returns normalized description from the given string.
 
 The main purpose of this method is to strip and wordifiy long descriptions by making them suitable for logging and debug messages.
 
 @param string String to strip.
 @return Returns stripped description.
 @see normalizedDescription
 @see maxNormalizedDescriptionLength
 */
+ (NSString *)normalizedDescriptionFromString:(NSString *)string;

/** Returns maximum length of normalized string.
 */
+ (NSUInteger)maxNormalizedDescriptionLength;

@end
