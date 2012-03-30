//
//  StoreConstants.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/30/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Defines various store types.
 
 Note that types are defined as Objective C objects solely because it makes unit testing less verbose (i.e. OCMOCK_ANY instead of declaring a variable and using OCMOCK_VALUE on it).
 */
extern const struct GBStoreTypes {
	__unsafe_unretained NSString *classMethod;	///< The object is a static method.
	__unsafe_unretained NSString *instanceMethod;	///< The object is an instance method.
} GBStoreTypes;
