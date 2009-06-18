//
//  XMLBasedOutputGenerator+GeneralParsingAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator+GeneralParsingAPI.h"
#import "Systemator.h"

@implementation XMLBasedOutputGenerator (GeneralParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Descriptions parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractBriefDescriptionFromItem:(id) item
{
	NSArray* subnodes = [self extractBriefDescriptionsFromItem:item];
	if (subnodes) return [[subnodes objectAtIndex:0] stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractBriefDescriptionsFromItem:(id) item
{
	NSXMLElement* briefNode = [self extractSubitemFromItem:item withName:@"brief"];
	if (briefNode) return [self extractDescriptionsFromItem:briefNode];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractDetailDescriptionsFromItem:(id) item
{
	NSXMLElement* detailsNode = [self extractSubitemFromItem:item withName:@"details"];
	if (detailsNode) return [self extractDescriptionsFromItem:detailsNode];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractDescriptionsFromItem:(id) item
{
	// Extract all children (recursively!) from the given description item.
	NSMutableArray* result = [NSMutableArray array];
	[self extractSubitemsFromItem:item appendToArray:result closeContainers:YES];
	
	// If there is at least one child, process it - we need to "close"
	if ([result count] > 0) return result;
	return nil;
}

//----------------------------------------------------------------------------------------
- (int) extractDescriptionType:(id) item
{
	// If the given item is an element, get the type based on element name. Note that
	// we kind of hack close elements handling to make the code simpler and avoid
	// repetition: since these are elements with the same name as their opening
	// counterparts except they have close=YES attribute, we use the same detection
	// code, but add 1 to the result. Therefore the code depends on the fact that all
	// close types should have the value of open type + 1!
	if ([item kind] == NSXMLElementKind)
	{
		// Is this close node? If we find close attribute (we don't even check the
		// value), we should add 1 to the result, otherwise 0.
		int offset = [item attributeForName:@"close"] ? 1 : 0;
		
		// Now handle the name. Note that we return the type + the calculated offset.
		if ([[item name] isEqualToString:@"para"])
			return kTKDescriptionParagraphStart + offset;
		if ([[item name] isEqualToString:@"code"])
			return kTKDescriptionCodeStart + offset;
		if ([[item name] isEqualToString:@"list"])
			return kTKDescriptionListStart + offset;
		if ([[item name] isEqualToString:@"item"])
			return kTKDescriptionListItemStart + offset;
		if ([[item name] isEqualToString:@"strong"])
			return kTKDescriptionStrongStart + offset;
		if ([[item name] isEqualToString:@"emphasis"])
			return kTKDescriptionEmphasisStart + offset;
		if ([[item name] isEqualToString:@"example"])
			return kTKDescriptionExampleStart + offset;
		if ([[item name] isEqualToString:@"ref"])
			return kTKDescriptionReferenceStart + offset;
	}
	
	// If the type is text, return text.
	else if ([item kind] == NSXMLTextKind)
	{
		return kTKDescriptionText;
	}
	
	// If we couldn't determine the type, raise an exception.
	NSString* message = [NSString stringWithFormat:@"Description item '%@' is unknown!", item];
	[Systemator throwExceptionWithName:kTKConverterException withDescription:message];
	return -1;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractDescriptionReference:(id) description
{
	NSXMLNode* idAttribute = [description attributeForName:@"id"];
	if (idAttribute) return [idAttribute stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractDescriptionText:(id) item
{
	return [item stringValue];
}

//----------------------------------------------------------------------------------------
- (BOOL) isDescriptionUsed:(NSArray*) items
{
	for (NSXMLElement* subnode in items)
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
- (id) extractSubitemFromItem:(id) item
					 withName:(NSString*) name
{
	NSArray* children = [item nodesForXPath:name error:nil];
	if ([children count] > 0)
	{
		return [children objectAtIndex:0];
	}
	return nil;
}

//----------------------------------------------------------------------------------------
- (void) extractSubitemsFromItem:(id) item
				   appendToArray:(NSMutableArray*) array
				 closeContainers:(BOOL) close
{
	// Handle all children and their children. This ends in recursic descent through the
	// XML hierarchy. Note that we close containers with an element of the same name as
	// the opening node, but with an attribute close="YES".
	for (NSXMLNode* node in [item children])
	{
		[array addObject:node];
		if ([node childCount] > 0)
		{
			[self extractSubitemsFromItem:node appendToArray:array closeContainers:close];
			if (close)
			{
				NSXMLElement* closeNode = [NSXMLNode elementWithName:[node name]];
				[closeNode addAttribute:[NSXMLNode attributeWithName:@"close" stringValue:@"YES"]];
				[array addObject:closeNode];
			}
		}
	}
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

@end
