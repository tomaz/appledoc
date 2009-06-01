//
//  GeneratorBase.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "GeneratorBase.h"
#import "GeneratorBase+GeneralParsingAPI.h"
#import "GeneratorBase+ObjectParsingAPI.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines private methods for use within @c GeneratorBase class only.

￼￼These are helper methods to make the main @c generateOutput() less cluttered. The methods
should only be used internaly by the @c GeneratorBase, they are not intended to be used
by the subclasses. Therefore the parameters are closely coupled to the underlying clean
object markup which is XML.
*/
@interface GeneratorBase ()

/** Generates the object info section if necessary.￼
 
From here the following messages are sent to the subclass:
- @c appendObjectInfoHeaderToData:()
- @c appendObjectInfoFooterToData:()

@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutput
@see generateOverviewSectionToData:
@see generateTasksSectionToData:
@see generateMembersSectionToData:
@see generateInfoSectionToData:fromNodes:index:type:
*/
- (void) generateInfoSectionToData:(NSMutableData*) data;

/** Generates the given object info section if necessary.￼
 
This is sent from @c generateInfoSectionToData:() for each info section item. From here 
the following message is sent to the subclass.
- @c appendObjectInfoItemToData:fromItems:index:type:()
 
The message is only send if the given @c nodes array is not empty. The @c type parameter 
can be one of the following:
- @c kTKInfoItemInherits: The @c nodes contain inherit from information.
- @c kTKInfoItemConforms: The @c nodes contain conforms to information.
- @c kTKInfoItemDeclared: The @c nodex contain declared in information.
 
@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@param nodes ￼￼￼￼￼￼The array of @c NSXMLElement instances to append to.
@param index ￼￼￼￼￼￼Pointer to zero based index of the section item. The method will increment
	if the given @c nodes is not empty.
@param type ￼￼￼￼￼￼Type of the section item.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateInfoSectionToData:
*/
- (void) generateInfoSectionToData:(NSMutableData*) data 
						 fromNodes:(NSArray*) nodes 
							 index:(int*) index
							  type:(int) type;

/** Generates the object overview data if necessary.￼

This is where the following messages are sent to the subclass:
- @c appendObjectOverviewToData:()

@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutput
@see generateInfoSectionToData:
@see generateTasksSectionToData:
@see generateMembersSectionToData:
*/
- (void) generateOverviewSectionToData:(NSMutableData*) data;

/** Generates the tasks section data if necessary.￼

This is where the following messages are sent to the subclass:
- @c appendObjectTasksHeaderToData:()
- @c appendObjectTaskHeaderToData:fromItem:index()
- @c appendObjectTaskMemberToData:fromItem:index:()
- @c appendObjectTaskFooterToData:fromItem:index()
- @c appendObjectTasksFooterToData:()

@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutput
@see generateInfoSectionToData:
@see generateOverviewSectionToData:
@see generateMembersSectionToData:
*/
- (void) generateTasksSectionToData:(NSMutableData*) data;

/** Generates the main members documentation section if necessary.￼

This is where the following messages are sent to the subclass:
- @c appendObjectMembersHeaderToData:()
- @c appendObjectMembersFooterToData:()

@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutput
@see generateInfoSectionToData:
@see generateOverviewSectionToData:
@see generateTasksSectionToData:
@see generateMemberSectionToData:fromItems:type:
*/
- (void) generateMembersSectionToData:(NSMutableData*) data;

/** Generates the given main members documentation section.￼

This is sent from @c generateMembersSectionToData:() for each group of members that
has at least one documented entry. This is where the following messages are sent to the 
subclass:
- @c appendObjectMemberGroupHeaderToData:type:() **
- @c appendObjectMemberToData:fromItem:index:() **
- @c appendObjectMemberGroupFooterToData:() **

The @c type parameter can be one of the following:￼
- @c kTKMemberTypeClass: The @c nodes describes class members.
- @c kTKMemberTypeInstance: The @c nodes describes instance members.
- @c kTKMemberTypeProperty: The @c nodes describes properties.
 
@param data ￼￼￼￼￼￼The @c NSMutableData to append to.
@param nodes ￼￼￼￼￼￼The array of @c NSXMLElement instances representing individual members.
@param type ￼￼￼￼￼￼The type of the instances.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateMembersSectionToData:
*/
- (void) generateMemberSectionToData:(NSMutableData*) data 
						   fromNodes:(NSArray*) nodes 
								type:(int) type;

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@implementation GeneratorBase

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Construction & destruction
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	self.lastUpdated = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSData*) generateOutputForObject:(NSDictionary*) data
{
	NSParameterAssert(data != nil);

	// Setup the object data (only weak reference since this can't be changed in between
	// the generation), then ask the subclass to generate the data, cleanup and return.
	objectData = data;
	NSData* result = [self outputDataForObject];
	objectData = nil;	
	return result;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Objects output generation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSData*) outputDataForObject
{
	NSMutableData* result = [NSMutableData data];	
	[self appendObjectHeaderToData:result];
	[self generateInfoSectionToData:result];
	[self generateOverviewSectionToData:result];
	[self generateTasksSectionToData:result];
	[self generateMembersSectionToData:result];
	[self appendObjectFooterToData:result];	
	return result;
}

//----------------------------------------------------------------------------------------
- (void) generateInfoSectionToData:(NSMutableData*) data
{
	// Get all nodes that describe the object information.
	NSArray* baseNodes = [self.objectMarkup nodesForXPath:@"object/base" error:nil];
	NSArray* protocolNodes = [self.objectMarkup nodesForXPath:@"object/protocol" error:nil];
	NSArray* fileNodes = [self.objectMarkup nodesForXPath:@"object/file" error:nil];
	
	// If at least one is present, continue.
	if ([baseNodes count] > 0 || [protocolNodes count] > 0 || [fileNodes count] > 0)
	{
		int index = 0;
		[self appendObjectInfoHeaderToData:data];
		[self generateInfoSectionToData:data fromNodes:baseNodes index:&index type:kTKSectionItemInherits];
		[self generateInfoSectionToData:data fromNodes:protocolNodes index:&index type:kTKSectionItemConforms];
		[self generateInfoSectionToData:data fromNodes:fileNodes index:&index type:kTKSectionItemDeclared];
		[self appendObjectInfoFooterToData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateInfoSectionToData:(NSMutableData*) data 
					  fromNodes:(NSArray*) items 
						  index:(int*) index
						   type:(int) type;
{	
	if ([items count] > 0)
	{
		[self appendObjectInfoItemToData:data fromItems:items index:*index type:type];
		(*index)++;
	}
}

//----------------------------------------------------------------------------------------
- (void) generateOverviewSectionToData:(NSMutableData*) data
{
	// Append the object overview if the object is documented. Note that we only take
	// the first description node if there are more (shouldn't happen, but just in case).
	NSArray* overviewNodes = [self.objectMarkup nodesForXPath:@"object/description" error:nil];
	if ([overviewNodes count] > 0)
	{
		NSXMLElement* overviewNode = [overviewNodes objectAtIndex:0];
		[self appendObjectOverviewToData:data fromItem:overviewNode];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateTasksSectionToData:(NSMutableData*) data
{
	// Appends the tasks with short method descriptions if at least one section is
	// found with at least one member. Note that the sections are only handled if there's
	// at least one member, otherwise these messages are not sent, even if (empty) 
	// sections are encountered.
	NSArray* sectionNodes = [self.objectMarkup nodesForXPath:@"object/sections/section" error:nil];
	if ([sectionNodes count] > 0)
	{
		BOOL sectionsHandled = NO;
		for (int i = 0; i < [sectionNodes count]; i++)
		{
			NSXMLElement* sectionNode = [sectionNodes objectAtIndex:i];
			NSArray* memberNodes = [sectionNode nodesForXPath:@"member" error:nil];
			if ([memberNodes count] > 0)
			{
				// Append the sections header if not yet.
				if (!sectionsHandled)
				{
					[self appendObjectTasksHeaderToData:data];
					sectionsHandled = YES;
				}
				
				// Append section header.
				[self appendObjectTaskHeaderToData:data fromItem:sectionNode index:i];				
				
				// Process all section members.
				for (int n = 0; n < [memberNodes count]; n++)
				{
					NSXMLElement* memberNode = [memberNodes objectAtIndex:n];
					[self appendObjectTaskMemberToData:data fromItem:memberNode index:n];
				}
				
				// Append section footer.
				[self appendObjectTaskFooterToData:data fromItem:sectionNode index:i];
			}
		}
		
		// Append sections footer.
		if (sectionsHandled) [self appendObjectTasksFooterToData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateMembersSectionToData:(NSMutableData*) data
{
	// Get the lists of all member nodes for each member type.
	NSArray* classMethodNodes = [self.objectMarkup 
								 nodesForXPath:@"object/sections/section/member[@kind='class-method']" 
								 error:nil];
	NSArray* instanceMethodNodes = [self.objectMarkup 
									nodesForXPath:@"object/sections/section/member[@kind='instance-method']" 
									error:nil];
	NSArray* propertyNodes = [self.objectMarkup 
							  nodesForXPath:@"object/sections/section/member[@kind='property']" 
							  error:nil];

	// Append the main members documentation descriptions if at least one member group
	// is found with at least one documented member.
	if ([classMethodNodes count] > 0 || 
		[instanceMethodNodes count] > 0 || 
		[propertyNodes count] > 0)
	{
		// Ask the subclass to append members documentation header.
		[self appendObjectMembersHeaderToData:data];
		
		// Process all lists.
		[self generateMemberSectionToData:data fromNodes:classMethodNodes type:kTKMemberTypeClass];
		[self generateMemberSectionToData:data fromNodes:instanceMethodNodes type:kTKMemberTypeInstance];
		[self generateMemberSectionToData:data fromNodes:propertyNodes type:kTKMemberTypeProperty];
		
		// Ask the subclass to append members documentation footer.
		[self appendObjectMembersFooterToData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateMemberSectionToData:(NSMutableData*) data 
						   fromNodes:(NSArray*) nodes 
								type:(int) type
{
	if ([nodes count] > 0)
	{
		// Ask the subclass to append members group header.
		[self appendObjectMemberGroupHeaderToData:data type:type];
		
		// Ask the subclass to document all members of this group.
		for (int i = 0; i < [nodes count]; i++)
		{
			NSXMLElement* node = [nodes objectAtIndex:i];
			[self appendObjectMemberToData:data fromItem:node index:i];
		}
		
		// Ask the subclass to append members group footer.
		[self appendObjectMemberGroupFooterToData:data type:type];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark File header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectFooterToData:(NSMutableData*) data
{	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object info section handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectInfoItemToData:(NSMutableData*) data
						  fromItems:(NSArray*) items
							  index:(int) index
							   type:(int) type
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object overview section handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectOverviewToData:(NSMutableData*) data 
						   fromItem:(id) item;
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object sections handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTasksFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskHeaderToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskFooterToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectTaskMemberToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Object members main documentation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendObjectMembersHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMembersFooterToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupHeaderToData:(NSMutableData*) data 
										type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberGroupFooterToData:(NSMutableData*) data 
										type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendObjectMemberToData:(NSMutableData*) data 
						 fromItem:(id) item 
							index:(int) index
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

@synthesize lastUpdated;

@end
