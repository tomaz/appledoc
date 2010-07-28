//
//  GBClassData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBAdoptedProtocolsProvider.h"
#import "GBIvarsProvider.h"
#import "GBMethodsProvider.h"

/** Describes a class.
 */
@interface GBClassData : NSObject {
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

/** Merges the data from the given source class.
 
 The result is all information from both classes is merged into receiver, while source is left untouched.
 
 @warning *Note:* If the given source class name is different, an exception is thrown!
 
 @param source Source class to merge from.
 @exception NSException Thrown if the given source class name is different from receivers.
 */
- (void)mergeDataFromClass:(GBClassData *)source;

/** The name of the class. */
@property (readonly) NSString *nameOfClass;

/** The name of the superclass or `nil` if this is root class. */
@property (copy) NSString *nameOfSuperclass;

/** Class's adopted protocols, available via `GBAdoptedProtocolsProvider`. */
@property (readonly) GBAdoptedProtocolsProvider *adoptedProtocols;

/** Class's ivars, available via `GBIvarsProvider`. */
@property (readonly) GBIvarsProvider *ivars;

/** Class's methods, available via `GBMethodsProvider`. */
@property (readonly) GBMethodsProvider *methods;

@end
