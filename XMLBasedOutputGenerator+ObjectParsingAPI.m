//
//  XMLBasedOutputGenerator+ObjectParsingAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator+GeneralParsingAPI.h"
#import "XMLBasedOutputGenerator+ObjectParsingAPI.h"
#import "DoxygenConverter.h"

@implementation XMLBasedOutputGenerator (ObjectParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Info items parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectInfoItemRef:(id) item
{
	NSXMLNode* idAttr = [item attributeForName:@"id"];
	if (idAttr) return [idAttr stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectInfoItemValue:(id) item
{
	return [item stringValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Section parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectTaskName:(id) item
{
	NSXMLElement* nameNode = [self extractSubitemFromItem:item withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Members parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (int) extractObjectMemberType:(id) node
{
	NSXMLNode* kindAttr = [node attributeForName:@"kind"];
	if (kindAttr)
	{
		if ([[kindAttr stringValue] isEqualToString:@"class-method"])
			return kTKObjectMemberTypeClass;
		if ([[kindAttr stringValue] isEqualToString:@"instance-method"])
			return kTKObjectMemberTypeInstance;
	}
	return kTKObjectMemberTypeProperty;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectMemberName:(id) node
{
	NSXMLElement* nameNode = [self extractSubitemFromItem:node withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectMemberSelector:(id) node
{
	NSXMLElement* selectorNode = [self extractSubitemFromItem:node withName:@"selector"];
	if (selectorNode) return [selectorNode stringValue];
	return [self extractObjectMemberName:node];
}

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectMemberFile:(id) node
{
	NSXMLElement* fileNode = [self extractSubitemFromItem:node withName:@"file"];
	if (fileNode) return [fileNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (id) extractObjectMemberPrototypeItem:(id) node
{
	return [self extractSubitemFromItem:node withName:@"prototype"];
}

//----------------------------------------------------------------------------------------
- (id) extractObjectMemberDescriptionItem:(id) node
{
	return [self extractSubitemFromItem:node withName:@"description"];
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractObjectMemberSectionItems:(id) node
								  type:(int) type
{
	NSString* query = nil;
	switch (type)
	{
		case kTKObjectMemberSectionExceptions:
			query = @"exceptions/param";
			break;
		default:
			query = @"parameters/param";
			break;
	}
	NSArray* result = [node nodesForXPath:query error:nil];
	if ([result count] > 0) return result;
	return nil;
}

//----------------------------------------------------------------------------------------
- (id) extractObjectMemberReturnItem:(id) node
{
	return [self extractSubitemFromItem:node withName:@"return"];
}

//----------------------------------------------------------------------------------------
- (id) extractObjectMemberWarningItem:(id) node
{
	return [self extractSubitemFromItem:node withName:@"warning"];
}

//----------------------------------------------------------------------------------------
- (id) extractObjectMemberBugItem:(id) node
{
	return [self extractSubitemFromItem:node withName:@"bug"];
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractObjectMemberSeeAlsoItems:(id) node
{
	NSArray* itemNodes = [node nodesForXPath:@"seeAlso/item" error:nil];
	if ([itemNodes count] > 0) return itemNodes;
	return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Member prototype parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSArray*) extractObjectMemberPrototypeSubitems:(id) node
{
	return [node children];
}

//----------------------------------------------------------------------------------------
- (int) extractObjectMemberPrototypeItemType:(id) item
{
	NSXMLNode* node = (NSXMLNode*)item;
	if ([node kind] == NSXMLElementKind) return kTKObjectMemberPrototypeParameter;
	return kTKObjectMemberPrototypeValue;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectMemberPrototypeItemValue:(id) item
{
	return [item stringValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parameter parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractObjectParameterName:(id) node
{
	NSXMLElement* nameNode = [self extractSubitemFromItem:node withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (id) extractObjectParameterDescriptionNode:(id) node
{
	return [self extractSubitemFromItem:node withName:@"description"];
}

@end