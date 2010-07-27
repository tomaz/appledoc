//
//  GBCategoryData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBAdoptedProtocolsProvider.h"
#import "GBMethodsProvider.h"

/** Describes a category.
 */
@interface GBCategoryData : NSObject {
	@private
	NSString *_categoryName;
	NSString *_className;
	GBAdoptedProtocolsProvider *_adoptedProtocols;
	GBMethodsProvider *_methods;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the category data with the given data.
 
 @param name The name of the category or `nil` if this is extension.
 @param className The name of the class the category extends.
 @return Returns initialized object.
 @exception NSException Thrown if the given class name is `nil` or empty.
 */
+ (id)categoryDataWithName:(NSString *)name className:(NSString *)className;

/** Initializes the category with the given name.
 
 This is the designated initializer.
 
 @param name The name of the category.
 @param className The name of the class the category extends.
 @return Returns initialized object.
 @exception NSException Thrown if the given class name is `nil` or empty.
 */
- (id)initWithName:(NSString *)name className:(NSString *)className;

///---------------------------------------------------------------------------------------
/// @name Class data
///---------------------------------------------------------------------------------------

/** Determines whether this category is extension or not. */
@property (readonly) BOOL isExtension;

/** The name of the category or `nil` if this is an extension. */
@property (readonly) NSString *categoryName;

/** The name of the class the category extends. */
@property (readonly) NSString *className;

/** Categories adopted protocols, available via `GBAdoptedProtocolsProvider`. */
@property (readonly) GBAdoptedProtocolsProvider *adoptedProtocols;

/** Categories methods, available via `GBMethodsProvider`. */
@property (readonly) GBMethodsProvider *methods;

@end
