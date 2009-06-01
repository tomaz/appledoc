//
//  GeneratorBase+PrivateAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "GeneratorBase+PrivateAPI.h"
#import "DoxygenConverter.h"

@implementation GeneratorBase (PrivateAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Section parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractSectionName:(NSXMLElement*) node
{
	NSXMLElement* nameNode = [self extractSubnodeFromNode:node withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Members parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (int) extractMemberType:(NSXMLElement*) node
{
	NSXMLNode* kindAttr = [node attributeForName:@"kind"];
	if (kindAttr)
	{
		if ([[kindAttr stringValue] isEqualToString:@"class-method"])
			return kTKMemberTypeClass;
		if ([[kindAttr stringValue] isEqualToString:@"instance-method"])
			return kTKMemberTypeInstance;
	}
	return kTKMemberTypeProperty;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractMemberName:(NSXMLElement*) node
{
	NSXMLElement* nameNode = [self extractSubnodeFromNode:node withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractMemberSelector:(NSXMLElement*) node
{
	// Determine whether this is class or instance method.
	NSString* prefix = nil;
	switch ([self extractMemberType:node])
	{
		case kTKMemberTypeClass:
			prefix = @"+ ";
			break;
		case kTKMemberTypeInstance:
			prefix = @"- ";
			break;
		default:
			prefix = @"";
			break;
	}
	
	// Return the prefix followed by the name.
	return [NSString stringWithFormat:@"%@%@", prefix, [self extractMemberName:node]];
}

//----------------------------------------------------------------------------------------
- (NSString*) extractMemberFile:(NSXMLElement*) node
{
	NSXMLElement* fileNode = [self extractSubnodeFromNode:node withName:@"file"];
	if (fileNode) return [fileNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractMemberPrototypeNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"prototype"];
}

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractMemberDescriptionNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"description"];
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractMemberSectionNodes:(NSXMLElement*) node
								  type:(int) type
{
	NSString* query = nil;
	switch (type)
	{
		case kTKMemberSectionExceptions:
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
- (NSXMLElement*) extractMemberReturnNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"return"];
}

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractMemberWarningNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"warning"];
}

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractMemberBugNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"bug"];
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractMemberSeeAlsoItems:(NSXMLElement*) node
{
	NSArray* itemNodes = [node nodesForXPath:@"seeAlso/item" error:nil];
	if ([itemNodes count] > 0) return itemNodes;
	return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Member section parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSArray*) extractMemberSectionSubnodes:(NSXMLElement*) node
{
	return [node children];
}

//----------------------------------------------------------------------------------------
- (int) extractMemberSectionItemType:(id) item
{
	NSXMLNode* node = (NSXMLNode*)item;
	if ([node kind] == NSXMLElementKind) return kTKMemberSectionParameter;
	return kTKMemberSectionValue;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractMemberSectionItemValue:(id) item
{
	return [item stringValue];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Parameter parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractParameterName:(NSXMLElement*) node
{
	NSXMLElement* nameNode = [self extractSubnodeFromNode:node withName:@"name"];
	if (nameNode) return [nameNode stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractParameterDescriptionNode:(NSXMLElement*) node
{
	return [self extractSubnodeFromNode:node withName:@"description"];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Descriptions parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractBriefDescriptionFromNode:(NSXMLElement*) node
{
	NSArray* subnodes = [self extractBriefSubnodesFromNode:node];
	if (subnodes) return [[subnodes objectAtIndex:0] stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractBriefSubnodesFromNode:(NSXMLElement*) node
{
	NSXMLElement* briefNode = [self extractSubnodeFromNode:node withName:@"brief"];
	if (briefNode)
	{
		NSArray* result = [briefNode nodesForXPath:@"*" error:nil];
		if ([result count] > 0) return result;
	}
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractDetailSubnodesFromNode:(NSXMLElement*) node
{
	NSXMLElement* briefNode = [self extractSubnodeFromNode:node withName:@"details"];
	if (briefNode)
	{
		NSArray* result = [briefNode nodesForXPath:@"*" error:nil];
		if ([result count] > 0) return result;
	}
	return nil;
}

//----------------------------------------------------------------------------------------
- (BOOL) isDescriptionUsed:(NSArray*) nodes
{
	for (NSXMLElement* subnode in nodes)
	{
		NSString* value = [subnode stringValue];
		if ([value length] > 0) return YES;
	}
	return NO;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Miscellanous parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSXMLElement*) extractSubnodeFromNode:(NSXMLElement*) node
								withName:(NSString*) name
{
	NSArray* children = [node nodesForXPath:name error:nil];
	if ([children count] > 0)
	{
		return [children objectAtIndex:0];
	}
	return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendLine:(NSString*) string toData:(NSMutableData*) data
{
	[self appendString:string toData:data];
	[self appendString:@"\n" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendString:(NSString*) string toData:(NSMutableData*) data
{
	NSData* stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:stringData];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) title
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
	return [objectData objectForKey:kTKDataObjectMarkupKey];
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
