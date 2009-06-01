//
//  XHTMLGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XHTMLGenerator.h"
#import "GeneratorBase+GeneralParsingAPI.h"
#import "GeneratorBase+ObjectParsingAPI.h"
#import "GeneratorBase+ObjectSubclassAPI.h"

@implementation XHTMLGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark General output handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 STRICT//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" 
			  toData:data];
	[self appendLine:@"<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
			  toData:data];
	[self appendLine:@"<head>" toData:data];
	
	[self appendString:@"  <title>" toData:data];
	[self appendString:self.objectTitle toData:data];
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
	[self appendString:self.objectTitle toData:data];
	[self appendLine:@"</h1>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectFooterToData:(NSMutableData*) data
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
- (void) appendObjectInfoHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"    <table summary=\"Basic information\" id=\"classInfo\">" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoItemToData:(NSMutableData*) data
						  fromItems:(NSArray*) items
							  index:(int) index
							   type:(int) type;
{
	// Append the <tr> with class="alt" for every second item.
	[self appendString:@"      <tr" toData:data];
	if (index % 2 == 0) [self appendString:@" class=\"alt\"" toData:data];
	[self appendLine:@">" toData:data];
	
	// Append the label based on the type.
	NSString* description = nil;
	NSString* delimiter = nil;
	switch (type)
	{
		case kTKSectionItemInherits:
			description = @"Inherits from";
			delimiter = @" : ";
			break;
		case kTKSectionItemConforms:
			description = @"Conforms to";
			delimiter = @"<br />";
			break;
		case kTKSectionItemDeclared:
			description = @"Declared in";
			delimiter = @"<br />";
			break;
	}
	[self appendString:@"        <td><label id=\"classDeclaration\">" toData:data];
	[self appendString:description toData:data];
	[self appendLine:@"</label></td>" toData:data];
	
	// Append the nodes information. Each node within the array get's it's own line
	// separated by a line break. Each node can optionally contain a reference to a
	// member which is provided by the id attribute.
	[self appendString:@"        <td>" toData:data];
	for (int i = 0; i < [items count]; i++)
	{
		id item = [items objectAtIndex:i];
		NSString* reference = [self extractObjectInfoItemRef:item];
		NSString* value = [self extractObjectInfoItemValue:item];
		
		// Append <a> header with href.
		if (reference)
		{	
			[self appendString:@"<a href=\"" toData:data];
			[self appendString:reference toData:data];
			[self appendString:@"\">" toData:data];
		}
		
		// Append the value.
		[self appendString:value toData:data];
		
		// Append </a>.
		if (reference) [self appendString:@"</a>" toData:data];
		
		// If there's more elements, append line break after each except last one.
		if (i < [items count] - 1) [self appendLine:delimiter toData:data];
	}
	[self appendLine:@"</td>" toData:data];
	[self appendLine:@"      </tr>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoFooterToData:(NSMutableData*) data
{
	[self appendLine:@"    </table>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object overview handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectOverviewToData:(NSMutableData*) data 
						   fromItem:(id) item
{
	[self appendLine:@"      <h2>Overview</h2>" toData:data];
	[self appendBriefDescriptionToData:data fromItem:item];
	[self appendDetailedDescriptionToData:data fromItem:item];	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object tasks handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksHeaderToData:(NSMutableData*) data
{
	[self appendLine:@"      <h2>Tasks</h2>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskHeaderToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
	[self appendString:@"      <h3>" toData:data];
	[self appendString:[self extractObjectTaskName:item] toData:data];
	[self appendLine:@"</h3>" toData:data];
	[self appendLine:@"      <ul class=\"methods\">" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskFooterToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
	[self appendLine:@"      </ul>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskMemberToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
	[self appendLine:@"        <li>" toData:data];
	[self appendLine:@"          <span class=\"tooltipRegion\">" toData:data];	

	// Append link to the actual member documentation.
	[self appendString:@"            <code>" toData:data];
	[self appendString:@"<a href=#" toData:data];
	[self appendString:[self extractObjectMemberName:item] toData:data];
	[self appendString:@">" toData:data];
	[self appendString:[self extractObjectMemberSelector:item] toData:data];
	[self appendString:@"</a>" toData:data];	
	[self appendLine:@"</code>" toData:data];
	
	// Append property data.
	if ([self extractObjectMemberType:item] == kTKMemberTypeProperty)
	{
		[self appendLine:@"            <span class=\"specialType\">property</span>" toData:data];
	}
	
	// Append tooltip text.
	id descriptionItem = [self extractObjectMemberDescriptionItem:item];
	if (descriptionItem)
	{
		NSString* description = [self extractBriefDescriptionFromItem:descriptionItem];
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
- (void) appendObjectMemberGroupHeaderToData:(NSMutableData*) data 
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
- (void) appendObjectMemberToData:(NSMutableData*) data 
						 fromItem:(id) item 
							index:(int) index
{
	[self appendObjectMemberTitleToData:data fromItem:item];
	[self appendObjectMemberOverviewToData:data fromItem:item];
	[self appendObjectMemberPrototypeToData:data fromItem:item];
	[self appendObjectMemberSectionToData:data fromItem:item type:kTKMemberSectionParameters title:@"Parameters"];
	[self appendObjectMemberSectionToData:data fromItem:item type:kTKMemberSectionExceptions title:@"Exceptions"];
	[self appendObjectMemberReturnToData:data fromItem:item];
	[self appendObjectMemberDiscussionToData:data fromItem:item];
	[self appendObjectMemberWarningToData:data fromItem:item];
	[self appendObjectMemberBugToData:data fromItem:item];
	[self appendObjectMemberSeeAlsoToData:data fromItem:item];
	[self appendObjectMemberFileToData:data fromItem:item];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Member helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberTitleToData:(NSMutableData*) data
							  fromItem:(id) item
{
	// Append the member title.
	[self appendString:@"      <h3><a name=\"" toData:data];
	[self appendString:[self extractObjectMemberName:item] toData:data];
	[self appendString:@"\"></a>" toData:data];
	[self appendString:[self extractObjectMemberName:item] toData:data];
	[self appendLine:@"</h3>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberOverviewToData:(NSMutableData*) data
								 fromItem:(id) item
{
	// Append the brief description. First get the description node and use it to append
	// brief description to the output. The description is fully formatted.
	id descriptionItem = [self extractObjectMemberDescriptionItem:item];
	if (descriptionItem)
	{
		[self appendBriefDescriptionToData:data fromItem:descriptionItem];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberPrototypeToData:(NSMutableData*) data
								  fromItem:(id) item
{
	// Append the prototype.
	id prototypeItem = [self extractObjectMemberPrototypeItem:item];
	if (prototypeItem)
	{
		[self appendString:@"      <code class=\"methodDeclaration\">" toData:data];		
		NSArray* items = [self extractObjectMemberPrototypeSubitems:prototypeItem];
		if (items)
		{
			for (id item in items)
			{
				if ([self extractObjectMemberPrototypeItemType:item] == kTKMemberPrototypeParameter)
				{
					[self appendString:@"        <span class=\"parameter\">" toData:data];
					[self appendString:[self extractObjectMemberPrototypeItemValue:item] toData:data];
					[self appendLine:@"</span>" toData:data];
				}
				else
				{
					[self appendString:[self extractObjectMemberPrototypeItemValue:item] toData:data];
				}
			}
		}		
		[self appendLine:@"      </code>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberSectionToData:(NSMutableData*) data
								fromItem:(id) item
									type:(int) type
								   title:(NSString*) title
{
	NSArray* parameterItems = [self extractObjectMemberSectionItems:item type:type];
	if (parameterItems)
	{
		[self appendString:@"      <h5>" toData:data];
		[self appendString:title toData:data];
		[self appendLine:@"</h5>" toData:data];
		
		[self appendLine:@"      <dl class=\"parameterList\">" toData:data];
		for (id parameterItem in parameterItems)
		{
			[self appendString:@"        <dt>" toData:data];
			[self appendString:[self extractObjectParameterName:parameterItem] toData:data];
			[self appendLine:@"</dt>" toData:data];
			
			[self appendString:@"        <dd>" toData:data];
			[self appendDescriptionToData:data fromParagraph:[self extractObjectParameterDescriptionNode:parameterItem]];
			[self appendLine:@"</dd>" toData:data];
		}
		[self appendLine:@"      </dl>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberReturnToData:(NSMutableData*) data
							   fromItem:(id) item
{
	id returnItem = [self extractObjectMemberReturnItem:item];
	if (returnItem)
	{
		[self appendLine:@"      <h5>Return value</h5>" toData:data];
		[self appendDescriptionToData:data fromParagraph:returnItem];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberDiscussionToData:(NSMutableData*) data
								   fromItem:(id) item
{
	id descriptionItem = [self extractObjectMemberDescriptionItem:item];
	if (descriptionItem)
	{
		NSArray* paragraphs = [self extractDetailParagraphsFromItem:descriptionItem];
		if (paragraphs && [self isDescriptionUsed:paragraphs])
		{
			[self appendLine:@"      <h5>Discussion</h5>" toData:data];
			[self appendDetailedDescriptionToData:data fromItem:descriptionItem];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberWarningToData:(NSMutableData*) data
								fromItem:(id) item
{
	id warningItem = [self extractObjectMemberWarningItem:item];
	if (warningItem)
	{
		[self appendLine:@"      <h5>Warning</h5>" toData:data];
		[self appendDescriptionToData:data fromParagraph:warningItem];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberBugToData:(NSMutableData*) data
					  fromItem:(id) item
{
	id bugItem = [self extractObjectMemberBugItem:item];
	if (bugItem)
	{
		[self appendLine:@"      <h5>Bug</h5>" toData:data];
		[self appendDescriptionToData:data fromParagraph:bugItem];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberSeeAlsoToData:(NSMutableData*) data
								fromItem:(id) item
{
	NSArray* items = [self extractObjectMemberSeeAlsoItems:item];
	if (items)
	{
		[self appendLine:@"      <h5>See also</h5>" toData:data];
		[self appendLine:@"      <ul class=\"seeAlso\">" toData:data];
		for (id item in items)
		{
			[self appendString:@"        <li><code>" toData:data];
			[self appendDescriptionToData:data fromParagraph:item];
			[self appendLine:@"</code></li>" toData:data];
		}
		[self appendLine:@"      </ul>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberFileToData:(NSMutableData*) data
							 fromItem:(id) item
{
	NSString* filename = [self extractObjectMemberFile:item];
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
							 fromItem:(id) item
{
	NSArray* paragraphs = [self extractBriefParagraphsFromItem:item];
	if (paragraphs)
	{
		for (id paragraph in paragraphs)
		{
			[self appendDescriptionToData:data fromParagraph:paragraph];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromItem:(id) item
{
	NSArray* paragraphs = [self extractDetailParagraphsFromItem:item];
	if (paragraphs)
	{
		for (id paragraph in paragraphs)
		{
			[self appendDescriptionToData:data fromParagraph:paragraph];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendDescriptionToData:(NSMutableData*) data 
				   fromParagraph:(id) item
{
	NSString* result = [self extractParagraphText:item];
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
