//
//  XHTMLOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XHTMLOutputGenerator.h"
#import "XMLBasedOutputGenerator+GeneralParsingAPI.h"
#import "XMLBasedOutputGenerator+ObjectParsingAPI.h"
#import "XMLBasedOutputGenerator+ObjectSubclassAPI.h"
#import "XMLBasedOutputGenerator+IndexParsingAPI.h"
#import "XMLBasedOutputGenerator+IndexSubclassAPI.h"
#import "XMLBasedOutputGenerator+HierarchyParsingAPI.h"
#import "XMLBasedOutputGenerator+HierarchySubclassAPI.h"
#import "Systemator.h"
#import "LoggingProvider.h"
#import "CommandLineParser.h"
#import "DoxygenConverter.h"

@implementation XHTMLOutputGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark OutputInfoProvider protocol implementation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) outputFilesExtension
{
	return @".html";
}

//----------------------------------------------------------------------------------------
- (NSString*) outputBasePath
{
	return [cmd.outputPath stringByAppendingPathComponent:@"cxhtml"];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) isOutputGenerationEnabled
{
	return cmd.createCleanXHTML;
}

//----------------------------------------------------------------------------------------
- (void) outputGenerationFinished
{
	// If at least one file was genereated, copy the css files from templates.
	if (self.outputFileWasCreated)
	{
		NSError* error = nil;
		NSArray* templateFiles = [manager contentsOfDirectoryAtPath:cmd.templatesPath error:&error];
		if (!templateFiles)
		{
			logError(@"Failed accessing template files at '%@'!", cmd.templatesPath);
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}
		
		for (NSString* templateFile in templateFiles)
		{
			if ([[templateFile pathExtension] isEqualToString:@"css"])
			{
				logVerbose(@"- Copying '%@' css file...", templateFile);
				NSString* source = [cmd.templatesPath stringByAppendingPathComponent:templateFile];
				NSString* dest = [[self outputBasePath] stringByAppendingPathComponent:kTKDirCSS];
				dest = [dest stringByAppendingPathComponent:templateFile];
				@try
				{
					[Systemator copyItemAtPath:source toPath:dest];
				}
				@catch (NSException* e)
				{
					logError(@"Failed copying XHTML css file!");
				}
			}
		}
	}	
}

//----------------------------------------------------------------------------------------
- (void) createOutputDirectories
{
	[super createOutputDirectories];
	[Systemator createDirectory:[[self outputBasePath] stringByAppendingPathComponent:kTKDirCSS]];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectHeaderToData:(NSMutableData*) data
{
	NSString* stylesheetPath = [NSString stringWithFormat:@"../%@/screen.css", kTKDirCSS];
	[self appendFileHeaderToData:data 
					   withTitle:self.objectTitle 
				   andStylesheet:stylesheetPath];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectFooterToData:(NSMutableData*) data
{
	[self appendFileFooterToData:data
				 withLastUpdated:YES
					andIndexLink:YES];
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
		case kTKObjectInfoItemInherits:
			description = @"Inherits from";
			delimiter = @" : ";
			break;
		case kTKObjectInfoItemConforms:
			description = @"Conforms to";
			delimiter = @"<br />";
			break;
		case kTKObjectInfoItemDeclared:
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
	if ([self extractObjectMemberType:item] == kTKObjectMemberTypeProperty)
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
		case kTKObjectMemberTypeClass:
			description = @"Class methods";
			break;
		case kTKObjectMemberTypeInstance:
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
	[self appendObjectMemberSectionToData:data fromItem:item type:kTKObjectMemberSectionParameters title:@"Parameters"];
	[self appendObjectMemberSectionToData:data fromItem:item type:kTKObjectMemberSectionExceptions title:@"Exceptions"];
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
				if ([self extractObjectMemberPrototypeItemType:item] == kTKObjectMemberPrototypeParameter)
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
			id descriptionItem = [self extractObjectParameterDescriptionNode:parameterItem];
			NSArray* paragraphs = [self extractParagraphsFromItem:descriptionItem];
			[self appendDescriptionToData:data fromParagraphs:paragraphs];
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
		NSArray* paragraphs = [self extractParagraphsFromItem:returnItem];
		[self appendDescriptionToData:data fromParagraphs:paragraphs];
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
		// Append the header based on the XHTML options.
		if (cmd.xhtmlUseBorderedWarnings)
			[self appendLine:@"      <div class=\"warning\">" toData:data];
		else
			[self appendLine:@"      <h5>Warning</h5>" toData:data];
		
		// Append the actual text.
		NSArray* paragraphs = [self extractParagraphsFromItem:warningItem];
		[self appendDescriptionToData:data fromParagraphs:paragraphs];
		
		// Append footer if bordered appearance is desired.
		if (cmd.xhtmlUseBorderedWarnings)
			[self appendLine:@"      </div>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberBugToData:(NSMutableData*) data
					  fromItem:(id) item
{
	id bugItem = [self extractObjectMemberBugItem:item];
	if (bugItem)
	{
		// Append the header based on the XHTML options.
		if (cmd.xhtmlUseBorderedBugs)
			[self appendLine:@"      <div class=\"bug\">" toData:data];
		else
			[self appendLine:@"      <h5>Bug</h5>" toData:data];
		
		// Append the actual text.
		NSArray* paragraphs = [self extractParagraphsFromItem:bugItem];
		[self appendDescriptionToData:data fromParagraphs:paragraphs];
		
		// Append footer if bordered appearance is desired.
		if (cmd.xhtmlUseBorderedWarnings)
			[self appendLine:@"      </div>" toData:data];
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
#pragma mark Index file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexHeaderToData:(NSMutableData*) data
{
	indexProtocolsGroupAppended = NO;
	indexCategoriesGroupAppended = NO;
	NSString* stylesheetPath = [NSString stringWithFormat:@"%@/screen.css", kTKDirCSS];
	[self appendFileHeaderToData:data 
					   withTitle:self.indexTitle 
				   andStylesheet:stylesheetPath];
}

//----------------------------------------------------------------------------------------
- (void) appendIndexFooterToData:(NSMutableData*) data
{
	// Finish the protocols and categories column if we started one. Note that this code
	// assumes that protocols and categories are handled last, so it may break if this
	// changes in the future...
	if (indexProtocolsGroupAppended || indexCategoriesGroupAppended)
	{
		[self appendLine:@"    </div>" toData:data];
	}
	
	// Finish the rest of the markup.
	[self appendLine:@"    <div class=\"clear\"></div>" toData:data];
	[self appendLine:@"    <div class=\"footer\">" toData:data];
	[self appendLine:@"      <a href=\"hierarchy.html\">Class hierarchy</a>" toData:data];
	[self appendLine:@"     </div>" toData:data];
	
	// Append the standard footer.
	[self appendFileFooterToData:data
				 withLastUpdated:NO
					andIndexLink:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Index groups handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupHeaderToData:(NSMutableData*) data
								 type:(int) type
{
	// Classes are embedded in their own column, while protocols and categories are
	// grouped together. For classes the handling is straightforward while for the other
	// two we need some ivars to make sure the column is started only once.
	BOOL startColumn = NO;
	NSString* title = nil;
	switch (type) 
	{
		case kTKIndexGroupClasses:
			title = @"Class references";
			startColumn = YES;
			break;
		case kTKIndexGroupProtocols:
			title = @"Protocol references";
			indexProtocolsGroupAppended = YES;
			if (!indexCategoriesGroupAppended) startColumn = YES;
			break;
		default:
			title = @"Categories references";
			indexCategoriesGroupAppended = YES;
			if (!indexProtocolsGroupAppended) startColumn = YES;
			break;
	}

	// Start the column if necessary.
	if (startColumn)
	{
		[self appendLine:@"    <div class=\"column\">" toData:data];
	}
	
	// Append the title.
	[self appendString:@"      <h5>" toData:data];
	[self appendString:title toData:data];
	[self appendLine:@"</h5>" toData:data];
	
	// Start the list.
	[self appendLine:@"      <ul>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupFooterToData:(NSMutableData*) data
								 type:(int) type
{
	// End the list.
	[self appendLine:@"      </ul>" toData:data];
	
	// If we are handling the classes group, end the column now. For the other two, we'll
	// handle it when processing index ends because at this point we have no indication
	// on whether there's additional group to put in the second column or not.
	if (type == kTKIndexGroupClasses)
	{
		[self appendLine:@"    </div>" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupItemToData:(NSMutableData*) data
						   fromItem:(id) item
							  index:(int) index
							   type:(int) type
{
	NSString* reference = [self extractIndexGroupItemRef:item];
	NSString* name = [self extractIndexGroupItemName:item];
	
	[self appendString:@"        <li>" toData:data];
	
	if (reference)
	{
		[self appendString:@"<a href=\"" toData:data];
		[self appendString:reference toData:data];
		[self appendString:@"\">" toData:data];
	}
	
	[self appendString:name toData:data];

	if (reference)
	{
		[self appendString:@"</a>" toData:data];
	}
	
	[self appendLine:@"</li>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Hierarchy groups handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHierarchyHeaderToData:(NSMutableData*) data
{
	NSString* stylesheetPath = [NSString stringWithFormat:@"%@/screen.css", kTKDirCSS];
	[self appendFileHeaderToData:data 
					   withTitle:self.hierarchyTitle 
				   andStylesheet:stylesheetPath];
	
	// Start the references column.
	[self appendLine:@"    <div class=\"hierarchy\">" toData:data];
	
	// Append the title.
	[self appendLine:@"      <h5>Class hierarchy</h5>" toData:data];
	
	// Prepare the default group indent. We use this so that the XHTML code is visually
	// more readable, however it doesn't add to the actual appearance...
	hierarchyGroupIndent = @"    ";
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyFooterToData:(NSMutableData*) data
{	
	[self appendLine:@"  </div>" toData:data];
	[self appendLine:@"  <div class=\"clear\"></div>" toData:data];
	[self appendLine:@"  <div class=\"footer\">" toData:data];
	[self appendLine:@"    <a href=\"index.html\">Main objects reference</a>" toData:data];
	[self appendLine:@"  </div>" toData:data];
	[self appendFileFooterToData:data
				 withLastUpdated:NO
					andIndexLink:NO];
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupHeaderToData:(NSMutableData*) data
{
	hierarchyGroupIndent = [hierarchyGroupIndent stringByAppendingString:@"  "];
	
	[self appendString:hierarchyGroupIndent toData:data];
	[self appendLine:@"<ul>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupFooterToData:(NSMutableData*) data
{
	[self appendString:hierarchyGroupIndent toData:data];
	[self appendLine:@"</ul>" toData:data];
	
	int length = [hierarchyGroupIndent length] - 2;
	hierarchyGroupIndent = [hierarchyGroupIndent substringToIndex:length];
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyGroupItemToData:(NSMutableData*) data
							   fromItem:(id) item
								  index:(int) index
{
	NSString* reference = [self extractHierarchyGroupItemRef:item];
	NSString* name = [self extractHierarchyGroupItemName:item];
	
	// Append the <li> opening tag.
	[self appendString:hierarchyGroupIndent toData:data];
	[self appendLine:@"  <li>" toData:data];
	
	// Append the item name and reference.
	[self appendString:hierarchyGroupIndent toData:data];
	if (reference)
	{
		[self appendString:@"    <a href=\"" toData:data];
		[self appendString:reference toData:data];
		[self appendString:@"\">" toData:data];
	}
	[self appendString:name toData:data];
	if (reference)
	{
		[self appendString:@"</a>" toData:data];
	}
	[self appendLine:@"" toData:data];
		
	// Ask the subclass to generate data for all the children.
	[self generateHierarchyGroupChildrenToData:data forItem:item];
	
	// Append the closing </li> tag.
	[self appendString:hierarchyGroupIndent toData:data];
	[self appendLine:@"  </li>" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Description helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromItem:(id) item
{
	NSArray* paragraphs = [self extractBriefParagraphsFromItem:item];
	[self appendDescriptionToData:data fromParagraphs:paragraphs];
}

//----------------------------------------------------------------------------------------
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromItem:(id) item
{
	NSArray* paragraphs = [self extractDetailParagraphsFromItem:item];
	[self appendDescriptionToData:data fromParagraphs:paragraphs];
}

//----------------------------------------------------------------------------------------
- (void) appendDescriptionToData:(NSMutableData*) data
				  fromParagraphs:(NSArray*) paragraphs
{
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
	if (item)
	{
		NSString* result = [self extractParagraphText:item];
		
		// Handle simple tags replacements.
		result = [result stringByReplacingOccurrencesOfString:@"<para>" withString:@"<p>"];
		result = [result stringByReplacingOccurrencesOfString:@"</para>" withString:@"</p>"];
		result = [result stringByReplacingOccurrencesOfString:@"<ref id" withString:@"<a href"];
		result = [result stringByReplacingOccurrencesOfString:@"</ref>" withString:@"</a>"];
		result = [result stringByReplacingOccurrencesOfString:@"<list>" withString:@"<ul>"];
		result = [result stringByReplacingOccurrencesOfString:@"</list>" withString:@"</ul>"];
		result = [result stringByReplacingOccurrencesOfString:@"<item>" withString:@"<li>"];
		result = [result stringByReplacingOccurrencesOfString:@"</item>" withString:@"</li>"];
		
		// Handle replacements with spans.
		result = [result stringByReplacingOccurrencesOfString:@"<bold>" withString:@"<span class=\"emphasize\">"];
		result = [result stringByReplacingOccurrencesOfString:@"</bold>" withString:@"</span>"];
		
		// Handle the example section.
		NSString* exampleTag = [NSString stringWithFormat:@"<div%@><pre>",
								cmd.xhtmlUseBorderedExamples ? 
								@" class=\"example\"" : 
								@""];
		result = [result stringByReplacingOccurrencesOfString:@"<example>" withString:exampleTag];
		result = [result stringByReplacingOccurrencesOfString:@"</example>" withString:@"</pre></div>"];
		
		[self appendLine:result toData:data];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendFileHeaderToData:(NSMutableData*) data
					  withTitle:(NSString*) title
				  andStylesheet:(NSString*) stylesheet
{
	[self appendString:@"<!DOCTYPE html PUBLIC " toData:data];
	[self appendString:@"\"-//W3C//DTD XHTML 1.0 STRICT//EN\" " toData:data];
	[self appendString:@"\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" toData:data];
	[self appendLine:@"" toData:data];
	
	[self appendString:@"<html " toData:data];
	[self appendString:@"xmlns=\"http://www.w3.org/1999/xhtml\" " toData:data];
	[self appendString:@"xml:lang=\"en\" lang=\"en\">" toData:data];
	[self appendLine:@"" toData:data];
	
	[self appendLine:@"<head>" toData:data];
	
	[self appendString:@"  <title>" toData:data];
	[self appendString:title toData:data];
	[self appendLine:@"</title>" toData:data];
	
	[self appendLine:@"  <meta http-equiv=\"Content-Type\" content=\"application/xhtml+xml;charset=utf-8\" />" 
			  toData:data];
	[self appendString:@"  <link rel=\"stylesheet\" type=\"text/css\" href=\"" toData:data];
	[self appendString:stylesheet toData:data];
	[self appendLine:@"\" />" toData:data];
	
	[self appendLine:@"  <meta name=\"generator\" content=\"appledoc\" />" 
			  toData:data];
	[self appendLine:@"</head>" toData:data];
	[self appendLine:@"<body>" toData:data];
	[self appendLine:@"  <div id=\"mainContainer\">" toData:data];
	
	[self appendString:@"    <h1>" toData:data];
	[self appendString:title toData:data];
	[self appendLine:@"</h1>" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendFileFooterToData:(NSMutableData*) data
				withLastUpdated:(BOOL) showLastUpdate
				   andIndexLink:(BOOL) showBackToIndex
{	
	if (showLastUpdate || showBackToIndex)
	{
		[self appendLine:@"    <hr />" toData:data];
		[self appendString:@"    <p id=\"lastUpdated\">" toData:data];
	
		if (showLastUpdate && self.lastUpdated && [self.lastUpdated length] > 0)
		{
			[self appendString:@"Last updated: " toData:data];
			[self appendString:self.lastUpdated toData:data];
			[self appendLine:@"      <br />" toData:data];
		}
		
		if (showBackToIndex)
		{
			[self appendString:@"Back to " toData:data];
			
			[self appendString:@"<a href=\"../" toData:data];
			[self appendString:[self outputIndexFilename] toData:data];
			[self appendString:@"\">index</a>" toData:data];
			
			[self appendString:@" / " toData:data];
			
			[self appendString:@"<a href=\"../" toData:data];
			[self appendString:[self outputHierarchyFilename] toData:data];
			[self appendString:@"\">hierarchy</a>." toData:data];
			
			[self appendLine:@"" toData:data];
		}
		
		[self appendLine:@"    </p>" toData:data];
	}
	
	[self appendLine:@"  </div>" toData:data];
	[self appendLine:@"</body>" toData:data];
	[self appendLine:@"</html>" toData:data];
}

@end
