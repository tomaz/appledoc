//
//  XMLBasedOutputGenerator+GeneralParsingAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator+GeneralParsingAPI.h"

@implementation XMLBasedOutputGenerator (GeneralParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Descriptions parsing support
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) extractBriefDescriptionFromItem:(id) item
{
	NSArray* subnodes = [self extractBriefParagraphsFromItem:item];
	if (subnodes) return [[subnodes objectAtIndex:0] stringValue];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractBriefParagraphsFromItem:(id) item
{
	NSXMLElement* briefNode = [self extractSubitemFromItem:item withName:@"brief"];
	if (briefNode) return [self extractParagraphsFromItem:briefNode];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractDetailParagraphsFromItem:(id) item
{
	NSXMLElement* detailsNode = [self extractSubitemFromItem:item withName:@"details"];
	if (detailsNode) return [self extractParagraphsFromItem:detailsNode];
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSArray*) extractParagraphsFromItem:(id) item
{
	NSArray* result = [item nodesForXPath:@"*" error:nil];
	if ([result count] > 0) return result;
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) extractParagraphText:(id) item
{
	return [item XMLString];
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
