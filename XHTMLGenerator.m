//
//  XHTMLGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XHTMLGenerator.h"
#import "GeneratorBase+PrivateAPI.h"

@implementation XHTMLGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark General output handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 STRICT//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" 
			  toData:data];
	[self appendLine:@"<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
			  toData:data];
	[self appendLine:@"<head>" toData:data];
	
	[self appendString:@"  <title>" toData:data];
	[self appendString:self.title toData:data];
	[self appendLine:@"</title>" toData:data];
	
	[self appendLine:@"  <meta http-equiv=\"Content-Type\" content=\"application/xhtml+xml;charset=utf-8\" />" 
			  toData:data];
	[self appendLine:@"  <link rel=\"stylesheet\" type=\"text/css\" href=\"../css/screen.css\" />" 
			  toData:data];
	[self appendLine:@"  <meta name=\"generator\" content=\"appledoc\" />" 
			  toData:data];
	[self appendLine:@"</head>" toData:data];
	[self appendLine:@"<body>" toData:data];
	[self appendLine:@"  <div id=\"mainContainer\">" toData:data];

	[self appendString:@"    <h1>" toData:data];
	[self appendString:self.title toData:data];
	[self appendLine:@"</h1>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendFooterToData:(NSMutableData*) data
{
	[self appendLine:@"    <hr />" toData:data];
	[self appendString:@"    <p id=\"lastUpdated\">" toData:data];
	
	if (self.lastUpdated && [self.lastUpdated length] > 0)
	{
		[self appendString:@"Last updated: " toData:data];
		[self appendString:self.lastUpdated toData:data];
		[self appendLine:@"      <br />" toData:data];
	}
	
	[self appendLine:@"Back to <a href=\"../Index.html\">index</a>." toData:data];
	[self appendLine:@"    </p>" toData:data];
	
	[self appendLine:@"  </div>" toData:data];
	[self appendLine:@"</body>" toData:data];
	[self appendLine:@"</html>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object info table handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendInfoHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"    <table summary=\"Basic information\" id=\"classInfo\">" 
			  toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendInfoItemToData:(NSMutableData*) data
					fromNodes:(NSArray*) nodes
						index:(int) index
						 type:(int) type
{
	// Append the <tr> with class="alt" for every second item.
	[self appendString:@"      <tr" toData:data];
	if (index % 2 == 0) [self appendString:@" class=\"alt\"" toData:data];
	[self appendLine:@">" toData:data];
	
	// Append the label based on the type.
	NSString* description = nil;
	switch (type)
	{
		case kTKSectionItemInherits:
			description = @"Inherits from";
			break;
		case kTKSectionItemConforms:
			description = @"Conforms to";
			break;
		case kTKSectionItemDeclared:
			description = @"Declared in";
			break;
	}
	[self appendString:@"        <td><label id=\"classDeclaration\">" toData:data];
	[self appendString:description toData:data];
	[self appendLine:@"</label></td>" toData:data];
	
	// Append the nodes information. Each node within the array get's it's own line
	// separated by a line break. Each node can optionally contain a reference to a
	// member which is provided by the id attribute.
	[self appendString:@"        <td>" toData:data];
	for (int i = 0; i < [nodes count]; i++)
	{
		NSXMLElement* node = [nodes objectAtIndex:i];
		NSXMLNode* idAttr = [node attributeForName:@"id"];
		
		// Append <a> header with href.
		if (idAttr)
		{	
			[self appendString:@"<a href=\"" toData:data];
			[self appendString:[idAttr stringValue] toData:data];
			[self appendString:@"\">" toData:data];
		}
		
		// Append the value.
		[self appendString:[node stringValue] toData:data];
		
		// Append </a>.
		if (idAttr) [self appendString:@"</a>" toData:data];
		
		// If there's more elements, append line break after each except last one.
		if (i < [nodes count] - 1) [self appendLine:@"<br />" toData:data];
	}
	[self appendLine:@"</td>" toData:data];
	[self appendLine:@"      </tr>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendInfoFooterToData:(NSMutableData*) data
{
	[self appendLine:@"    </table>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object overview handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendOverviewToData:(NSMutableData*) data 
					 fromNode:(NSXMLElement*) node
{
	[self appendLine:@"      <h2>Overview</h2>" toData:data];
	[self appendBriefDescriptionToData:data fromNode:node];
	[self appendDetailedDescriptionToData:data fromNode:node];	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object sections handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendSectionsHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"      <h2>Tasks</h2>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendSectionHeaderToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
							 index:(int) index
{
	[self appendString:@"      <h3>" toData:data];
	[self appendString:[self extractSectionName:node] toData:data];
	[self appendLine:@"</h3>" toData:data];
	[self appendLine:@"      <ul class=\"methods\">" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendSectionFooterToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
							 index:(int) index
{
	[self appendLine:@"      </ul>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendSectionMemberToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
							 index:(int) index
{
	[self appendLine:@"        <li>" toData:data];
	[self appendLine:@"          <span class=\"tooltipRegion\">" toData:data];	

	// Append link to the actual member documentation.
	[self appendString:@"            <code>" toData:data];
	[self appendString:@"<a href=#" toData:data];
	[self appendString:[self extractMemberName:node] toData:data];
	[self appendString:@">" toData:data];
	[self appendString:[self extractMemberSelector:node] toData:data];
	[self appendString:@"</a>" toData:data];	
	[self appendLine:@"</code>" toData:data];
	
	// Append property data.
	if ([self extractMemberType:node] == kTKMemberTypeProperty)
	{
		[self appendLine:@"            <span class=\"specialType\">property</span>" toData:data];
	}
	
	// Append tooltip text.
	NSXMLElement* descriptionNode = [self extractMemberDescriptionNode:node];
	if (descriptionNode)
	{
		NSString* description = [self extractBriefDescriptionFromNode:descriptionNode];
		if (description)
		{
			[self appendString:@"            <span class=\"tooltip\">" toData:data];
			[self appendString:description toData:data];
			[self appendString:@"</span>" toData:data];
		}
	}
	
	[self appendLine:@"          </span>" toData:data];
	[self appendLine:@"        </li>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object members main documentation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendMemberGroupHeaderToData:(NSMutableData*) data 
								  type:(int) type
{
	NSString* description = nil;
	switch (type)
	{
		case kTKMemberTypeClass:
			description = @"Class methods";
			break;
		case kTKMemberTypeInstance:
			description = @"Instance methods";
			break;
		default:
			description = @"Properties";
			break;
	}
	[self appendString:@"      <h2>" toData:data];
	[self appendString:description toData:data];
	[self appendLine:@"</h2>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendMemberToData:(NSMutableData*) data 
				   fromNode:(NSXMLElement*) node 
					  index:(int) index
{
	[self appendMemberTitleToData:data fromNode:node];
	[self appendMemberOverviewToData:data fromNode:node];
	[self appendMemberPrototypeToData:data fromNode:node];
	[self appendMemberSectionToData:data fromNode:node type:kTKMemberSectionParameters title:@"Parameters"];
	[self appendMemberSectionToData:data fromNode:node type:kTKMemberSectionExceptions title:@"Exceptions"];
	[self appendMemberReturnToData:data fromNode:node];
	[self appendMemberDiscussionToData:data fromNode:node];
	[self appendMemberWarningToData:data fromNode:node];
	[self appendMemberBugToData:data fromNode:node];
	[self appendMemberSeeAlsoToData:data fromNode:node];
	[self appendMemberFileToData:data fromNode:node];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memer helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendMemberTitleToData:(NSMutableData*) data
						fromNode:(NSXMLElement*) node
{
	// Append the member title.
	[self appendString:@"      <h3><a name=\"" toData:data];
	[self appendString:[self extractMemberName:node] toData:data];
	[self appendString:@"\"></a>" toData:data];
	[self appendString:[self extractMemberName:node] toData:data];
	[self appendLine:@"</h3>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendMemberOverviewToData:(NSMutableData*) data
						   fromNode:(NSXMLElement*) node
{
	// Append the brief description. First get the description node and use it to append
	// brief description to the output. The description is fully formatted.
	NSXMLElement* descriptionNode = [self extractMemberDescriptionNode:node];
	if (descriptionNode)
	{
		[self appendBriefDescriptionToData:data fromNode:descriptionNode];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberPrototypeToData:(NSMutableData*) data
							fromNode:(NSXMLElement*) node
{
	// Append the prototype.
	NSXMLElement* prototypeNode = [self extractMemberPrototypeNode:node];
	if (prototypeNode)
	{
		[self appendString:@"      <code class=\"methodDeclaration\">" toData:data];		
		NSArray* items = [self extractMemberSectionSubnodes:prototypeNode];
		if (items)
		{
			for (id item in items)
			{
				if ([self extractMemberSectionItemType:item] == kTKMemberSectionParameter)
				{
					[self appendString:@"        <span class=\"parameter\">" toData:data];
					[self appendString:[self extractMemberSectionItemValue:item] toData:data];
					[self appendLine:@"</span>" toData:data];
				}
				else
				{
					[self appendString:[self extractMemberSectionItemValue:item] toData:data];
				}
			}
		}		
		[self appendLine:@"      </code>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberSectionToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
							  type:(int) type
							 title:(NSString*) title
{
	NSArray* parameterNodes = [self extractMemberSectionNodes:node type:type];
	if (parameterNodes)
	{
		[self appendString:@"      <h5>" toData:data];
		[self appendString:title toData:data];
		[self appendLine:@"</h5>" toData:data];
		
		[self appendLine:@"      <dl class=\"parameterList\">" toData:data];
		for (NSXMLElement* parameterNode in parameterNodes)
		{
			[self appendString:@"        <dt>" toData:data];
			[self appendString:[self extractParameterName:parameterNode] toData:data];
			[self appendLine:@"</dt>" toData:data];
			
			[self appendString:@"        <dd>" toData:data];
			[self appendDescriptionToData:data fromNode:[self extractParameterDescriptionNode:parameterNode]];
			[self appendLine:@"</dd>" toData:data];
		}
		[self appendLine:@"      </dl>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberReturnToData:(NSMutableData*) data
						 fromNode:(NSXMLElement*) node
{
	NSXMLElement* returnNode = [self extractMemberReturnNode:node];
	if (returnNode)
	{
		[self appendLine:@"      <h5>Return value</h5>" toData:data];
		[self appendDescriptionToData:data fromNode:returnNode];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberDiscussionToData:(NSMutableData*) data
							 fromNode:(NSXMLElement*) node
{
	NSXMLElement* descriptionNode = [self extractMemberDescriptionNode:node];
	if (descriptionNode)
	{
		NSArray* detailSubnodes = [self extractDetailSubnodesFromNode:descriptionNode];
		if (detailSubnodes && [self isDescriptionUsed:detailSubnodes])
		{
			[self appendLine:@"      <h5>Discussion</h5>" toData:data];
			[self appendDetailedDescriptionToData:data fromNode:descriptionNode];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberWarningToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
{
	NSXMLElement* warningNode = [self extractMemberWarningNode:node];
	if (warningNode)
	{
		[self appendLine:@"      <h5>Warning</h5>" toData:data];
		[self appendDescriptionToData:data fromNode:warningNode];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberBugToData:(NSMutableData*) data
					  fromNode:(NSXMLElement*) node
{
	NSXMLElement* bugNode = [self extractMemberBugNode:node];
	if (bugNode)
	{
		[self appendLine:@"      <h5>Bug</h5>" toData:data];
		[self appendDescriptionToData:data fromNode:bugNode];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberSeeAlsoToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
{
	NSArray* items = [self extractMemberSeeAlsoItems:node];
	if (items)
	{
		[self appendLine:@"      <h5>See also</h5>" toData:data];
		[self appendLine:@"      <ul class=\"seeAlso\">" toData:data];
		for (NSXMLElement* item in items)
		{
			[self appendString:@"        <li><code>" toData:data];
			[self appendDescriptionToData:data fromNode:item];
			[self appendLine:@"</code></li>" toData:data];
		}
		[self appendLine:@"      </ul>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendMemberFileToData:(NSMutableData*) data
					   fromNode:(NSXMLElement*) node
{
	NSString* filename = [self extractMemberFile:node];
	if (filename)
	{
		[self appendLine:@"      <h5>Declared in</h5>" toData:data];
		[self appendString:@"      <code>" toData:data];
		[self appendString:filename toData:data];
		[self appendLine:@"</code>" toData:data];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Description helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromNode:(NSXMLElement*) node
{
	NSArray* briefSubnodes = [self extractBriefSubnodesFromNode:node];
	if (briefSubnodes)
	{
		for (NSXMLElement* briefSubnode in briefSubnodes)
		{
			[self appendDescriptionToData:data fromNode:briefSubnode];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromNode:(NSXMLElement*) node
{
	NSArray* detailsSubnodes = [self extractDetailSubnodesFromNode:node];
	if (detailsSubnodes)
	{
		for (NSXMLElement* detailsSubnode in detailsSubnodes)
		{
			[self appendDescriptionToData:data fromNode:detailsSubnode];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendDescriptionToData:(NSMutableData*) data 
						fromNode:(NSXMLElement*) node;
{
	NSString* result = [node XMLString];
	result = [result stringByReplacingOccurrencesOfString:@"<para>" withString:@"<p>"];
	result = [result stringByReplacingOccurrencesOfString:@"</para>" withString:@"</p>"];
	result = [result stringByReplacingOccurrencesOfString:@"<ref id" withString:@"<a href"];
	result = [result stringByReplacingOccurrencesOfString:@"</ref>" withString:@"</a>"];
	result = [result stringByReplacingOccurrencesOfString:@"<list>" withString:@"<ul>"];
	result = [result stringByReplacingOccurrencesOfString:@"</list>" withString:@"</ul>"];
	result = [result stringByReplacingOccurrencesOfString:@"<item>" withString:@"<li>"];
	result = [result stringByReplacingOccurrencesOfString:@"</item>" withString:@"</li>"];
	[self appendLine:result toData:data];
}

@end
