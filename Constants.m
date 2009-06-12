//
//  Constants.m
//  appledoc
//
//  Created by Tomaz Kragelj on 12.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "Constants.h"

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Exception names
//////////////////////////////////////////////////////////////////////////////////////////

NSString* kTKConverterException				= @"TKConverterException";

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Placeholder strings
//////////////////////////////////////////////////////////////////////////////////////////

NSString* kTKPlaceholderExtension			= @"$EXTENSION";

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Common directory structure
//////////////////////////////////////////////////////////////////////////////////////////

NSString* kTKDirClasses						= @"Classes";
NSString* kTKDirCategories					= @"Categories";
NSString* kTKDirProtocols					= @"Protocols";
NSString* kTKDirCSS							= @"css";
NSString* kTKDirDocSet						= @"docset";

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Database keys
//////////////////////////////////////////////////////////////////////////////////////////

NSString* kTKDataMainIndexKey				= @"Index";					// NSXMLDocument
NSString* kTKDataMainHierarchyKey			= @"Hierarchy";				// NSXMLDocument
NSString* kTKDataMainHierarchiesKey			= @"Hierarchies";			// NSDictionary
NSString* kTKDataMainObjectsKey				= @"Objects";				// NSDictionary
NSString* kTKDataMainDirectoriesKey			= @"Directories";			// NSDictionary

NSString* kTKDataHierarchyObjectNameKey		= @"ObjectName";			// NSString
NSString* kTKDataHierarchyObjectDataKey		= @"ObjectData";			// NSDictionary
NSString* kTKDataHierarchyChildrenKey		= @"Children";				// NSString
NSString* kTKDataHierarchyTempKey			= @"TEMPORARY";				// NSNumber / BOOL

NSString* kTKDataObjectNameKey				= @"ObjectName";			// NSString
NSString* kTKDataObjectKindKey				= @"ObjectKind";			// NSString
NSString* kTKDataObjectClassKey				= @"ObjectClass";			// NSString
NSString* kTKDataObjectMarkupKey			= @"CleanedMarkup";			// NSXMLDocument
NSString* kTKDataObjectMembersKey			= @"Members";				// NSDictionary
NSString* kTKDataObjectParentKey			= @"Parent";				// NSString
NSString* kTKDataObjectRelDirectoryKey		= @"RelativeDirectory";		// NSString
NSString* kTKDataObjectRelPathKey			= @"RelativePath";			// NSString
NSString* kTKDataObjectDoxygenFilenameKey	= @"DoxygenMarkupFilename";	// NSString

NSString* kTKDataMemberNameKey				= @"Name";					// NSString
NSString* kTKDataMemberPrefixKey			= @"Prefix";				// NSString
NSString* kTKDataMemberSelectorKey			= @"Selector";				// NSString
