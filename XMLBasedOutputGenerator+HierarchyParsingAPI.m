//
//  XMLBasedOutputGenerator+HierarchyParsingAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator+GeneralParsingAPI.h"
#import "XMLBasedOutputGenerator+HierarchyParsingAPI.h"
#import "DoxygenConverter.h"

@implementation XMLBasedOutputGenerator (HierarchyParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Hierarchy items parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractHierarchyGroupItemRef:(id) item
{
	NSXMLNode* idAttr = [item attributeForName:@"id"];
	if (idAttr) return [idAttr stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractHierarchyGroupItemName:(id) item
{
	NSXMLElement* nameNode = [self extractSubitemFromItem:item withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return @"";
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractHierarchyGroupItemChildren:(id) item
{
	NSArray* childrenNodes = [item nodesForXPath:@"children/object" error:nil];
	if ([childrenNodes count] > 0) return childrenNodes;
	return nil;
}

@end