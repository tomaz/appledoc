//
//  GBIvarData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

/** Describes an ivar */
@interface GBIvarData : GBModelBase

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the ivar data from given array of components.
 
 Components array should contain all ivar type tokens and ivar name as the last entry. Types are copied to `ivarTypes` property
 and name to `ivarName` property.
 
 @param components Components array to setup the data from.
 @return Returns initialized instance.
 @exception NSException Thrown if the given array of components is `nil` or has only one entry.
 */
+ (id)ivarDataWithComponents:(NSArray *)components;

/** Initializes the ivar data from given array of components.

 Components array should contain all ivar type tokens and ivar name as the last entry. Types are copied to `ivarTypes` property
 and name to `ivarName` property.
 
 @param components Components array to setup the data from.
 @return Returns initialized instance.
 @exception NSException Thrown if the given array of components is `nil` or has only one entry.
 */
- (id)initWithDataFromComponents:(NSArray *)components;

///---------------------------------------------------------------------------------------
/// @name Ivar data
///---------------------------------------------------------------------------------------

/** Merges the data from the given source ivar.
 
 The result is all information from both ivars is merged into receiver, while source is left untouched.
 
 @warning *Note:* If the given source ivar name or types are different, an exception is thrown!
 
 @param source Source ivar to merge from.
 @exception NSException Thrown if the given source ivar name or types are different from receivers.
 */
- (void)mergeDataFromIvar:(GBIvarData *)source;

/** The name of the ivar. */
@property (retain) NSString *nameOfIvar;

/** The array of all ivar type tokens in the order of parsing. */
@property (retain) NSArray *ivarTypes;

@end
