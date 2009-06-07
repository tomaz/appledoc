//
//  OutputGenerator+ObjectSubclassAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "OutputGenerator+ObjectSubclassAPI.h"
#import "DoxygenConverter.h"

@implementation OutputGenerator (ObjectSubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark File header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectFooterToData:(NSMutableData*) data
{	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object info section handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoItemToData:(NSMutableData*) data
						  fromItems:(NSArray*) items
							  index:(int) index
							   type:(int) type
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object overview section handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectOverviewToData:(NSMutableData*) data 
						   fromItem:(id) item;
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object sections handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskHeaderToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskFooterToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskMemberToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object members main documentation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectMembersHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMembersFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupHeaderToData:(NSMutableData*) data 
										type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupFooterToData:(NSMutableData*) data 
										type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberToData:(NSMutableData*) data 
						 fromItem:(id) item 
							index:(int) index
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) objectTitle
{
	return [NSString stringWithFormat:@"%@ %@ reference", 
			self.objectName, 
			self.objectKind];
}

//----------------------------------------------------------------------------------------
- (NSString*) objectName
{
	return [objectData objectForKey:kTKDataObjectNameKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) objectKind
{
	return [objectData objectForKey:kTKDataObjectKindKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) objectClass
{
	return [objectData objectForKey:kTKDataObjectClassKey];
}

//----------------------------------------------------------------------------------------
- (NSXMLDocument*) objectMarkup
{
	return objectMarkup;
}

//----------------------------------------------------------------------------------------
- (NSString*) objectRelativeDir
{
	return [objectData objectForKey:kTKDataObjectRelDirectoryKey];
}

//----------------------------------------------------------------------------------------
- (NSString*) objectRelativePath
{
	return [objectData objectForKey:kTKDataObjectRelPathKey];
}

@end