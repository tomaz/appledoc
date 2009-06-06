//
//  GeneratorBase+HierarchySubclassAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "GeneratorBase+HierarchySubclassAPI.h"
#import "DoxygenConverter.h"

@implementation GeneratorBase (HierarchySubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark File header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHierarchyHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyFooterToData:(NSMutableData*) data
{	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Group handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupItemToData:(NSMutableData*) data
							   fromItem:(id) item
								  index:(int) index
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) generateHierarchyGroupChildrenToData:(NSMutableData*) data
									  forItem:(id) item
{
	NSArray* childrenNodes = [item nodesForXPath:@"children/object" error:nil];
	if ([childrenNodes count] > 0)
	{
		[self appendHierarchyGroupHeaderToData:data];
		for (int i = 0; i < [childrenNodes count]; i++)
		{
			NSXMLElement* childNode = [childrenNodes objectAtIndex:i];
			[self appendHierarchyGroupItemToData:data 
										fromItem:childNode 
										   index:i];
		}
		[self appendHierarchyGroupFooterToData:data];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) hierarchyTitle
{
	NSString* project =
		(self.projectName != nil && [self.projectName length] > 0) ?
		self.projectName : @"Project";
	return [NSString stringWithFormat:@"%@ hierarchy", project];
}

//----------------------------------------------------------------------------------------
- (NSXMLDocument*) hierarchyMarkup
{
	return hierarchyMarkup;
}

@end