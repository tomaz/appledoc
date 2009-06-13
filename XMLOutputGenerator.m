//
//  XMLOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLOutputGenerator.h"
#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"

@implementation XMLOutputGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark OutputInfoProvider protocol implementation
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) outputFilesExtension
{
	return @".xml";
}

//----------------------------------------------------------------------------------------
- (NSString*) outputBasePath
{
	return [cmd.outputPath stringByAppendingPathComponent:@"cxml"];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) generateSpecificOutput
{
	if (!self.doxygenInfoProvider)
		[Systemator throwExceptionWithName:kTKConverterException
						   withDescription:@"doxygenInfoProvider not set"];
	
	[self createCleanObjectDocumentationMarkup];
	[self mergeCleanCategoriesToKnownObjects];
	[self updateCleanObjectsDatabase];
	[self createCleanIndexDocumentationFile];
	[self createCleanHierarchyDocumentationFile];
	[self fixCleanObjectDocumentation];
	[self saveCleanObjectDocumentationFiles];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Clean XML handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) createCleanObjectDocumentationMarkup
{
	logNormal(@"Creating clean object XML files...");
	NSAutoreleasePool* loopAutoreleasePool = nil;
	NSError* error = nil;
	
	// First get the list of all files (and directories) at the doxygen output path. Note
	// that we only handle certain files, based on their names.
	NSString* searchPath = [self.doxygenInfoProvider outputBasePath];
	NSArray* files = [manager contentsOfDirectoryAtPath:searchPath error:&error];
	if (!files)
	{
		logError(@"Failed enumerating files at '%@'!", searchPath);
		[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
	}
	
	for (NSString* filename in files)
	{
		// Setup the autorelease pool for this iteration. Note that we are releasing the
		// previous iteration pool here as well. This is because we use continue to 
		// skip certain iterations, so releasing at the end of the loop would not work...
		// Also note that after the loop ends, we are releasing the last iteration loop.
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		// (1) First check if the file is .xml and starts with correct name.
		BOOL parse = [filename hasSuffix:@".xml"];
		parse &= [filename hasPrefix:@"class_"] ||
				 [filename hasPrefix:@"interface_"] ||
				 [filename hasPrefix:@"protocol_"];
		if (!parse)
		{
			logDebug(@"- Skipping '%@' because it doesn't describe known object.", filename);
			continue;
		}
		
		// (2) Parse the XML and check if the file is documented or not. Basically
		// we check if at least one brief or detailed description contains a
		// para tag. If so, the document is considered documented... If parsing
		// fails, log and skip the file.
		NSString* inputFilename = [searchPath stringByAppendingPathComponent:filename];
		NSURL* originalURL = [NSURL fileURLWithPath:inputFilename];
		NSXMLDocument* originalDocument = [[[NSXMLDocument alloc] initWithContentsOfURL:originalURL
																				options:0
																				  error:&error] autorelease];
		if (!originalDocument)
		{
			logError(@"Skipping '%@' because parsing failed with error %@!", 
					 filename, 
					 [error localizedDescription]);
			continue;
		}
		
		// (3) If at least one item is documented, run the document through the
		// xslt converter to get clean XML. Then use the clean XML to get
		// further object information and finally add the object to the data
		// dictionary.
		if ([[originalDocument nodesForXPath:@"//briefdescription/para" error:NULL] count] == 0 &&
			[[originalDocument nodesForXPath:@"//detaileddescription/para" error:NULL] count] == 0)
		{
			logVerbose(@"- Skipping '%@' because it contains non-documented object...", filename);
			continue;
		}

		// (4) Prepare file names and run the xslt converter. Catch any exception
		// and log it, then continue with the next file.
		@try
		{
			// (A) Run the xslt converter.
			NSString* stylesheetFile = [cmd.templatesPath stringByAppendingPathComponent:@"object.xslt"];
			NSXMLDocument* cleanDocument = [Systemator applyXSLTFromFile:stylesheetFile 
															  toDocument:originalDocument
																   error:&error];
			if (!cleanDocument)
			{
				logError(@"Skipping '%@' because creating clean XML failed with error %@!", 
						 filename, 
						 [error localizedDescription]);
				continue;
			}

			// (B) If object node is not present, exit. This means the convertion failed...
			NSArray* objectNodes = [cleanDocument nodesForXPath:@"/object" error:NULL];
			if ([objectNodes count] == 0)
			{
				logError(@"Skipping '%@' because object node not found!", filename);
				continue;
			}
			
			// (C) Get object name node. If not found, exit.
			NSXMLElement* objectNode = [objectNodes objectAtIndex:0];
			NSArray* objectNameNodes = [objectNode nodesForXPath:@"name" error:NULL];
			if ([objectNameNodes count] == 0)
			{
				logError(@"Skipping '%@' because object name node not found!", filename);
				continue;
			}
			
			// (D) Now we have all information, get the data and add the object to the list.
			NSXMLElement* objectNameNode = [objectNameNodes objectAtIndex:0];
			NSString* objectName = [objectNameNode stringValue];
			NSString* objectKind = [[objectNode attributeForName:@"kind"] stringValue];
			if ([objectName length] == 0 || [objectKind length] == 0)
			{
				logError(@"Skipping '%@' because data cannot be collected (name %@, kind %@)!",
						 filename,
						 objectName,
						 objectKind);
				continue;
			}
			
			// (D.1) Prepare the object's parent.
			NSString* objectParent = nil;
			NSArray* baseNodes = [objectNode nodesForXPath:@"base" error:nil];
			if ([baseNodes count] > 0) objectParent = [[baseNodes objectAtIndex:0] stringValue];
			
			// (E) Prepare the object relative directory and relative path to the index.
			// Also set the class "link" for categories.
			NSString* objectClass = nil;
			NSString* objectRelativeDirectory = nil;
			if ([objectKind isEqualToString:@"category"])
			{
				objectRelativeDirectory = kTKDirCategories;
				NSRange categoryNameRange = [objectName rangeOfString:@"("];
				if (categoryNameRange.location != NSNotFound)
				{
					objectClass = [objectName substringToIndex:categoryNameRange.location];
				}
			}
			else if ([objectKind isEqualToString:@"protocol"])
			{
				objectRelativeDirectory = kTKDirProtocols;
			}
			else
			{
				objectRelativeDirectory = kTKDirClasses;
			}
			
			NSString* objectRelativePath = [objectRelativeDirectory stringByAppendingPathComponent:objectName];
			objectRelativePath = [objectRelativePath stringByAppendingString:kTKPlaceholderExtension];
			
			// (F) OK, now really add the node to the database... ;) First create the
			// object's description dictionary. Then add the object to the Objects
			// dictionary. Then check if the object's relative directory key already
			// exists in the directories dictionary. If not, create it, then add the
			// object to the end of the list.
			NSMutableDictionary* objectData = [[NSMutableDictionary alloc] init];
			[objectData setObject:objectName forKey:kTKDataObjectNameKey];
			[objectData setObject:objectKind forKey:kTKDataObjectKindKey];
			[objectData setObject:cleanDocument forKey:kTKDataObjectMarkupKey];
			[objectData setObject:objectRelativeDirectory forKey:kTKDataObjectRelDirectoryKey];
			[objectData setObject:objectRelativePath forKey:kTKDataObjectRelPathKey];
			[objectData setObject:inputFilename forKey:kTKDataObjectDoxygenFilenameKey];
			if (objectParent) [objectData setObject:objectParent forKey:kTKDataObjectParentKey];
			if (objectClass) [objectData setObject:objectClass forKey:kTKDataObjectClassKey];
			
			// Add the object to the object's dictionary.
			NSMutableDictionary* objectsDict = [database objectForKey:kTKDataMainObjectsKey];
			[objectsDict setObject:objectData forKey:objectName];
			
			// Add the object to the directories list.
			NSMutableDictionary* directoriesDict = [database objectForKey:kTKDataMainDirectoriesKey];
			NSMutableArray* directoryArray = [directoriesDict objectForKey:objectRelativeDirectory];
			if (directoryArray == nil)
			{
				directoryArray = [NSMutableArray array];
				[directoriesDict setObject:directoryArray forKey:objectRelativeDirectory];
			}
			[directoryArray addObject:objectData];
			
			// Log the object.
			logVerbose(@"- Found '%@' of type '%@' in file '%@'...", 
					   objectName, 
					   objectKind,
					   filename);
		}
		@catch (NSException* e)
		{
			logError(@"Skipping '%@' because converting to clean documentation failed with error %@!", 
					 filename, 
					 [e reason]);
			continue;
		}
	}
	
	// Release the last iteration pool.
	[loopAutoreleasePool drain];	
	logInfo(@"Finished creating clean object documentation files.");
}

//----------------------------------------------------------------------------------------
- (void) mergeCleanCategoriesToKnownObjects
{
	if (cmd.mergeKnownCategoriesToClasses)
	{
		logNormal(@"Merging categories documentation to known classes...");
		
		// Go through all categories and check if they belong to a known class. If so
		// merge the documentation as a new section at the end of the class documentation.
		// Then remember the category name so we can later remove it from the database. 
		NSMutableArray* removedCategories = [NSMutableArray array];
		NSMutableDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
		NSDictionary* directoriesDict = [database objectForKey:kTKDataMainDirectoriesKey];
		NSMutableArray* categoriesArray = [directoriesDict objectForKey:kTKDirCategories];
		for (NSDictionary* categoryData in categoriesArray)
		{
			NSString* categoryName = [categoryData objectForKey:kTKDataObjectNameKey];
			NSString* className = [categoryData objectForKey:kTKDataObjectClassKey];
			if (!className)
			{
				logVerbose(@"- Skipping '%@' because it belongs to unknown class.", categoryName);
				continue;
			}
			
			logVerbose(@"- Merging category '%@' documentation to class '%@'...",
					   categoryName,
					   className);
			
			// Get the main class XML.
			NSDictionary* classData = [objects objectForKey:className];
			NSXMLDocument* classDocument = [classData objectForKey:kTKDataObjectMarkupKey];
			
			// Get the main class <sections> container element. If not found, exit.
			// (this should not really happen, since the xslt adds "Others" node by
			// default, but let's keep it safe). If there's more than one sections node,
			// use the first one (also should not happen).
			NSXMLElement* classSectionsNode = nil;
			NSArray* classSectionsNodes = [classDocument nodesForXPath:@"/object/sections" error:nil];
			if ([classSectionsNodes count] == 0) 
			{
				logInfo(@"Skipping '%@' because class doesn't contain sections node!", categoryName);
				continue;					
			}
			classSectionsNode = (NSXMLElement*)[classSectionsNodes objectAtIndex:0];

			// Get the category clean document markup. Next step depends on the category
			// merging optios. If sections need to be preserved, we should copy all
			// sections. Otherwise we should create one section for each category which
			// includes members from all sections.
			NSXMLDocument* categoryDocument = [categoryData objectForKey:kTKDataObjectMarkupKey];
			if (cmd.keepMergedCategorySections)
			{
				// Get the array of all category sections and append them in the same
				// order to the main class. The new section name should have the category
				// name prepended.
				NSArray* categorySectionNodes = [categoryDocument nodesForXPath:@"/object/sections/section" error:nil];
				for (NSXMLElement* categorySectionNode in categorySectionNodes)
				{
					// Get category section name. Use empty string by default just in case...
					NSString* categorySectionName = @"";
					NSArray* categorySectionNameNodes = [categorySectionNode nodesForXPath:@"name" error:nil];
					if ([categorySectionNameNodes count] > 0)
					{
						NSXMLNode* nameNode = [categorySectionNameNodes objectAtIndex:0];
						categorySectionName = [nameNode stringValue];
					}
					
					// Merge the section data to the main class document. We need to prepend
					// the category name before the section description before... Note that
					// we handle the cases where no category name is defined by simply using
					// the category section name.
					logDebug(@"  - Merging documentation for section '%@'...");
					NSXMLElement* classSectionNode = [categorySectionNode copy];
					NSArray* classSectionNameNodes = [classSectionNode nodesForXPath:@"name" error:nil];
					if ([classSectionNameNodes count] > 0)
					{					
						NSString* extensionName = [categoryName substringFromIndex:[className length]];
						extensionName = [extensionName substringWithRange:NSMakeRange(1, [extensionName length]-2)];
						NSString* classSectionName = categorySectionName;
						if ([extensionName length] > 0)
							classSectionName = [NSString stringWithFormat:@"%@ / %@", 
												extensionName,
												categorySectionName];
						NSXMLNode* nameNode = [classSectionNameNodes objectAtIndex:0];
						[nameNode setStringValue:classSectionName];
					}
					[classSectionsNode addChild:classSectionNode];
				}
			}
			else
			{
				logDebug(@"  - Merging all sections to '%@'...", categoryName);
				
				// Create the class section element.
				NSXMLElement* sectionNode = [NSXMLNode elementWithName:@"section"];
				NSXMLElement* sectionNameNode = [NSXMLNode elementWithName:@"name" stringValue:categoryName];
				[sectionNode addChild:sectionNameNode];
				
				// Get all member documentation for all sections and add each one to the
				// class section element.
				NSArray* memberNodes = [categoryDocument nodesForXPath:@"/object/sections/section/member" error:nil];
				for (NSXMLElement* memberNode in memberNodes)
				{
					NSXMLElement* classMemberNode = [memberNode copy];
					[sectionNode addChild:classMemberNode];
				}
				
				// Append the section data to the main class document.
				[classSectionsNode addChild:sectionNode];
			}
			
			// After the category was added, add it's <file> tag to the end of the 
			// last one. This will be used in actual output generation to show all
			// source files from which documentation was extracted. Note that we skip
			// all files which were already added.
			NSArray* categoryFileNodes = [categoryDocument nodesForXPath:@"object/file" error:nil];
			if ([categoryFileNodes count] > 0)
			{
				NSArray* classFileNodes = [classDocument nodesForXPath:@"object/file" error:nil];
				if ([classFileNodes count] > 0)
				{
					NSXMLElement* lastClassFileNode = [classFileNodes lastObject];
					NSXMLElement* parentNode = (NSXMLElement*)[lastClassFileNode parent];
					NSUInteger index = [lastClassFileNode index];
					for (NSXMLElement* categoryFileNode in categoryFileNodes)
					{
						NSString* testQuery = [NSString stringWithFormat:@"object/file[%@]", 
											   [categoryFileNode stringValue]];
						if ([[classDocument nodesForXPath:testQuery error:nil] count] == 0)
						{
							logDebug(@"  - Inserting file '%@' from category to index %d...",
									 [categoryFileNode stringValue],
									 index);						
							NSXMLElement* insertedNode = [categoryFileNode copy];
							[parentNode insertChild:insertedNode atIndex:index + 1];
							index++;
						}
					}
				}
			}
			
			// Remember the category name which was removed. Note that we use category
			// data because we can get all information from there and we need the
			// instance to properly remove from the directories array.
			[removedCategories addObject:categoryData];
		}
		
		
		// Remove all category "stand alone" documentation from the database. We'll
		// lose the category description this way, but this usually doesn't provide
		// much information (at least not in my documentation... ;-)).
		for (NSDictionary* categoryData in removedCategories)
		{
			NSString* categoryName = [categoryData objectForKey:kTKDataObjectNameKey];
			logDebug(@"  - Removing category '%@' documentation...", categoryName);
			[categoriesArray removeObject:categoryData];
			[objects removeObjectForKey:categoryName];
		}
				
		logInfo(@"Finished merging categories documentation to known classes...");
	}
}

//----------------------------------------------------------------------------------------
- (void) updateCleanObjectsDatabase
{
	logNormal(@"Updating clean objects database...");
	
	// Prepare common variables to optimize loop a bit.
	NSAutoreleasePool* loopAutoreleasePool = nil;
	
	// Handle all files in the database.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		// Setup the autorelease pool for this iteration. Note that we are releasing the
		// previous iteration pool here as well. This is because we use continue to 
		// skip certain iterations, so releasing at the end of the loop would not work...
		// Also note that after the loop ends, we are releasing the last iteration loop.
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		// Get the required object data.
		NSMutableDictionary* objectData = [objects objectForKey:objectName];
		logVerbose(@"- Handling '%@'...", objectName);
		
		[self createMembersDataForObject:objectName objectData:objectData];
	}
	
	// Release last iteration pool.
	[loopAutoreleasePool drain];
	logInfo(@"Finished updating clean objects database.");
}

//----------------------------------------------------------------------------------------
- (void) createCleanIndexDocumentationFile
{
	logNormal(@"Creating clean index documentation file...");	
	NSAutoreleasePool* loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
	
	// Create the default markup.
	NSXMLDocument* document = [[NSXMLDocument alloc] init];
	NSXMLElement* projectElement = [NSXMLElement elementWithName:@"project"];
	[document setVersion:@"1.0"];
	[document addChild:projectElement];
	
	// Enumerate through all the enumerated objects and create the markup. Note that
	// we use directory structure so that we get proper enumeration.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	NSArray* sortedObjectNames = [[objects allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for (NSString* objectName in sortedObjectNames)
	{
		logVerbose(@"- Handling '%@'...", objectName);
		
		NSDictionary* objectData = [objects valueForKey:objectName];
		NSString* objectKind = [objectData valueForKey:kTKDataObjectKindKey];
		NSString* objectRef = [objectData valueForKey:kTKDataObjectRelPathKey];
		
		// Create the object element and the kind and id attributes.
		NSXMLElement* objectElement = [NSXMLElement elementWithName:@"object"];
		NSXMLNode* kindAttribute = [NSXMLNode attributeWithName:@"kind" stringValue:objectKind];
		NSXMLNode* idAttribute = [NSXMLNode attributeWithName:@"id" stringValue:objectRef];
		[objectElement addAttribute:kindAttribute];
		[objectElement addAttribute:idAttribute];
		[projectElement addChild:objectElement];
		
		// Create the name element.
		NSXMLElement* nameElement = [NSXMLElement elementWithName:@"name"];
		[nameElement setStringValue:objectName];
		[objectElement addChild:nameElement];
	}
	
	// Store the cleaned markup to the application data.
	[database setObject:document forKey:kTKDataMainIndexKey];
	
	// Save the markup.
	NSError* error = nil;
	NSData* markupData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSString* filename = [self outputBasePath];
	filename = [filename stringByAppendingPathComponent:[self outputIndexFilename]];
	if (![markupData writeToFile:filename options:0 error:&error])
	{
		logError(@"Failed writting clean Index.xml to '%@'!", filename);
		[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
	}
	
	[loopAutoreleasePool drain];
	logInfo(@"Finished creating clean index documentation file.");
}

//----------------------------------------------------------------------------------------
- (void) createCleanHierarchyDocumentationFile
{
	logNormal(@"Creating clean hierarchy documentation file...");
	
	// Prepare common variables.
	NSAutoreleasePool* loopAutoreleasePool = nil;
	
	// Go through all the objects in the database and prepare the hierarchy. Note that
	// this is done in two steps. In the first step the objects are stored in the
	// hierarchy in proper structure, except that the root level contains ALL of the
	// objects. However all objects which place is not in the root will have their
	// temporary flag set. These will be removed in the second pass. This way allows
	// us to simplify hieararchy generation - when adding a new object, get it's parent
	// and check if the parent already exists in the root. If not, add the parent, add
	// the object to it's children and then also add the object to the root but marked
	// with temporary...
	NSMutableDictionary* hierarchies = [database objectForKey:kTKDataMainHierarchiesKey];
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		// Release all autoreleased objects from the previous iteration.
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		// Get the object data from the objects database. If parent data exists, add the
		// object to the hierarchy. Note that this adds both, the parent and the object
		// to the root.
		NSMutableDictionary* objectData = [objects objectForKey:objectName];
		NSString* parentName = [objectData objectForKey:kTKDataObjectParentKey];
		if (parentName)
		{
			logDebug(@"  - Handling '%@' as child of '%@'...", objectName, parentName);
			
			// Check the hierarchy database to see if object has already been added - this
			// can happen in the code below if the object is found as a parent of another
			// object. In such case we need to add object's data to the existing entry,
			// otherwise we need to create the data.
			NSMutableDictionary* objectHierarchyData = [hierarchies objectForKey:objectName];
			if (!objectHierarchyData)
			{
				objectHierarchyData = [NSMutableDictionary dictionary];
				[objectHierarchyData setObject:objectName forKey:kTKDataHierarchyObjectNameKey];
				[objectHierarchyData setObject:[NSMutableDictionary dictionary] forKey:kTKDataHierarchyChildrenKey];
				[hierarchies setObject:objectHierarchyData forKey:objectName];
			}
			
			// Add the pointer to the object's data dictionary and set it's temporary
			// key so that it will be removed later on - this object has a parent, so
			// it's place is not in the root.
			[objectHierarchyData setObject:objectData forKey:kTKDataHierarchyObjectDataKey];
			[objectHierarchyData setObject:[NSNumber numberWithBool:YES] forKey:kTKDataHierarchyTempKey];
			
			// Check the hierarchy database to see if parent was already handled - if
			// we find it in the root, add the object to it's children. Otherwise create
			// the data for it now (note that at this point we don't prepare full data,
			// this will be handled in above code when (if) parent object is found in
			// documented data).
			NSMutableDictionary* parentHierarchyData = [hierarchies objectForKey:parentName];
			if (!parentHierarchyData)
			{
				parentHierarchyData = [NSMutableDictionary dictionary];
				[parentHierarchyData setObject:parentName forKey:kTKDataHierarchyObjectNameKey];
				[parentHierarchyData setObject:[NSMutableDictionary dictionary] forKey:kTKDataHierarchyChildrenKey];
				[hierarchies setObject:parentHierarchyData forKey:parentName];
			}
			
			// Add the object to it's parent children. Note that we don't set parent's
			// temporary key - if the parent is still unknown, it may be the root object,
			// however if we find it as a child of another object later on, we'll set it's
			// temporary key at that point (see above).
			NSMutableDictionary* parentChildren = [parentHierarchyData objectForKey:kTKDataHierarchyChildrenKey];
			[parentChildren setObject:objectHierarchyData forKey:objectName];
		}
	}	
	
	// Create the default markup. Then handle all root level objects. This in turn will
	// handle their children and these their and so on in the recursive method. Note that
	// all root level nodes with temporary flag set, should not be handled. These will
	// eventually be removed from the database root level, at the end of the clean XML
	// generation. However for the moment they are left here, so that code generation
	// is simpler - to find an object and it's hierarchy, simply search for it in the
	// root...
	NSXMLDocument* document = [[NSXMLDocument alloc] init];
	NSXMLElement* projectElement = [NSXMLElement elementWithName:@"project"];
	[document setVersion:@"1.0"];
	[document addChild:projectElement];
	NSArray* sortedObjects = [[hierarchies allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for (NSString* objectName in sortedObjects)
	{
		NSDictionary* objectData = [hierarchies objectForKey:objectName];
		NSNumber* temporaryFlag = [objectData objectForKey:kTKDataHierarchyTempKey];
		if (!temporaryFlag || ![temporaryFlag boolValue])
		{
			[self createHierarchyDataForObject:objectData withinNode:projectElement];
		}
	}
	
	// Store the cleaned markup to the application data.
	[database setObject:document forKey:kTKDataMainHierarchyKey];
	
	// Save the markup.
	NSError* error = nil;
	NSData* markupData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSString* filename = [self outputBasePath];
	filename = [filename stringByAppendingPathComponent:[self outputHierarchyFilename]];
	if (![markupData writeToFile:filename options:0 error:&error])
	{
		logError(@"Failed writting clean Hierarchy.xml to '%@'!", filename);
		[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
	}
	
	[loopAutoreleasePool drain];
	logInfo(@"Finished creating clean hierarchy documentation file.");
}

//----------------------------------------------------------------------------------------
- (void) fixCleanObjectDocumentation
{
	logNormal(@"Fixing clean objects documentation links...");
	
	// Prepare common variables to optimize loop a bit.
	NSAutoreleasePool* loopAutoreleasePool = nil;
	
	// Handle all files in the database.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		// Setup the autorelease pool for this iteration. Note that we are releasing the
		// previous iteration pool here as well. This is because we use continue to 
		// skip certain iterations, so releasing at the end of the loop would not work...
		// Also note that after the loop ends, we are releasing the last iteration loop.
		[loopAutoreleasePool drain];
		loopAutoreleasePool = [[NSAutoreleasePool alloc] init];
		
		// Get the required object data.
		NSMutableDictionary* objectData = [objects objectForKey:objectName];
		logVerbose(@"- Handling '%@'...", objectName);
		
		[self fixInheritanceForObject:objectName objectData:objectData objects:objects];
		[self fixLocationForObject:objectName objectData:objectData objects:objects];
		[self fixReferencesForObject:objectName objectData:objectData objects:objects];
		[self fixParaLinksForObject:objectName objectData:objectData objects:objects];
		[self fixEmptyParaForObject:objectName objectData:objectData objects:objects];
	}
	
	// When all fixes are applied, we can remove temporary objects from the hierarchies
	// root level. The outside code relies on the fact that the hierarchies is "clean"
	// and only contains objects on the places where they belong.
	NSMutableDictionary* hierarchies = [database objectForKey:kTKDataMainHierarchiesKey];
	for (int i = 0; i < [hierarchies count]; i++)
	{
		NSString* objectName = [[hierarchies allKeys] objectAtIndex:i];
		NSDictionary* data = [hierarchies objectForKey:objectName];
		NSNumber* temporary = [data objectForKey:kTKDataHierarchyTempKey];
		if (temporary && [temporary boolValue])
		{
			logDebug(@"  - Removing temporary object '%@' from root...", objectName);
			[hierarchies removeObjectForKey:objectName];
			i--;
		}
	}
	
	// Release last iteration pool.
	[loopAutoreleasePool drain];
	logInfo(@"Finished fixing clean objects documentation links.");
}

//----------------------------------------------------------------------------------------
- (void) saveCleanObjectDocumentationFiles
{
	logNormal(@"Saving clean object documentation files...");
	
	// Save all objects.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		NSAutoreleasePool* loopAutoreleasePool = [[NSAutoreleasePool alloc] init];		
		NSDictionary* objectData = [objects objectForKey:objectName];
		
		// Prepare the file name.
		NSString* filename = [self outputBasePath];
		filename = [filename stringByAppendingPathComponent:[self outputObjectFilenameForObject:objectData]];
		
		// Save the document.
		logVerbose(@"- Saving '%@' to '%@'...", objectName, filename);
		NSXMLDocument* document = [objectData objectForKey:kTKDataObjectMarkupKey];
		NSData* documentData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
		if (![documentData writeToFile:filename atomically:NO])
		{
			logError(@"Failed saving '%@' to '%@'!", objectName, filename);
		}
		
		[loopAutoreleasePool drain];
	}
	
	logInfo(@"Finished saving clean object documentation files...");
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Clean XML "makeup" handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) createMembersDataForObject:(NSString*) objectName
						 objectData:(NSMutableDictionary*) objectData
{
	// Add the empty dictionary to the object data.
	NSMutableDictionary* members = [NSMutableDictionary dictionary];
	[objectData setObject:members forKey:kTKDataObjectMembersKey];
	
	// Get the array of all member nodes.
	NSXMLDocument* document = [objectData objectForKey:kTKDataObjectMarkupKey];
	NSArray* memberNodes = [document nodesForXPath:@"object/sections/section/member" error:nil];
	for (NSXMLElement* memberNode in memberNodes)
	{
		NSXMLNode* kindAttr = [memberNode attributeForName:@"kind"];
		if (kindAttr)
		{
			NSArray* nameNodes = [memberNode nodesForXPath:@"name" error:nil];
			if ([nameNodes count] > 0)
			{
				// Get member data.
				NSString* memberName = [[nameNodes objectAtIndex:0] stringValue];
				NSString* memberKind = [kindAttr stringValue];
				
				// Prepare member prefix.
				NSString* memberPrefix = @"";
				if ([memberKind isEqualToString:@"class-method"])
					memberPrefix = @"+";
				else if ([memberKind isEqualToString:@"instance-method"])
					memberPrefix = @"-";
				
				// Prepare member selector. Note that we use the template to allow the
				// users specify their desired format. If prefix is used, we should use
				// the template, otherwise we stick to the name only. This avoids the
				// empty spaces in front of properties for example.
				NSString* memberSelector = nil;
				if ([memberPrefix length] > 0)
				{
					memberSelector = cmd.memberReferenceTemplate;
					memberSelector = [memberSelector stringByReplacingOccurrencesOfString:@"$PREFIX" withString:memberPrefix];
					memberSelector = [memberSelector stringByReplacingOccurrencesOfString:@"$MEMBER" withString:memberName];
				}
				else
				{
					memberSelector = memberName;
				}
				logDebug(@"  - Generating '%@' member data...", memberSelector);
				
				// Create member data dictionary.
				NSMutableDictionary* memberData = [NSMutableDictionary dictionary];
				[memberData setObject:memberName forKey:kTKDataMemberNameKey];
				[memberData setObject:memberPrefix forKey:kTKDataMemberPrefixKey];
				[memberData setObject:memberSelector forKey:kTKDataMemberSelectorKey];
				
				// Add the dictionary to the members data.
				[members setObject:memberData forKey:memberName];
				
				// Add the member selector to the XML.
				NSXMLElement* selectorNode = [NSXMLNode elementWithName:@"selector" stringValue:memberSelector];
				[memberNode addChild:selectorNode];
			}
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) createHierarchyDataForObject:(NSDictionary*) objectHierarchyData
						   withinNode:(NSXMLElement*) node
{
	// Get the object data.
	NSDictionary* objectData = [objectHierarchyData objectForKey:kTKDataHierarchyObjectDataKey];
	NSDictionary* children = [objectHierarchyData objectForKey:kTKDataHierarchyChildrenKey];	
	NSString* objectName = [objectHierarchyData objectForKey:kTKDataHierarchyObjectNameKey];
	NSString* objectKind = [objectData objectForKey:kTKDataObjectKindKey];
	NSString* objectRef = [objectData valueForKey:kTKDataObjectRelPathKey];
	if (!objectKind) objectKind = @"class";
	logVerbose(@"- Handling '%@'...", objectName);
	
	// Create the node that will represent the object itself.
	NSXMLElement* objectNode = [NSXMLNode elementWithName:@"object"];
	[objectNode addAttribute:[NSXMLNode attributeWithName:@"kind" stringValue:objectKind]];
	if (objectRef) [objectNode addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:objectRef]];
	[node addChild:objectNode];
	
	// Create the name subnode.
	NSXMLElement* nameNode = [NSXMLNode elementWithName:@"name" stringValue:objectName];
	[objectNode addChild:nameNode];
	
	// If there are any children, process them. First create the children node, then
	// add all children to it.
	if ([children count] > 0)
	{
		NSXMLElement* childrenNode = [NSXMLNode elementWithName:@"children"];
		[objectNode addChild:childrenNode];
		
		NSArray* sortedChildrenNames = [[children allKeys] sortedArrayUsingSelector:@selector(compare:)];
		for (NSString* childName in sortedChildrenNames)
		{
			NSDictionary* childData = [children objectForKey:childName];
			[self createHierarchyDataForObject:childData 
									withinNode:childrenNode];
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) fixInheritanceForObject:(NSString*) objectName
					  objectData:(NSMutableDictionary*) objectData
						 objects:(NSDictionary*) objects
{
	NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
	
	// Fix the base class link. If the base class is one of the known objects,
	// add the id attribute so we can link to it when creating xhtml. Note that
	// we need to handle protocols here too - if a class conforms to protocols,
	// we should change the name of the node from <base> to <conforms> so that we
	// have easier job while generating html. We should also create the link to
	// the known protocols.
	NSXMLDocument* cleanDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
	NSArray* baseNodes = [cleanDocument nodesForXPath:@"/object/base" error:nil];
	for (NSXMLElement* baseNode in baseNodes)
	{
		NSString* refValue = [baseNode stringValue];
		if ([objects objectForKey:refValue])
		{
			NSString* linkReference = [self objectReferenceFromObject:objectName toObject:refValue];
			NSXMLNode* idAttribute = [NSXMLNode attributeWithName:@"id" stringValue:linkReference];
			[baseNode addAttribute:idAttribute];
			logDebug(@"  - Found base class reference to '%@' at '%@'.", refValue, linkReference);
		}
		else
		{
			refValue = [refValue stringByTrimmingCharactersInSet:whitespaceSet];
			if ([refValue hasPrefix:@"<"] && [refValue hasSuffix:@">"])
			{					
				NSRange protocolNameRange = NSMakeRange(1, [refValue length] - 2);
				refValue = [refValue substringWithRange:protocolNameRange];
				refValue = [refValue stringByTrimmingCharactersInSet:whitespaceSet];
				
				NSXMLElement* protocolNode = [NSXMLNode elementWithName:@"protocol"];
				[protocolNode setStringValue:refValue];
				
				if ([objects objectForKey:refValue])
				{
					NSString* linkReference = [self objectReferenceFromObject:objectName toObject:refValue];
					NSXMLNode* idAttribute = [NSXMLNode attributeWithName:@"id" stringValue:linkReference];
					[protocolNode addAttribute:idAttribute];
					logDebug(@"  - Found protocol reference to '%@' at '%@'.", refValue, linkReference);
				}
				else
				{
					logDebug(@"  - Found protocol reference to '%@'.", refValue);
				}
				
				NSUInteger index = [baseNode index];
				NSXMLElement* parentNode = (NSXMLElement*)[baseNode parent];
				[parentNode replaceChildAtIndex:index withNode:protocolNode];
			}
		}
	}
	
	// Now prepare the object full hierarchy. This will add additional <base> nodes after
	// the main one for classes which have "deep" inheritance. All known bases will also
	// be documented. Note that we only handle objects that are contained in the hierarchy.
	// Also note that we need to fetch base nodes again (we should only have one now, 
	// however we play safe and start adding after the last one).
	NSString* parentName = [objectData objectForKey:kTKDataObjectParentKey];
	if (parentName)
	{
		// We need the object node in case there's non base node - then we should just
		// add additional base nodes directly to the object node.
		NSArray* objectNodes = [cleanDocument nodesForXPath:@"object" error:nil];
		NSXMLElement* objectNode = [objectNodes lastObject];
		
		// Prepare default insertion index. If object node contains less than 4 subnodes
		// (name, file, base), we should insert to the end, otherwise we should insert
		// after the third (after the base node). However, if the node contains base
		// subnodes, we will properly setup the insertion index after the last one.
		NSUInteger insertionIndex = ([objectNode childCount] < 4) ? [objectNode childCount] - 1 : 3;
		NSArray* baseNodes = [objectNode nodesForXPath:@"base" error:nil];
		if ([baseNodes count] > 0)
		{
			insertionIndex = [[baseNodes lastObject] index] + 1;
		}

		// Note that this loop will skip the immediate object's parent since this one is
		// already documented. However to avoid code repetition, this is not handled
		// outside, and therefore requires a conditional within the loop.
		int parentLevel = 0;
		while (parentName)
		{
			// Only handle second level inheritance...
			NSDictionary* parentData = [objects objectForKey:parentName];
			if (parentLevel > 0)
			{
				NSXMLElement* baseNode = [NSXMLNode elementWithName:@"base" stringValue:parentName];
				if (parentData)
				{
					NSString* linkReference = [self objectReferenceFromObject:objectName toObject:parentName];
					NSXMLNode* idAttribute = [NSXMLNode attributeWithName:@"id" stringValue:linkReference];
					[baseNode addAttribute:idAttribute];
				}
				[objectNode insertChild:baseNode atIndex:insertionIndex];
				insertionIndex++;
			}
			
			// Continue with the next parent.
			parentName = [parentData objectForKey:kTKDataObjectParentKey];
			parentLevel++;
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) fixLocationForObject:(NSString*) objectName
				   objectData:(NSMutableDictionary*) objectData
					  objects:(NSDictionary*) objects
{
	// We only need to check this for classes and only if this is enabled.
	if (cmd.fixClassLocations && [[objectData objectForKey:kTKDataObjectKindKey] isEqualToString:@"class"])
	{
		NSXMLDocument* cleanDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
		NSArray* fileNodes = [cleanDocument nodesForXPath:@"object/file" error:nil];
		if ([fileNodes count] > 0)
		{
			for (NSXMLElement* fileNode in fileNodes)
			{
				// If path extension is not .h, check further.
				NSString* path = [fileNode stringValue];
				NSString* extension = [path pathExtension];
				if ([extension isEqualToString:@"m"] ||
					[extension isEqualToString:@"mm"])
				{
					// If the path contains other parts, besides extension and file name,
					// or it doesn't start with the object name, replace it...
					if (![path hasPrefix:objectName] ||
						[path length] != [extension length] + [objectName length] + 1)
					{
						NSString* newPath = [NSString stringWithFormat:@"%@.h", objectName];
						logDebug(@"  - Fixing strange looking class file '%@' to '%@'...",
								 path,
								 newPath);
						[fileNode setStringValue:newPath];
					}
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) fixReferencesForObject:(NSString*) objectName
					 objectData:(NSMutableDictionary*) objectData
						objects:(NSDictionary*) objects
{
	NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet* classStartSet = [NSCharacterSet characterSetWithCharactersInString:@"("];
	NSCharacterSet* classEndSet = [NSCharacterSet characterSetWithCharactersInString:@")"];
	NSCharacterSet* invalidSet = [NSCharacterSet characterSetWithCharactersInString:@" -+"];
	
	// Now look for all <ref> nodes. Then determine the type of link from the link
	// text. The link can either be internal, within the same object or it can be
	// to a member of another object.
	NSXMLDocument* cleanDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
	NSArray* refNodes = [cleanDocument nodesForXPath:@"//ref" error:nil];
	for (NSXMLElement* refNode in refNodes)
	{
		// Get the reference (link) object and member components. The links from
		// doxygen have the format "memberName (ClassName)". The member name includes
		// all the required objective-c colons for methods. Note that some links may 
		// only contain member and some only object components! The links that only
		// contain object component don't encapsulate the object name within the
		// parenthesis! However these are all links to the current object, so we can
		// easily determine the type by comparing to the current object name.
		NSString* refValue = [refNode stringValue];
		if ([refValue length] > 0)
		{
			NSString* refObject = nil;
			NSString* refMember = nil;
			NSScanner* scanner = [NSScanner scannerWithString:refValue];
			
			// If we cannot parse the value of the tag, write the error and continue
			// with next one. Although this should not really happen since we only
			// come here if some text is found, it's still nice to obey the framework...
			if (![scanner scanUpToCharactersFromSet:classStartSet intoString:&refMember])
			{
				logNormal(@"Skipping reference '%@' for object '%@' because tag value was invalid!",
						  refValue,
						  refMember);
				continue;
			}
			refMember = [refMember stringByTrimmingCharactersInSet:whitespaceSet];
			
			// Find and parse the object name part if it exists. Note that we need to be
			// able to handle categories here which should include the ending parenthesis.
			// This is stripped out by the scanner.
			if ([scanner scanCharactersFromSet:classStartSet intoString:NULL])
			{
				if ([scanner scanUpToCharactersFromSet:classEndSet intoString:&refObject])
				{
					refObject = [refObject stringByTrimmingCharactersInSet:whitespaceSet];
					if ([refValue hasSuffix:@"))"]) refObject = [refObject stringByAppendingString:@")"];
				}
			}
			
			// Doxygen appends -p to the end of the protocol names, so we should remove
			// that before checking any further. Note that this apparently happens only
			// for links to protocol members, so we can only test if both components
			// are provided.
			if (refMember && refObject && [refObject hasSuffix:@"-p"])
			{
				logDebug(@"  - Found broken '%@' protocol link...", refObject);
				refObject = [refObject substringToIndex:[refObject length] - 2];
			}
			
			// If we only have one component, we should first determine if it
			// represents an object name or member name. In the second case, the
			// reference is alredy setup properly. In the first case, however, we
			// need to swap the object and member reference.
			if (!refObject && [objects objectForKey:refMember])
			{
				refObject = refMember;
				refMember = nil;
			}
			
			// If the link represents a reference to a merged category, we should change
			// the reference object to the main class.
			if (cmd.mergeKnownCategoriesToClasses &&
				[refObject hasSuffix:@")"] && 
				[refObject hasPrefix:objectName])
			{
				refObject = objectName;
			}
		
			// If we have both components and the object part points to current
			// object, we should discard it and only use member component.
			if (refObject && refMember && [refObject isEqualToString:objectName])
			{
				refObject = nil;
			}
			
			// Validate member reference.
			if (refMember)
			{
				refMember = [refMember stringByTrimmingCharactersInSet:invalidSet];
			}
			
			// Prepare the reference description. Again it depends on the components
			// of the reference value. If both components are present, we should
			// combine them. Otherwise just use the one that is available. Note that
			// in case this is inter-file link we should check if we need to link to
			// another sub-directory.
			NSString* linkDescription = nil;
			NSString* linkReference = nil;
			if (refObject && refMember)
			{
				linkDescription = [self objectLinkNameForObject:refObject andMember:refMember];
				linkReference = [NSString stringWithFormat:@"#%@", refMember];
			}
			else if (refObject)
			{
				linkDescription = refObject;
				linkReference = @"";
			}
			else
			{
				linkDescription = [self memberLinkNameForObject:objectName andMember:refMember];
				linkReference = [NSString stringWithFormat:@"#%@", refMember];
			}
			
			// Check if we need to link to another directory.
			if (refObject && ![refObject isEqualToString:objectName])
			{
				NSString* linkPath = [self objectReferenceFromObject:objectName toObject:refObject];
				linkReference = [NSString stringWithFormat:@"%@%@", linkPath, linkReference];
			}
			
			// Update the <ref> tag. First we need to remove any existing id
			// attribute otherwise the new one will not be used. Then we need to
			// replace the value with the new description.
			NSXMLNode* idAttribute = [NSXMLNode attributeWithName:@"id" stringValue:linkReference];
			[refNode removeAttributeForName:@"id"];
			[refNode addAttribute:idAttribute];
			[refNode setStringValue:linkDescription];
			logDebug(@"  - Found reference to %@ at '%@'.", linkDescription, linkReference);
		}
	}
}

//----------------------------------------------------------------------------------------
- (void) fixParaLinksForObject:(NSString*) objectName
					objectData:(NSMutableDictionary*) objectData
					   objects:(NSDictionary*) objects
{
	// The handling of replacements is done in two phases. First we scan all possible
	// documentation words and prepare the list of words which should be replaced and
	// the corresponding replacement strings. This is held in the replacements dictionary.
	// However in some cases we may have a word which contains another, smaller word
	// within. So we need do first replace the larger word and only then the smaller one.
	// But even this doesn't handle all cases, so we first obsfucate certain replacements
	// which can potentially contain words from other replacements so we obsfucate those
	// and when all are replaced, we run through all obsfucations as well... If we could
	// find a better way of replacing words at the moment of detection, we could avoid
	// all this hassle, but for the moment, we'll have to live with it.
	NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
	NSMutableDictionary* replacements = [NSMutableDictionary dictionary];
	NSMutableDictionary* obsfucations = [NSMutableDictionary dictionary];
	
	// Get given object members. This is used for testing links to the members of the
	// same object.
	NSDictionary* objectMembers = [objectData objectForKey:kTKDataObjectMembersKey];
	
	// We also need to handle broken doxygen member links handling. This is especially
	// evident in categories where the links to member functions are not properly
	// handled at all. At the moment we only handle members which are expressed either
	// as ::<membername> or <membername>() notation. Since doxygen skips these, and
	// leaves the format as it was written in the original documentation, we can
	// easily find them in the source text without worrying about breaking the links
	// we fixed in the above loop.
	NSXMLDocument* cleanDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
	NSArray* textNodes = [cleanDocument nodesForXPath:@"//para/text()|//para/*/text()" error:nil];
	for (NSXMLNode* textNode in textNodes)
	{
		// Scan the text word by word and check the words for possible member links.
		// For each detected member link, add the original and replacement text to
		// the replacements dictionary. We'll use it later on to replace all occurences
		// of the text node string and then replace the whole text node string value.
		NSString* word = nil;			
		NSScanner* scanner = [NSScanner scannerWithString:[textNode stringValue]];
		while ([scanner scanUpToCharactersFromSet:whitespaceSet intoString:&word])
		{
			// Fix members that are declared with two colons. Skip words which are composed
			// from double colons only so that users can still use that in documentation.
			if ([word hasPrefix:@"::"] && [word length] > 2 && ![replacements objectForKey:word])
			{
				NSString* member = [word substringFromIndex:2];
				NSString* name = [self memberLinkNameForObject:objectName andMember:member];
				NSString* link = nil;
				if ([objectMembers objectForKey:member])
				{
					link = [NSString stringWithFormat:@"<ref id=\"#%@\">%@</ref>", member, name];
					logDebug(@"  - Found reference to %@ at '#%@'.", member, member);
				}
				else
				{
					link = name;
					logError(@"- Found reference to unknown member %@!", member);
				}
				[replacements setObject:link forKey:word];
			}
			
			// Fix members that are declated with parenthesis. Skip words which are composed
			// from parenthesis only so that users can still use that in documentation. Note
			// that this is also where we come in case a category member link is desired.
			// For example: for documentation "NSObject(Logging)::logger()", doxygen would
			// convert to "NSObject(Logging)logger()". So we need to check whether the given
			// word contains parenthesis in the middle and assume this is a category member
			// link if so. Note that class members are correctly handled by doxygen, so
			// we don't need to handle these cases.
			if ([word hasSuffix:@"()"] && [word length] > 2 && ![replacements objectForKey:word])
			{
				// Does the word include parenthesis in the middle? If so, this is link to
				// a category member and we should handle it differently because it
				// represents link to member of a category. We should check if the category
				// is known or not and prepare the link in the first case and only prettier
				// name in second. Note that we need to obsfucate the replacement since
				// a category object link may also be present and it will partially
				// replace these!
				NSUInteger firstOpenParLocation = [word rangeOfString:@"("].location;
				NSUInteger firstCloseParLocation = [word rangeOfString:@")"].location;
				if (firstOpenParLocation < [word length] - 2 &&
					firstCloseParLocation < [word length] - 1)
				{
					NSString* category = [word substringToIndex:firstCloseParLocation + 1];
					NSString* member = [word substringFromIndex:firstCloseParLocation + 1];
					member = [member substringToIndex:[member length] - 2];
					NSString* name = [self objectLinkNameForObject:category andMember:member];
					NSDictionary* categoryData = [objects objectForKey:category];
					if (categoryData)
					{
						NSString* categoryLink = [self objectReferenceFromObject:objectName toObject:category];
						NSString* link = [NSString stringWithFormat:@"<ref id=\"%@#%@\">%@</ref>", 
										  categoryLink, 
										  member,
										  name];
						NSString* obsfucated = [self obsfucatedStringFromString:link];
						[obsfucations setObject:link forKey:obsfucated];
						[replacements setObject:obsfucated forKey:word];
						logDebug(@"  - Found reference to member %@ from category %@.", member, category);
					}
					else
					{
						NSString* obsfucated = [self obsfucatedStringFromString:name];
						[obsfucations setObject:name forKey:obsfucated];
						[replacements setObject:obsfucated forKey:word];
						logDebug(@"  - Found reference to member %@ from unknown category %@.", member, category);
					}
				}

				// This is either true member link, protocol link or unknown class link.
				else
				{
					// Does the work contain :: in the middle? If so, this is a link to a
					// protocol or unknown class member, so we need to handle it similar to 
					// categories above.
					NSRange colonsRange = [word rangeOfString:@"::"];
					if (colonsRange.location != NSNotFound)
					{
						NSString* class = [word substringToIndex:colonsRange.location];
						NSString* member = [word substringFromIndex:colonsRange.location + 2];
						member = [member substringToIndex:[member length] - 2];
						NSString* name = [self objectLinkNameForObject:class andMember:member];
						NSDictionary* linkData = [objects objectForKey:class];
						if (linkData)
						{
							NSString* classLink = [self objectReferenceFromObject:objectName toObject:class];
							NSString* link = [NSString stringWithFormat:@"<ref id=\"%@#%@\">%@</ref>", 
											  classLink, 
											  member,
											  name];
							NSString* obsfucated = [self obsfucatedStringFromString:link];
							[obsfucations setObject:link forKey:obsfucated];
							[replacements setObject:obsfucated forKey:word];
							logDebug(@"  - Found reference to member %@ from object %@.", member, class);
						}
						else
						{
							[replacements setObject:name forKey:word];
							logDebug(@"  - Found reference to %@ from unknown class %@.", member, class);
						}
					}
					else
					{
						NSString* member = [word substringToIndex:[word length] - 2];
						NSString* name = [self memberLinkNameForObject:objectName andMember:member];
						NSString* link = nil;
						if ([objectMembers objectForKey:member])
						{
							link = [NSString stringWithFormat:@"<ref id=\"#%@\">%@</ref>", member, name];
							logDebug(@"  - Found reference to %@ at '#%@'.", member, member);
						}
						else
						{
							link = name;
							logError(@"- Found reference to unknown member %@!", member);
						}
						[replacements setObject:link forKey:word];
					}
				}
			}
			
			// Fix known category links.
			NSDictionary* linkedObjectData = [objects objectForKey:word];
			if (linkedObjectData && [[linkedObjectData objectForKey:kTKDataObjectKindKey] isEqualToString:@"category"])
			{
				NSString* link = [self objectReferenceFromObject:objectName toObject:word];
				NSString* linkReference = [NSString stringWithFormat:@"<ref id=\"%@\">%@</ref>", link, word];
				[replacements setObject:linkReference forKey:word];
				logDebug(@"  - Found reference to %@ at '%@'.", word, link);
			}
		}			
	}
	
	// Fix member links within the see also section. We should add the reference for each
	// item which doesn't contain the <ref> tag already. This happens for all references
	// to other classes or categories for which doxygen cannot find the target. Note that
	// we need to add the parenthesis (or any other unique identifier) to these items,
	// since replacing method names will also replace all valid <ref>s which will result
	// in exceptions when parsing the updated XML later on. This is especially important
	// when fixing inter-file links.
	NSArray* testNodes = [cleanDocument nodesForXPath:@"//seeAlso/item" error:nil];
	for (NSXMLNode* testNode in testNodes)
	{
		if ([[testNode nodesForXPath:@"ref" error:nil] count] == 0)
		{
			NSString* itemValue = [[testNode stringValue] stringByTrimmingCharactersInSet:whitespaceSet];
			NSString* name = [self memberLinkNameForObject:objectName andMember:itemValue];
			NSString* link = [NSString stringWithFormat:@"<ref id=\"#%@\">%@</ref>", itemValue, name];
			NSString* fixedValue = [itemValue stringByAppendingString:@"()"];
			[replacements setObject:link forKey:fixedValue];
			[testNode setStringValue:fixedValue];
			logDebug(@"  - Found broken see also reference to '%@'.", itemValue);
		}
	}
		
	// We should replace all found references with correct ones. Note that we
	// must also wrap the replaced string within the <ref> tag. So for example
	// instead of 'work()' we would end with '<ref id="#work">work</ref>'. In order
	// for this to work, we have to export the whole XML, replace all occurences and
	// then re-import the new XML. If we would change text nodes directly, the <ref>
	// tags would be imported as &lt; and similar...
	if ([replacements count] > 0)
	{
		NSString* xmlString = [cleanDocument XMLString];
		
		// Replace all occurences of the found member links with the fixed notation. Note
		// that we have to replace by using sorted keys by their names to make sure we
		// handle larger names first. Note that we need to scan throught
		NSArray* sortedWords = [[replacements allKeys] sortedArrayUsingSelector:@selector(compare:)];
		for (NSString* word in [sortedWords reverseObjectEnumerator])
		{
			NSString* replacement = [replacements objectForKey:word];
			xmlString = [xmlString stringByReplacingOccurrencesOfString:word withString:replacement];
		}
		
		// Now re-apply all obsfucations.
		for (NSString* word in obsfucations)
		{
			NSString* replacement = [obsfucations objectForKey:word];
			xmlString = [xmlString stringByReplacingOccurrencesOfString:word withString:replacement];
		}
		
		// Reload the XML from the updated string and replace the old one in the
		// object data. A bit inefficient, but works...
		NSError* error = nil;
		cleanDocument = [[NSXMLDocument alloc] initWithXMLString:xmlString 
														 options:0 
														   error:&error];
		if (!cleanDocument)
		{
			logError(@"Failed reloading clean XML document!");
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}
		[objectData setObject:cleanDocument forKey:kTKDataObjectMarkupKey];
		[cleanDocument release];
	}		
}

//----------------------------------------------------------------------------------------
- (void) fixEmptyParaForObject:(NSString*) objectName
					objectData:(NSMutableDictionary*) objectData
					   objects:(NSDictionary*) objects
{
	if (cmd.removeEmptyParagraphs)
	{
		// Note that 0xFFFC chars are added during clean XML xstl phase, so these have to be
		// removed too - if the paragraph only contains those, we should delete it... Why
		// this happens I don't know, but this fixes it (instead of only deleting the 0xFFFC
		// we are deleting the last 16 unicode chars). If this creates problems in other
		// languages, we should make this code optional.
		NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
		NSCharacterSet* customSet = [NSCharacterSet characterSetWithRange:NSMakeRange(0xFFF0, 16)];
		
		// Find all paragraphs that only contain empty text and remove them. This will result
		// in better looking documentation. Although these are left because spaces or such
		// were used in the documentation, in most cases they are not desired. For example,
		// Xcode automatically appends a space for each empty documentation line in my style
		// of documenting; since I don't want to deal with this, I will fix it after the
		// documentation has been created.	
		NSXMLDocument* cleanDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
		NSArray* paraNodes = [cleanDocument nodesForXPath:@"//para" error:nil];
		for (NSXMLElement* paraNode in paraNodes)
		{
			NSString* paragraph = [paraNode stringValue];
			paragraph = [paragraph stringByTrimmingCharactersInSet:whitespaceSet];
			paragraph = [paragraph stringByTrimmingCharactersInSet:customSet];
			if ([paraNode childCount] == 0 || [paragraph length] == 0)
			{
				NSXMLElement* parent = (NSXMLElement*)[paraNode parent];
				logDebug(@"  - Removing empty paragraph '%@' index %d from '%@'...",
						 paraNode,
						 [paraNode index],
						 [parent name]);
				[parent removeChildAtIndex:[paraNode index]];
			}
		}		
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSDictionary*) linkDataForObject:(NSString*) objectName
						  andMember:(NSString*) memberName
{
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	NSDictionary* objectData = [objects objectForKey:objectName];
	if (objectData)
	{
		NSDictionary* membersData = [objectData objectForKey:kTKDataObjectMembersKey];
		return [membersData objectForKey:memberName];
	}
	return nil;
}

//----------------------------------------------------------------------------------------
- (NSString*) objectLinkNameForObject:(NSString*) objectName
							andMember:(NSString*) memberName
{
	NSString* prefix = @"";
	NSDictionary* memberData = [self linkDataForObject:objectName andMember:memberName];
	if (memberData) prefix = [memberData objectForKey:kTKDataMemberPrefixKey];
	
	NSString* result = cmd.objectReferenceTemplate;
	result = [result stringByReplacingOccurrencesOfString:@"$PREFIX" withString:prefix];
	result = [result stringByReplacingOccurrencesOfString:@"$OBJECT" withString:objectName];
	result = [result stringByReplacingOccurrencesOfString:@"$MEMBER" withString:memberName];
	return result;
}

//----------------------------------------------------------------------------------------
- (NSString*) memberLinkNameForObject:(NSString*) objectName
							andMember:(NSString*) memberName
{
	NSDictionary* memberData = [self linkDataForObject:objectName andMember:memberName];
	if (memberData) return [memberData objectForKey:kTKDataMemberSelectorKey];
	return memberName;
}

//----------------------------------------------------------------------------------------
- (NSString*) objectReferenceFromObject:(NSString*) source 
							   toObject:(NSString*) destination
{
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	
	// Get the source and destination object's data.
	NSDictionary* sourceData = [objects objectForKey:source];
	NSDictionary* destinationData = [objects objectForKey:destination];
	
	// Get the source and destination object's sub directory.
	NSString* sourceSubdir = [sourceData objectForKey:kTKDataObjectRelDirectoryKey];
	NSString* destinationSubdir = [destinationData objectForKey:kTKDataObjectRelDirectoryKey];
	
	// If the two subdirectories are not the same, we should prepend the relative path.
	if (![sourceSubdir isEqualToString:destinationSubdir])
	{
		return [NSString stringWithFormat:
				@"../%@/%@%@",
				destinationSubdir, 
				destination, 
				kTKPlaceholderExtension];
	}
	
	return [NSString stringWithFormat:@"%@%@", destination, kTKPlaceholderExtension];
}

//----------------------------------------------------------------------------------------
- (NSString*) obsfucatedStringFromString:(NSString*) string
{
	NSMutableString* result = [NSMutableString string];
	for (int i = 0; i < [string length]; i++)
	{
		NSString* original = [string substringWithRange:NSMakeRange(i, 1)];
		[result appendString:original];
		[result appendString:@"*"];
	}
	return result;
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

@synthesize doxygenInfoProvider;

@end
