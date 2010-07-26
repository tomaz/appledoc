//
//  GBClassData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Describes a class.
 */
@interface GBClassData : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes the class with he given name.
 
 This is the designated initializer.
 
 @param name The name of the class.
 @return Returns initialized object.
 @exception NSException Thrown if the given name is `nil` or empty.
 */
- (id)initWithName:(NSString *)name;

///---------------------------------------------------------------------------------------
/// @name Class data
///---------------------------------------------------------------------------------------

/** The name of the class. */
@property (readonly, copy) NSString *className;

/** The name of the superclass or `nil` if this is root class. */
@property (readonly, copy) NSString *superclassName;

@end
