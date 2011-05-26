//
//  GBSourceInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Specifies declared file data for store object.
 
 Declared file provides information about where an object was declared - i.e. source file name and line number. This can be used for generating output and for diagnostics and as debug information.
 */
@interface GBSourceInfo : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBSourceInfo` with the given values.
 
 @param filename The name of the file including full path.
 @param lineNumber Line number within the file.
 @return Returns autoreleased object.
 @exception NSException Thrown if the given filename is `nil` or empty string.
 */
+ (id)infoWithFilename:(NSString *)filename lineNumber:(NSUInteger)lineNumber;

///---------------------------------------------------------------------------------------
/// @name Data handling
///---------------------------------------------------------------------------------------

/** Returns an `NSComparisonResult` value that indicates whether the receiver is greater than, equal to, or less than a given _data_.
 
 Comparison is done over the `filename` first. If the `filename` is the same, `lineNumber` is compared.
 
 @warning *Important:* Note that the given _data_ must not be `nil`. The behavior is undefined in such case!
 
 @param data `GBSourceInfo` to compare with.
 @return `NSOrderedAscending` if the value of _data_ is greater than the receiver, `NSOrderedSame` if they’re equal, and `NSOrderedDescending` if the _data_ is less than the receiver.
 */
- (NSComparisonResult)compare:(GBSourceInfo *)data;

/** Full path to the file name.
 
 @see filename
 */
@property (readonly, copy) NSString *fullpath;

/** The name of the file, without path.
 
 @see lineNumber
 */
@property (readonly, copy) NSString *filename;

/** The number of the line within the file.
 
 @see filename
 */
@property (readonly, assign) NSUInteger lineNumber;

@end
