//
//  GBApplicationStringsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Provides static strings and string templates for the rest of the application.
 
 The main purpose of this class is to serve as an entry point for static strings used for output generation. This allows us to provide simple way of handling translations. The class is intended to be used as is - just pass it over to `GBTemplateWriter` and make sure template files use proper key paths.
 */
@interface GBApplicationStringsProvider : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBApplicationStringsProvider` instance.
 */
+ (id)provider;

///---------------------------------------------------------------------------------------
/// @name Object output strings
///---------------------------------------------------------------------------------------

/** Strings used for generating common page strings for objects. */
@property (readonly) NSDictionary *objectPage;

/** Strings used for generating specification sections for objects. */
@property (readonly) NSDictionary *objectSpecifications;

/** Strings used for generating overview section for objects. */
@property (readonly) NSDictionary *objectOverview;

/** Strings used for generating tasks section for objects. */
@property (readonly) NSDictionary *objectTasks;

/** Strings used for generating methods sections for objects. */
@property (readonly) NSDictionary *objectMethods;

///---------------------------------------------------------------------------------------
/// @name Document output strings
///---------------------------------------------------------------------------------------

/** Strings used for generating common page strings for static documents. */
@property (readonly) NSDictionary *documentPage;

///---------------------------------------------------------------------------------------
/// @name Index output strings
///---------------------------------------------------------------------------------------

/** Strings used for generating common page strings for index. */
@property (readonly) NSDictionary *indexPage;

/** Strings used for generating common page strings for hierarchy. */
@property (readonly) NSDictionary *hierarchyPage;

///---------------------------------------------------------------------------------------
/// @name DocSet output strings
///---------------------------------------------------------------------------------------

/** Strings used for generating common page strings for documentation set. */
@property (readonly) NSDictionary *docset;

///---------------------------------------------------------------------------------------
/// @name Common strings
///---------------------------------------------------------------------------------------

/** Strings used for appledoc related data. */
@property (readonly) NSDictionary *appledocData;


@end
