//
//  GBClassData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"

@class GBAdoptedProtocolsProvider;
@class GBIvarsProvider;
@class GBMethodsProvider;

/** Describes a class.
 */
@interface GBClassData : GBModelBase <GBObjectDataProviding> {
	@private
	NSString *_className;
	GBAdoptedProtocolsProvider *_adoptedProtocols;
	GBIvarsProvider *_ivars;
	GBMethodsProvider *_methods;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the class data with the given name.
 
 @param name The name of the class.
 @return Returns initialized object.
 @exception NSException Thrown if the given name is `nil` or empty.
 */
+ (id)classDataWithName:(NSString *)name;

/** Initializes the class with the given name.
 
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
@property (readonly) NSString *nameOfClass;

/** The name of the superclass or `nil` if this is root class. */
@property (copy) NSString *nameOfSuperclass;

/** Superclass object if known object or `nil` if `nameOfSuperclass` is `nil` or doesn't point to a known class. */
@property (strong) GBClassData *superclass;

/** Class's adopted protocols, available via `GBAdoptedProtocolsProvider`. */
@property (readonly) GBAdoptedProtocolsProvider *adoptedProtocols;

/** Class's ivars, available via `GBIvarsProvider`. */
@property (readonly) GBIvarsProvider *ivars;

/** Class's methods, available via `GBMethodsProvider`. */
@property (readonly) GBMethodsProvider *methods;

@end
