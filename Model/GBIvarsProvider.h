//
//  GBIvarsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBIvarData;

/** A helper class that unifies ivars handling.
 
 Dividing implementation of ivars provider to a separate class allows us to abstract the logic and reuse it within any object that needs to handle ivars using composition. This breaks down the code into simpler and more managable chunks. It also simplifies ivars parsing and handling. To use the class, simply "plug" it to the class that needs to handle ivars and provide access through public interface.
 
 The downside is that querrying code becomes a bit more verbose as another method or property needs to be sent before getting access to actual ivars data.
 */
@interface GBIvarsProvider : NSObject {
	@private
	NSMutableArray *_ivars;
	NSMutableDictionary *_ivarsByName;
	id _parent;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes ivars provider with the given parent object.
 
 The given parent object is set to each `GBIvarData` registered through `registerIvar:`. This is the designated initializer.
 
 @param parent The parent object to be used for all registered ivars.
 @return Returns initialized object.
 @exception NSException Thrown if the given parent is `nil`.
 */
- (id)initWithParentObject:(id)parent;

///---------------------------------------------------------------------------------------
/// @name Ivars handling
///---------------------------------------------------------------------------------------

/** Registers the given ivar to the providers data.
 
 If provider doesn't yet have the given ivar instance registered, the object is added to `ivars` list. If the same object is already registered, nothing happens.
 
 @warning *Note:* If another instance of the ivar with the same name is registered, an exception is thrown.
 
 @param ivar The ivar to register.
 @exception NSException Thrown if the given ivar is already registered.
 */
- (void)registerIvar:(GBIvarData *)ivar;

/** Merges data from the given ivars provider.
 
 This copies all unknown ivars from the given source to receiver and invokes merging of data for receivers ivars also found in source. It leaves source data intact.
 
 @param source `GBIvarsProvider` to merge from.
 */
- (void)mergeDataFromIvarsProvider:(GBIvarsProvider *)source;

/** The array of all registered ivars as `GBIvarData` instances in the order of registration. */
@property (readonly) NSArray *ivars;

@end
