//
//  MarkdownOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "MarkdownOutputGenerator.h"
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

@implementation MarkdownOutputGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (id) initWithDatabase:(NSMutableDictionary*) data
{
	self = [super initWithDatabase:data];
	if (self)
	{
		linkReferences = [[NSMutableDictionary alloc] init];
		[self resetDescriptionVarsToDefaults];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	[linkReferences release], linkReferences = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark OutputInfoProvider protocol implementation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) outputFilesExtension
{
	return @".markdown";
}

//----------------------------------------------------------------------------------------
- (NSString*) outputReferencesExtension
{
	return @".html";
}

//----------------------------------------------------------------------------------------
- (NSString*) outputBasePath
{
	return [cmd.outputPath stringByAppendingPathComponent:@"markdown"];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) isOutputGenerationEnabled
{
	return cmd.createMarkdown;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectHeaderToData:(NSMutableData*) data
{
	[linkReferences removeAllObjects];
	[self appendHeaderToData:data forString:self.objectTitle level:1];
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectFooterToData:(NSMutableData*) data
{
	// Append horizontal rule.
	[self appendLine:@"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" 
			  toData:data];
	
	// Append last updated text with spaces at the end so line break is created.
	[self appendString:self.lastUpdated toData:data];
	[self appendLine:@"   " toData:data];
	
	// Append back to links.
	[self appendString:@"Back to " toData:data];
	[self appendLinkToData:data fromReference:[self outputIndexFilename] andDescription:@"Index"];
	[self appendString:@" / " toData:data];
	[self appendLinkToData:data fromReference:[self outputHierarchyFilename] andDescription:@"Hieararchy"];
	[self appendLine:@"." toData:data];
	
	// Append the links.
	[self appendLinkFootnotesToData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object info table handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoItemToData:(NSMutableData*) data
						  fromItems:(NSArray*) items
							  index:(int) index
							   type:(int) type;
{
	// Prepare the description and the delimiter. Note that the description already
	// contains all spaces that align the data afterwards.
	NSString* description = nil;
	NSString* delimiter = nil;
	NSString* formatter = nil;
	switch (type)
	{
		case kTKObjectInfoItemInherits:
			description = @"Inherits from: ";
			delimiter = @" : ";
			formatter = @"`";
			break;
		case kTKObjectInfoItemConforms:
			description = @"Conforms to:   ";
			delimiter = @", ";
			formatter = @"`";
			break;
		case kTKObjectInfoItemDeclared:
			description = @"Declared in:   ";
			delimiter = @", ";
			formatter = @"";
			break;
	}

	// Append the line marker followed by the description.
	[self appendString:@"* " toData:data];
	[self appendString:description toData:data];

	// Append all items.
	for (int i = 0; i < [items count]; i++)
	{
		id item = [items objectAtIndex:i];
		NSString* reference = [self extractObjectInfoItemRef:item];
		NSString* value = [self extractObjectInfoItemValue:item];
		
		// If the item is known, we should append it as a reference, otherwise as
		// normal text.
		if (!reference)
		{
			[self appendString:formatter toData:data];
			[self appendString:value toData:data];
			[self appendString:formatter toData:data];
		}
		else
		{
			[self appendLinkToData:data fromReference:reference andDescription:value];
		}

		
		// If there's more elements, append delimiter after each except last one.
		if (i < [items count] - 1) [self appendString:delimiter toData:data];
	}
	
	// Finish with a new line.
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoFooterToData:(NSMutableData*) data
{
	[self appendLine:@"" toData:data];
	[self appendLine:@"" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object overview handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectOverviewToData:(NSMutableData*) data 
						   fromItem:(id) item
{
	[self appendHeaderToData:data forString:@"Overview" level:2];
	[self appendLine:@"" toData:data];
	
	[self resetDescriptionVarsToDefaults];
	[self appendBriefDescriptionToData:data fromItem:item];
	[self appendDetailedDescriptionToData:data fromItem:item];	
	
	[self appendLine:@"" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object tasks handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksHeaderToData:(NSMutableData*) data
{
	[self appendHeaderToData:data forString:@"Tasks" level:2];
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksFooterToData:(NSMutableData*) data
{
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskHeaderToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
	[self appendHeaderToData:data forString:[self extractObjectTaskName:item] level:3];
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskMemberToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
	// Append list item marker.
	[self appendString:@"*\t" toData:data];
	
	// Append the name of the method or property.
	[self appendString:@"`" toData:data];
	[self appendString:[self extractObjectMemberName:item] toData:data];
	[self appendLine:@"`" toData:data];
	
	// Append brief description in the second line. Make sure it is properly indented.
	[self appendString:@"\t" toData:data];
	[self resetDescriptionVarsToDefaults];
	[self appendBriefDescriptionToData:data 
							  fromItem:[self extractObjectMemberDescriptionItem:item]];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object members main documentation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupHeaderToData:(NSMutableData*) data 
										type:(int) type
{
	// Prepare the description.
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
	
	// Append the group header. Note that contrary to the rest of the headers which
	// use a single line gap before the text is appended, group headers use two line
	// gap to make the first item more distinguishable.
	[self appendHeaderToData:data forString:description level:2];
	[self appendLine:@"" toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupFooterToData:(NSMutableData*) data 
										type:(int) type
{
	[self appendLine:@"" toData:data];
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
	[self appendLine:@"" toData:data];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Member helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberTitleToData:(NSMutableData*) data
							  fromItem:(id) item
{
	// Previous member (or header) already appended one empty line, however we want to
	// delimit each member by two lines so they are more clearly visible in the output.
	[self appendLine:@"" toData:data];
	[self appendHeaderToData:data forString:[self extractObjectMemberName:item] level:3];
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberOverviewToData:(NSMutableData*) data
								 fromItem:(id) item
{
	// Append the brief description. First get the description item and use it to append
	// brief description to the output. The description is fully formatted.
	id descriptionItem = [self extractObjectMemberDescriptionItem:item];
	if (descriptionItem)
	{
		[self resetDescriptionVarsToDefaults];
		descriptionDelimitSingleParameters = NO;
		descriptionDelimitLastParameter = NO;
		[self appendBriefDescriptionToData:data fromItem:descriptionItem];
		[self appendLine:@"" toData:data];
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberPrototypeToData:(NSMutableData*) data
								  fromItem:(id) item
{
	// Append the prototype. We need to append an empty line afterwards (after the empty
	// line which actually ends the prototype line).
	id prototypeItem = [self extractObjectMemberPrototypeItem:item];
	if (prototypeItem)
	{
		NSArray* items = [self extractObjectMemberPrototypeSubitems:prototypeItem];
		if (items)
		{
			[self appendString:@"\t" toData:data];
			for (id item in items)
			{
				[self appendString:[self extractObjectMemberPrototypeItemValue:item] toData:data];
			}
			[self appendLine:@"" toData:data];
			[self appendLine:@"" toData:data];
		}
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
		[self appendHeaderToData:data forString:title level:4];
		for (id parameterItem in parameterItems)
		{
			// Append the section item list marker.
			[self appendString:@"*\t" toData:data];
			
			// Append the section name.
			[self appendString:@"_" toData:data];
			[self appendString:[self extractObjectParameterName:parameterItem] toData:data];
			[self appendString:@"_" toData:data];
			
			// Append the section item description. Since items are displayed as unordered
			// list, place a tab before each line. However we don't want to prefix the
			// first line, since we already did that after the item marker above.
			[self appendString:@" " toData:data];
			id descriptionItem = [self extractObjectParameterDescriptionItem:parameterItem];
			if (descriptionItem)
			{
				NSArray* descriptions = [self extractDescriptionsFromItem:descriptionItem];
				[self resetDescriptionVarsToDefaults];
				descriptionBlockLinePrefix = @"\t";
				descriptionBlockPrefixFirstLine = NO;
				descriptionDelimitSingleParameters = NO;
				descriptionDelimitLastParameter = NO;
				[self appendDescriptionToData:data fromDescriptionItems:descriptions];
			}

			// End parameter description paragraph.
			[self appendLine:@"" toData:data];
		}
		
		// Make a one line gap before the next section.
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberReturnToData:(NSMutableData*) data
							   fromItem:(id) item
{
	id returnItem = [self extractObjectMemberReturnItem:item];
	if (returnItem)
	{
		[self appendHeaderToData:data forString:@"Return value" level:4];
		
		NSArray* descriptions = [self extractDescriptionsFromItem:returnItem];
		[self resetDescriptionVarsToDefaults];
		descriptionDelimitSingleParameters = NO;
		descriptionDelimitLastParameter = NO;
		[self appendDescriptionToData:data fromDescriptionItems:descriptions];
		
		[self appendLine:@"" toData:data];
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberDiscussionToData:(NSMutableData*) data
								   fromItem:(id) item
{
	id descriptionItem = [self extractObjectMemberDescriptionItem:item];
	if (descriptionItem)
	{
		NSArray* descriptions = [self extractDetailDescriptionsFromItem:descriptionItem];
		if (descriptions && [self isDescriptionUsed:descriptions])
		{
			[self appendHeaderToData:data forString:@"Discussion" level:4];
			[self resetDescriptionVarsToDefaults];
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
		NSArray* descriptions = [self extractDescriptionsFromItem:warningItem];

		[self resetDescriptionVarsToDefaults];
		descriptionBlockPrefix = @"__";
		descriptionBlockSuffix = @"__";
		descriptionDelimitSingleParameters = NO;
		descriptionDelimitLastParameter = NO;
		descriptionMarkEmphasis = NO;
		
		[self appendDescriptionToData:data fromDescriptionItems:descriptions];		
		[self appendLine:@"" toData:data];
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberBugToData:(NSMutableData*) data
					  fromItem:(id) item
{
	id bugItem = [self extractObjectMemberBugItem:item];
	if (bugItem)
	{
		NSArray* descriptions = [self extractDescriptionsFromItem:bugItem];
		
		[self resetDescriptionVarsToDefaults];
		descriptionBlockPrefix = @"__";
		descriptionBlockSuffix = @"__";
		descriptionDelimitSingleParameters = NO;
		descriptionDelimitLastParameter = NO;
		descriptionMarkEmphasis = NO;
		
		[self appendDescriptionToData:data fromDescriptionItems:descriptions];		
		[self appendLine:@"" toData:data];
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberSeeAlsoToData:(NSMutableData*) data
								fromItem:(id) item
{
	// Note that we only append text, we don't use member references, however we do
	// use inter-object references.
	NSArray* items = [self extractObjectMemberSeeAlsoItems:item];
	if (items)
	{
		[self appendHeaderToData:data forString:@"See also" level:4];
		for (id item in items)
		{
			NSString* reference = [self extractDescriptionReference:item];
			NSString* text = [self extractDescriptionText:item];
			
			[self appendString:@"*\t" toData:data];
			[self appendLinkToData:data fromReference:reference andDescription:text];
			[self appendLine:@"" toData:data];
		}
		[self appendLine:@"" toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberFileToData:(NSMutableData*) data
							 fromItem:(id) item
{
	NSString* filename = [self extractObjectMemberFile:item];
	if (filename)
	{
		[self appendHeaderToData:data forString:@"Declared in" level:4];
		[self appendLine:filename toData:data];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Index file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexFooterToData:(NSMutableData*) data
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Index groups handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupHeaderToData:(NSMutableData*) data
								 type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupFooterToData:(NSMutableData*) data
								 type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupItemToData:(NSMutableData*) data
						   fromItem:(id) item
							  index:(int) index
							   type:(int) type
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Hierarchy groups handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHierarchyHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendHierarchyFooterToData:(NSMutableData*) data
{	
}

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
#pragma mark Description helpers
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromItem:(id) item
{
	NSArray* descriptions = [self extractBriefDescriptionsFromItem:item];
	[self appendDescriptionToData:data fromDescriptionItems:descriptions];
}

//----------------------------------------------------------------------------------------
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromItem:(id) item
{
	NSArray* descriptions = [self extractDetailDescriptionsFromItem:item];
	[self appendDescriptionToData:data fromDescriptionItems:descriptions];
}

//----------------------------------------------------------------------------------------
- (void) appendDescriptionToData:(NSMutableData*) data 
			fromDescriptionItems:(NSArray*) items
{
	NSMutableString* output = [NSMutableString string];
	NSString* reference = nil;
	BOOL handleCodeEnd = YES;
	int paragraphsCount = 0;
	descriptionBlockLineCount = 0;
	
	// Append block prefix.
	[self appendString:descriptionBlockPrefix toData:data];
	
	// Append all descriptions.
	for (id item in items)
	{
		int type = [self extractDescriptionType:item];
		switch (type) 
		{
			// If a second or greater parameter is detected, we should delimit previous 
			// one, otherwise not. Note that we handle the last parameter after the loop
			// ends - see code below the for statement below.
			case kTKDescriptionParagraphStart:
				if (paragraphsCount >= 1)
				{
					[self appendLine:@"" toData:data];
					[self appendLine:@"" toData:data];
				}
				paragraphsCount++;
				break;
			case kTKDescriptionParagraphEnd:
				if ([output length] > 0)
				{
					[self appendParagraphToData:data fromString:output linePrefix:@"" wrap:YES];
					[output setString:@""];
				}
				break;
				
			// Handle the lists. Note that we treat each list item as a paragraph but
			// without incrementing the paragraph count. When list starts, we finish
			// current paragraph (if any) and make sure the list is started with one
			// empty line break. When the list ends, we make sure the list is delimited
			// by an empty line break before any other text is appended.
			case kTKDescriptionListStart:
				if ([output length] > 0)
				{
					[self appendParagraphToData:data fromString:output linePrefix:@"" wrap:YES];
					[self appendLine:@"" toData:data];
					[self appendLine:@"" toData:data];
					[output setString:@""];
				}
				break;
			case kTKDescriptionListEnd:
				[self appendLine:@"" toData:data];
				break;
			case kTKDescriptionListItemStart:
				[output appendString:@"*"];
				break;
			case kTKDescriptionListItemEnd:
				if ([output length] > 0)
				{
					[self appendParagraphToData:data fromString:output linePrefix:@"\t" wrap:YES];
					[self appendLine:@"" toData:data];
					[output setString:@""];
				}
				break;
				
			// Setup word formatting markers.
			case kTKDescriptionCodeStart:
				[output appendString:@"##{"];
				[output appendString:@"`"];
				handleCodeEnd = YES;
				break;
			case kTKDescriptionCodeEnd:
				if (handleCodeEnd) [output appendString:@"`"];
				[output appendString:@"}##"];
				break;				
			case kTKDescriptionStrongStart:
				if (descriptionMarkEmphasis) [output appendString:@"*"];
				break;
			case kTKDescriptionStrongEnd:
				if (descriptionMarkEmphasis) [output appendString:@"*"];
				break;				
			case kTKDescriptionEmphasisStart:
				if (descriptionMarkEmphasis) [output appendString:@"__"];
				break;
			case kTKDescriptionEmphasisEnd:
				if (descriptionMarkEmphasis) [output appendString:@"__"];
				break;
				
			// When starting example, flush current output. When ending example, create
			// an empty, delimiter, line. Note that we handle example as new paragraph.
			// If there was a paragraph before, we should append new line before it.
			// Note that we need to indent each line of the example. Also note that we
			// need to make sure the example is indented in both cases - if the whole
			// example is enclosed within kTKDescriptionExampleStart and kTKDescriptionExampleEnd
			// block (i.e. not part of a paragraph) or the example is part of the paragraph.
			// In the first case, we only do it if there was a paragraph written before.
			case kTKDescriptionExampleStart:
				if ([output length] > 0)
				{
					[self appendParagraphToData:data fromString:output linePrefix:@"" wrap:YES];
					[self appendLine:@"" toData:data];
					[self appendLine:@"" toData:data];
					[output setString:@""];
				}
				else if (paragraphsCount >= 1)
				{
					[self appendLine:@"" toData:data];
					[self appendLine:@"" toData:data];
				}
				break;
			case kTKDescriptionExampleEnd:
				if ([output length] > 0)
				{
					[self appendParagraphToData:data fromString:output linePrefix:@"\t" wrap:NO];
					[output setString:@""];
				}
				break;
				
			// When reference is being handled, tread the text as the reference, not
			// as normal text. Here we only set the flag which we check when text is
			// reported (see below). Note that we need to remove the code prefix if
			// used. We handle this manually for references.
			case kTKDescriptionReferenceStart:
				if ([output hasSuffix:@"`"])
				{
					NSRange range = NSMakeRange([output length] - 1, 1);
					[output deleteCharactersInRange:range];
					handleCodeEnd = NO;
				}
				reference = [self extractDescriptionReference:item];
				break;
			case kTKDescriptionReferenceEnd:
				reference = nil;
				break;
				
			// If we are handling reference, treat the text as the reference, otherwise
			// treat it as normal text.
			case kTKDescriptionText: {
				NSString* value = [self extractDescriptionText:item];
				if (reference) 
				{
					value = [self formatLinkFromReference:reference andDescription:value];
					value = [NSString stringWithFormat:@"##{%@}##", value];
				}
				[output appendString:value];
			} break;
		}
	}
	
	// Append block suffix.
	[self appendString:descriptionBlockSuffix toData:data];
	
	// Close the parameter is necessary. We should only delimit the last parameter if
	// needed. However if there was only one parameter, we should only delimit it if
	// the flag is set.
	if (descriptionDelimitLastParameter)
	{
		if (paragraphsCount > 1 || descriptionDelimitSingleParameters)
		{
			[self appendLine:@"" toData:data];
			[self appendLine:@"" toData:data];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) appendParagraphToData:(NSMutableData*) data
					fromString:(NSString*) string
					linePrefix:(NSString*) prefix
						  wrap:(BOOL) wrap
{
	// Cleanup double code markers from references. These are added by kTKDescriptionCodeStart 
	// and kTKDescriptionCodeEnd cases and the additional with link generation code. Also
	// remove starting and trailing new lines - these are dealt with in the "parent" method.
	NSCharacterSet* newlineSet = [NSCharacterSet newlineCharacterSet];
	string = [string stringByReplacingOccurrencesOfString:@"##{`##{`" withString:@"##{`"];
	string = [string stringByReplacingOccurrencesOfString:@"`}##`}##" withString:@"`}##"];
	string = [string stringByTrimmingCharactersInSet:newlineSet];
	
	// If no word wrap is desired, just emmit the whole string.
	if (cmd.markdownLineLength <= 0)
	{
		if ([string length] > 0)
		{
			if (descriptionBlockLineCount > 0 || descriptionBlockPrefixFirstLine)
			{
				[self appendString:descriptionBlockLinePrefix toData:data];
				[self appendString:prefix toData:data];
			}
			[self appendString:string toData:data];
			descriptionBlockLineCount++;
		}
		return;
	}

	// If we need to wrap words, append words to the line until the line reaches
	// it's maximum width. At that point append the line and continue with a new.
	if (wrap)
	{
		// Setup the emmiting variables.
		NSCharacterSet* delimitersSet = [NSCharacterSet whitespaceCharacterSet];
		NSMutableString* line = [NSMutableString string];
		NSMutableString* phrase = [NSMutableString string];
		NSString* word = nil;
		BOOL canWrap = YES;
		
		// Append the given paragraph and make sure it fits the maximum line width.
		NSScanner* scanner = [NSScanner scannerWithString:string];
		while (![scanner isAtEnd])
		{
			if ([scanner scanUpToCharactersFromSet:delimitersSet intoString:&word])
			{
				// Don't allow wrapping multiple word code such as method names. However
				// if the word is too long, we should wrap it to the start of next line.
				// First we need to add the word to the phrase string which is used
				// temporarily until all words constituting the phrase are processed.
				// Then we use the phrase string to see the actual length of the phrase.
				// Note that we use the actual phrase string to determine if we are in
				// the middle of the multi-word phrase.
				BOOL isNonWrapStart = ([word rangeOfString:@"##{"].location != NSNotFound);
				BOOL isNonWrapEnd = ([word rangeOfString:@"}##"].location != NSNotFound);
				if (isNonWrapStart) canWrap = NO;
				if (isNonWrapEnd) canWrap = YES;
				
				// Remove wrapping prefix and/or suffix.
				if (isNonWrapStart) word = [word stringByReplacingOccurrencesOfString:@"##{" withString:@""];
				if (isNonWrapEnd) word = [word stringByReplacingOccurrencesOfString:@"}##" withString:@""];
				
				// Start the phrase if we detect non-wrap start prefix. If the phrase
				// string is non-empty, or non-wrap end suffix is detected, append the
				// word to existing phrase string. Note that we must make sure to append
				// only if the phrase is not single word (single word phrases have non-wrap
				// start and end markers present at the same time). Also note that we need
				// to append a space in between phrase words.
				if (isNonWrapStart) [phrase setString:word];
				else if ([phrase length] > 0) [phrase appendFormat:@" %@", word];
				
				// Finish the line when necessary (if allowed - we postpone this until
				// non-wrappable phrases are parsed completely).
				if (canWrap)
				{
					// If we just finished the phrase, set it as current word since the
					// code below uses that for processing (we handle multiple words
					// non-wrapping phrases as a single words).
					if ([phrase length] > 0) 
					{
						word = [[phrase copy] autorelease];
						[phrase setString:@""];
					}
					
					// If the line cannot accomodate the word, break it. Note that we
					// still allow the line to continue if it is short enough and the
					// added word keeps it within certain tolerance.
					int newLineLength = [line length] + [word length];
					if (newLineLength > cmd.markdownLineLength)
					{
						if ([line length] > cmd.markdownLineLength - cmd.markdownLineWrapThreshold ||
							newLineLength > cmd.markdownLineLength + cmd.markdownLineWrapMargin)
						{
							if (descriptionBlockLineCount > 0 || descriptionBlockPrefixFirstLine)
							{
								[self appendString:descriptionBlockLinePrefix toData:data];
								[self appendString:prefix toData:data];
							}
							[self appendLine:line toData:data];
							[line setString:@""];
						}
					}
					
					// Append the word to the line.
					[line appendString:word];
					[line appendString:@" "];
				}
			}
		}	
		
		// Append the remaining text.
		if ([line length] > 0)
		{
			if (descriptionBlockLineCount > 0 || descriptionBlockPrefixFirstLine)
			{
				[self appendString:descriptionBlockLinePrefix toData:data];
				[self appendString:prefix toData:data];
			}
			[self appendString:line toData:data];
		}
	}
	
	// If non-wrapping mode is desired, get individual lines from the string and prefix
	// each with global and current prefix.
	else
	{
		NSArray* lines = [string componentsSeparatedByCharactersInSet:newlineSet];
		for (NSString* line in lines)
		{
			[self appendString:descriptionBlockLinePrefix toData:data];
			[self appendString:prefix toData:data];
			[self appendLine:line toData:data];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) resetDescriptionVarsToDefaults
{
	descriptionBlockPrefix = @"";
	descriptionBlockSuffix = @"";
	descriptionBlockLinePrefix = @"";
	descriptionBlockPrefixFirstLine = YES;
	descriptionDelimitSingleParameters = YES;
	descriptionDelimitLastParameter = YES;
	descriptionMarkEmphasis = YES;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendHeaderToData:(NSMutableData*) data
				  forString:(NSString*) string
					  level:(int) level
{
	NSParameterAssert(level >= 1 && level <= 10);
	
	// If header level is 3 or greater or atx style should be used for all, prepare the
	// prefix and suffix string and write it to the data, followed by a space.
	NSString* headerMarker = nil;
	if (level >= 3)
	{	
		// Prepare the string.
		NSMutableString* marker = [NSMutableString string];
		for (int i = 0; i < level; i++)
		{
			[marker appendString:@"#"];
		}
		headerMarker = marker;
		
		// Write it and append a space.
		[self appendString:headerMarker toData:data];
		[self appendString:@" " toData:data];
	}
	
	// Write the actual title.
	[self appendString:string toData:data];
	
	// Write the suffix or underline.
	if (level >= 3)
	{
		[self appendString:@" " toData:data];
		[self appendLine:headerMarker toData:data];
	}
	else if (level == 2)
	{
		[self appendLine:@"" toData:data];
		[self appendUnderlineToData:data forString:string underline:@"-"];
	}
	else if (level == 1)
	{
		[self appendLine:@"" toData:data];
		[self appendUnderlineToData:data forString:string underline:@"="];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendUnderlineToData:(NSMutableData*) data
					 forString:(NSString*) string
					 underline:(NSString*) underline
{
	if ([string length] > 0 && [underline length] > 0)
	{
		NSMutableString* underlineString = [NSMutableString stringWithCapacity:[string length]];
		while ([underlineString length] < [string length])
		{
			[underlineString appendString:underline];
		}
		[self appendLine:underlineString toData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) appendLinkToData:(NSMutableData*) data
			fromReference:(NSString*) reference
		   andDescription:(NSString*) description
{
	NSString* link = [self formatLinkFromReference:reference andDescription:description];
	[self appendString:link toData:data];
}

//----------------------------------------------------------------------------------------
- (void) appendLinkFootnotesToData:(NSMutableData*) data
{
	if (cmd.markdownReferenceStyleLinks && [linkReferences count] > 0)
	{
		[self appendLine:@"" toData:data];
		
		// Get the dictionary of all footnote numbers and the corresponding data.
		// Note that we calculate the largest reference length so that we can align
		// the output better later on.
		int maxReferenceLength = 0;
		NSMutableDictionary* numbers = [NSMutableDictionary dictionary];
		for (NSString* reference in [linkReferences allKeys])
		{
			NSDictionary* footnoteData = [linkReferences objectForKey:reference];
			
			int referenceLength = [[footnoteData objectForKey:@"Reference"] length];
			if (referenceLength > maxReferenceLength) maxReferenceLength = referenceLength;
			
			NSNumber* number = [footnoteData objectForKey:@"Number"];
			[numbers setObject:footnoteData forKey:number];
		}
		
		// Prepare the sorted array of all numbers and calculate the greatest number size
		// again for better alignement later on.
		NSArray* sortedKeys = [[numbers allKeys] sortedArrayUsingSelector:@selector(compare:)];
		int maxNumberLength = [[[sortedKeys lastObject] stringValue] length];

		// Emmit all link footnotes sorted by their number.
		for (NSNumber* number in sortedKeys)
		{
			NSDictionary* footnoteData = [numbers objectForKey:number];
			NSString* numberText = [number stringValue];
			int length = [numberText length];
			
			// Right pad numbers.
			while (length < maxNumberLength)
			{
				[self appendString:@" " toData:data];
				length++;
			}
			[self appendString:@"[" toData:data];
			[self appendString:numberText toData:data];
			[self appendString:@"]: " toData:data];
			
			// Append the reference.
			NSString* reference = [footnoteData objectForKey:@"Reference"];
			[self appendString:@"<" toData:data];
			[self appendString:reference toData:data];
			[self appendString:@"> " toData:data];
			
			// Pad description so that all are aligned properly - i.e. all start at the
			// same column.
			length = [reference length];
			while (length < maxReferenceLength)
			{
				[self appendString:@" " toData:data];
				length++;
			}
			[self appendString:@"\"" toData:data];
			[self appendString:[footnoteData objectForKey:@"Description"] toData:data];
			[self appendLine:@"\"" toData:data];
		}
	}
}

//----------------------------------------------------------------------------------------
- (NSString*) formatLinkFromReference:(NSString*) reference
					   andDescription:(NSString*) description
{
	NSParameterAssert(reference != nil || description != nil);
	
	// If the link description is not given, use reference.
	if (!description) description = reference;

	// If this is a member link, only emmit the description.
	if (![self isInterObjectReference:reference]) reference = nil;
	
	// If reference is given, emmit standard reference and text.
	if (reference)
	{
		// If we should use reference style links, we only output the link description
		// and ID. We should handle IDs properly - if the link was already used, use 
		// it's original ID, otherwise create a ID and add it to the dictionary.
		if (cmd.markdownReferenceStyleLinks)
		{
			NSNumber* footnoteNumber = [linkReferences objectForKey:reference];
			if (!footnoteNumber)
			{
				int count = [linkReferences count];
				footnoteNumber = [NSNumber numberWithInt:count + 1];
				NSDictionary* footnoteData = [NSDictionary dictionaryWithObjectsAndKeys:
											  footnoteNumber, @"Number",
											  reference, @"Reference", 
											  description, @"Description", nil];
				[linkReferences setObject:footnoteData forKey:reference];
			}
			
			// Append the description and footnote index.
			return [NSString stringWithFormat:@"[`%@`][%@]", description, footnoteNumber];
		}
		
		// If we use inline style links, output the description and reference.
		return [NSString stringWithFormat:@"[%@](%@)", reference, description];
	}
	
	// If reference is not given, emmit text only.
	return [NSString stringWithFormat:@"`%@`", description];
}

@end

