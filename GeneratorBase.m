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
#import "GeneratorBase+ObjectSubclassAPI.h"
#import "GeneratorBase+IndexParsingAPI.h"
#import "GeneratorBase+IndexSubclassAPI.h"
#import "GeneratorBase+HierarchyParsingAPI.h"
#import "GeneratorBase+HierarchySubclassAPI.h"
#import "CommandLineParser.h"
#import "DoxygenConverter.h"
#import "LoggingProvider.h"
#import "Systemator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines private methods for use within @c GeneratorBase class only.

These are helper methods to make the main @c generateOutput() less cluttered. The methods
should only be used internaly by the @c GeneratorBase, they are not intended to be used
by the subclasses. Therefore the parameters are closely coupled to the underlying clean
object markup which is XML.
*/
@interface GeneratorBase ()

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object generation helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates the object info section if necessary.
 
From here the following messages are sent to the subclass:
- @c appendObjectInfoHeaderToData:()
- @c appendObjectInfoFooterToData:()

@param data The @c NSMutableData to append to.
@exception NSException Thrown if generation fails.
@see generateOutputForObject
@see generateOverviewSectionToData:
@see generateTasksSectionToData:
@see generateObjectMembersSectionToData:
@see generateObjectInfoSectionToData:fromNodes:index:type:
*/
- (void) generateObjectInfoSectionToData:(NSMutableData*) data;

/** Generates the given object info section if necessary.
 
This is sent from @c generateObjectInfoSectionToData:() for each info section item. From here 
the following message is sent to the subclass.
- @c appendObjectInfoItemToData:fromItems:index:type:()
 
The message is only send if the given @c nodes array is not empty. The @c type parameter 
can be one of the following:
- @c kTKObjectInfoItemInherits: The @c nodes contain inherit from information.
- @c kTKObjectInfoItemConforms: The @c nodes contain conforms to information.
- @c kTKObjectInfoItemDeclared: The @c nodex contain declared in information.
 
@param data The @c NSMutableData to append to.
@param nodes The array of @c NSXMLElement instances to append to.
@param index Pointer to zero based index of the section item. The method will increment
	if the given @c nodes is not empty.
@param type Type of the section item.
@exception NSException Thrown if generation fails.
@see generateObjectInfoSectionToData:
*/
- (void) generateObjectInfoSectionToData:(NSMutableData*) data 
							   fromNodes:(NSArray*) nodes 
								   index:(int*) index
									type:(int) type;

/** Generates the object overview data if necessary.

This is where the following messages are sent to the subclass:
- @c appendObjectOverviewToData:fromItem:()

@param data The @c NSMutableData to append to.
@exception NSException Thrown if generation fails.
@see generateOutputForObject
@see generateObjectInfoSectionToData:
@see generateTasksSectionToData:
@see generateObjectMembersSectionToData:
*/
- (void) generateObjectOverviewSectionToData:(NSMutableData*) data;

/** Generates the tasks section data if necessary.

This is where the following messages are sent to the subclass:
- @c appendObjectTasksHeaderToData:()
- @c appendObjectTaskHeaderToData:fromItem:index:()
- @c appendObjectTaskMemberToData:fromItem:index:()
- @c appendObjectTaskFooterToData:fromItem:index:()
- @c appendObjectTasksFooterToData:()

@param data The @c NSMutableData to append to.
@exception NSException Thrown if generation fails.
@see generateOutputForObject
@see generateObjectInfoSectionToData:
@see generateOverviewSectionToData:
@see generateObjectMembersSectionToData:
*/
- (void) generateObjectTasksSectionToData:(NSMutableData*) data;

/** Generates the main members documentation section if necessary.

This is where the following messages are sent to the subclass:
- @c appendObjectMembersHeaderToData:()
- @c appendObjectMembersFooterToData:()

@param data The @c NSMutableData to append to.
@exception NSException Thrown if generation fails.
@see generateOutputForObject
@see generateObjectInfoSectionToData:
@see generateOverviewSectionToData:
@see generateTasksSectionToData:
@see generateMemberSectionToData:fromItems:type:
*/
- (void) generateObjectMembersSectionToData:(NSMutableData*) data;

/** Generates the given main members documentation section.

This is sent from @c generateObjectMembersSectionToData:() for each group of members that
has at least one documented entry. This is where the following messages are sent to the 
subclass:
- @c appendIndexGroupHeaderToData:type:()
- @c appendIndexGroupItemToData:fromItem:index:type:()
- @c appendIndexGroupFooterToData:type:()

The @c type parameter can be one of the following:
- @c kTKIndexGroupClasses: This group will append all classes.
- @c kTKIndexGroupProtocols: This group will append all protocols.
- @c kTKIndexGroupCategories: This group will append all categories.
 
@param data The @c NSMutableData to append to.
@param nodes The array of @c NSXMLElement instances representing individual members.
@param type The type of the instances.
@exception NSException Thrown if generation fails.
@see generateObjectMembersSectionToData:
*/
- (void) generateObjectMemberSectionToData:(NSMutableData*) data 
								 fromNodes:(NSArray*) nodes 
									  type:(int) type;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Index generation helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates the index groups documentation sections.

This is sent from @c generateIndexGroupSectionsToData:(). It collects the group data
and then sends @c generateIndexGroupSectionToData:fromNodes:type:() for each detected
group.
 
@param data The @c NSMutableData to append to.
@exception NSException Thrown if generation fails.
@see generateOutputForIndex
@see generateIndexGroupSectionToData:fromNodes:type:
*/
- (void) generateIndexGroupSectionsToData:(NSMutableData*) data;

/** Generates the given main members documentation section.

This is sent from @c generateIndexGroupSectionsToData:() for each group that has at
least one member. This is where the following messages are sent to the subclass:
- @c appendIndexGroupHeaderToData:type:()
- @c appendIndexGroupItemToData:fromItem:index:type:()
- @c appendIndexGroupFooterToData:type:()

The @c type parameter can be one of the following:
- @c kTKObjectMemberTypeClass: The @c nodes describes class members.
- @c kTKObjectMemberTypeInstance: The @c nodes describes instance members.
- @c kTKObjectMemberTypeProperty: The @c nodes describes properties.
 
@param data The @c NSMutableData to append to.
@param nodes The array of @c NSXMLElement instances representing individual members.
@param type The type of the instances.
@exception NSException Thrown if generation fails.
@see generateObjectMembersSectionToData:
*/
- (void) generateIndexGroupSectionToData:(NSMutableData*) data 
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
- (id) init
{
	self = [super init];
	if (self != nil)
	{
		cmd = [CommandLineParser sharedInstance];
	}
	return self;
}

//----------------------------------------------------------------------------------------
- (void) dealloc
{
	self.projectName = nil;
	self.lastUpdated = nil;
	cmd = nil;
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) generateOutputForObject:(NSDictionary*) data
						  toFile:(NSString*) filename
{
	NSParameterAssert(data != nil);
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);

	// Generate the data.
	objectData = data;
	logVerbose(@"- Generating output for object '%@'...", self.objectName);
	NSData* result = [self outputDataForObject];
	objectData = nil;
	
	// Save the data.
	if (result && [result length] > 0)
	{
		logDebug(@"  - Saving object output to '%@'...", filename);
		if (![result writeToFile:filename atomically:NO])
		{
			NSString* message = [NSString stringWithFormat:@"Failed saving object output to '%@'!", filename];
			logError(@"Failed saving clean object output!");
			[Systemator throwExceptionWithName:kTKConverterException withDescription:message];
		}
		wasFileCreated = YES;
	}
}

//----------------------------------------------------------------------------------------
- (void) generateOutputForIndex:(NSDictionary*) data
							toFile:(NSString*) filename
{
	NSParameterAssert(data != nil);
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);

	// Generate the data.
	indexData = data;
	logVerbose(@"- Generating output for index...");
	NSData* result = [self outputDataForIndex];
	indexData = nil;
	
	// Save the data.
	if (result && [result length] > 0)
	{
		logDebug(@"  - Saving index output to '%@'...", filename);
		if (![result writeToFile:filename atomically:NO])
		{
			NSString* message = [NSString stringWithFormat:@"Failed saving index output to '%@'!", filename];
			logError(@"Failed saving clean index output!");
			[Systemator throwExceptionWithName:kTKConverterException withDescription:message];
		}
		wasFileCreated = YES;
	}
}

//----------------------------------------------------------------------------------------
- (void) generateOutputForHierarchy:(NSDictionary*) data
							 toFile:(NSString*) filename
{
	NSParameterAssert(data != nil);
	NSParameterAssert(filename != nil);
	NSParameterAssert([filename length] > 0);
	
	// Generate the data.
	hierarchyData = data;
	logVerbose(@"- Generating output for hierarchy...");
	NSData* result = [self outputDataForHierarchy];
	hierarchyData = nil;
	
	// Save the data.
	if (result && [result length] > 0)
	{
		logDebug(@"  - Saving hierarchy output to '%@'...", filename);
		if (![result writeToFile:filename atomically:NO])
		{
			NSString* message = [NSString stringWithFormat:@"Failed saving hierarchy output to '%@'!", filename];
			logError(@"Failed saving clean hierarchy output!");
			[Systemator throwExceptionWithName:kTKConverterException withDescription:message];
		}
		wasFileCreated = YES;
	}
}

//----------------------------------------------------------------------------------------
- (void) generationStarting
{
	wasFileCreated = NO;
}

//----------------------------------------------------------------------------------------
- (void) generationFinished
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Objects output generation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSData*) outputDataForObject
{
	NSMutableData* result = [NSMutableData data];	
	[self appendObjectHeaderToData:result];
	[self generateObjectInfoSectionToData:result];
	[self generateObjectOverviewSectionToData:result];
	[self generateObjectTasksSectionToData:result];
	[self generateObjectMembersSectionToData:result];
	[self appendObjectFooterToData:result];	
	return result;
}

//----------------------------------------------------------------------------------------
- (void) generateObjectInfoSectionToData:(NSMutableData*) data
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
		[self generateObjectInfoSectionToData:data fromNodes:baseNodes index:&index type:kTKObjectInfoItemInherits];
		[self generateObjectInfoSectionToData:data fromNodes:protocolNodes index:&index type:kTKObjectInfoItemConforms];
		[self generateObjectInfoSectionToData:data fromNodes:fileNodes index:&index type:kTKObjectInfoItemDeclared];
		[self appendObjectInfoFooterToData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateObjectInfoSectionToData:(NSMutableData*) data 
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
- (void) generateObjectOverviewSectionToData:(NSMutableData*) data
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
- (void) generateObjectTasksSectionToData:(NSMutableData*) data
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
- (void) generateObjectMembersSectionToData:(NSMutableData*) data
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
		[self generateObjectMemberSectionToData:data fromNodes:classMethodNodes type:kTKObjectMemberTypeClass];
		[self generateObjectMemberSectionToData:data fromNodes:instanceMethodNodes type:kTKObjectMemberTypeInstance];
		[self generateObjectMemberSectionToData:data fromNodes:propertyNodes type:kTKObjectMemberTypeProperty];
		
		// Ask the subclass to append members documentation footer.
		[self appendObjectMembersFooterToData:data];
	}
}

//----------------------------------------------------------------------------------------
- (void) generateObjectMemberSectionToData:(NSMutableData*) data 
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
#pragma mark Index output generation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSData*) outputDataForIndex
{
	NSMutableData* result = [NSMutableData data];	
	[self appendIndexHeaderToData:result];
	[self generateIndexGroupSectionsToData:result];
	[self appendIndexFooterToData:result];	
	return result;
}

//----------------------------------------------------------------------------------------
- (void) generateIndexGroupSectionsToData:(NSMutableData*) data
{
	NSArray* classNodes = [self.indexMarkup nodesForXPath:@"project/object[@kind='class']" error:nil];
	NSArray* categoryNodes = [self.indexMarkup nodesForXPath:@"project/object[@kind='category']" error:nil];
	NSArray* protocolNodes = [self.indexMarkup nodesForXPath:@"project/object[@kind='protocol']" error:nil];
	
	[self generateIndexGroupSectionToData:data 
								fromNodes:classNodes
									 type:kTKIndexGroupClasses];
	[self generateIndexGroupSectionToData:data 
								fromNodes:protocolNodes
									 type:kTKIndexGroupProtocols];
	[self generateIndexGroupSectionToData:data 
								fromNodes:categoryNodes
									 type:kTKIndexGroupCategories];
}

//----------------------------------------------------------------------------------------
- (void) generateIndexGroupSectionToData:(NSMutableData*) data 
							   fromNodes:(NSArray*) nodes 
									type:(int) type
{
	if ([nodes count] > 0)
	{
		[self appendIndexGroupHeaderToData:data type:type];
		for (int i = 0; i < [nodes count]; i++)
		{
			NSXMLElement* node = [nodes objectAtIndex:i];
			[self appendIndexGroupItemToData:data
									fromItem:node
									   index:i
										type:type];
		}
		[self appendIndexGroupFooterToData:data type:type];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Hierarchy output generation handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSData*) outputDataForHierarchy
{
	// Note that we could use the hierarchies data directly instead of relying on the
	// generated XML and it would probably be more optimized too. However using XML
	// ensures consistent parsing code with the rest of the generation methods and
	// perhaps even more important - it uses the same data that external utilities
	// might use if they are only interested in generating the XML from appledoc.
	NSMutableData* result = [NSMutableData data];	
	NSArray* rootNodes = [self.hierarchyMarkup nodesForXPath:@"project/object" error:nil];
	if ([rootNodes count] > 0)
	{
		[self appendHierarchyHeaderToData:result];
		[self appendHierarchyGroupHeaderToData:result];
		for (int i = 0; i < [rootNodes count]; i++)
		{
			NSXMLElement* rootNode = [rootNodes objectAtIndex:i];
			[self appendHierarchyGroupItemToData:result 
										fromItem:rootNode 
										   index:i];
		}
		[self appendHierarchyGroupFooterToData:result];
		[self appendHierarchyFooterToData:result];	
	}
	
	return result;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

@synthesize projectName;
@synthesize lastUpdated;
@synthesize wasFileCreated;

@end
