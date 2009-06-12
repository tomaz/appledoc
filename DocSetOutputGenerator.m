//
//  DocSetOutputGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "DocSetOutputGenerator.h"
#import "CommandLineParser.h"
#import "LoggingProvider.h"
#import "Systemator.h"

@implementation DocSetOutputGenerator

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Specific output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (BOOL) isOutputGenerationEnabled
{
	return cmd.createDocSet;
}

//----------------------------------------------------------------------------------------
- (void) generateSpecificOutput
{
	if (!self.documentationFilesInfoProvider)
		[Systemator throwExceptionWithName:kTKConverterException
						   withDescription:@"documentationFilesInfoProvider not set"];
	
	[self createDocSetSourcePlistFile];
	[self createDocSetNodesFile];
	[self createDocSetTokesFile];
	[self createDocSetBundle];
}

//----------------------------------------------------------------------------------------
- (void) createOutputDirectories
{
	// Note that we only manually create temporary documentation set directory here,
	// if the documentation set is installed, it will be copied as a bundle to the
	// appropriate path.
	[Systemator createDirectory:cmd.outputDocSetPath];
	[Systemator createDirectory:cmd.outputDocSetContentsPath];
	[Systemator createDirectory:cmd.outputDocSetResourcesPath];
}

//----------------------------------------------------------------------------------------
- (void) removeOutputDirectories
{
	// Note that we only remove temporary documentation set directory here, the installed
	// copy is always left in it's installation directory.
	[Systemator removeItemAtPath:cmd.outputDocSetPath];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Documentation set handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) createDocSetSourcePlistFile
{
	// If the docset source plist doesn't yet exist, create it, otherwise read the data
	// from it in case the user changes it.
	if (![manager fileExistsAtPath:cmd.docsetSourcePlistPath])
	{
		logNormal(@"Creating DocSet info plist...");
		
		// Create the dictionary and populate it with data.
		NSMutableDictionary* docsetInfo = [[NSMutableDictionary alloc] init];
		[docsetInfo setObject:cmd.docsetBundleID forKey:(NSString*)kCFBundleIdentifierKey];
		[docsetInfo setObject:cmd.projectName forKey:(NSString*)kCFBundleNameKey];
		[docsetInfo setObject:cmd.docsetBundleFeed forKey:@"DocSetFeedName"];
		
		// Convert the dictionary to property list. Exit if anything goes wrong.
		@try
		{
			[Systemator writePropertyList:docsetInfo toFile:cmd.docsetSourcePlistPath];
		}
		@finally
		{			
			[docsetInfo release];
		}
		
		logInfo(@"Finished creating DocSet info plist.");
	}
	
	// If the plist already exists, read the data from it and set it to command line
	// parser so the rest of the code execute after this already uses it. Note that we
	// don't have to handle this if the file doesn't exists - we just created it and
	// populated with default options in such case.
	else
	{
		logNormal(@"Reading DocSet info plist data...");
		
		@try
		{
			// Read the property list from the file and extract the properties.
			NSString* value = nil;
			NSDictionary* docsetInfo = [Systemator readPropertyListFromFile:cmd.docsetSourcePlistPath];
			
			value = [docsetInfo objectForKey:(NSString*)kCFBundleIdentifierKey];
			if (value)
			{
				logVerbose(@"- Updating DocSet bundle ID '%@' from info plist...", value);
				cmd.docsetBundleID = value;
			}
			
			value = [docsetInfo objectForKey:@"DocSetFeedName"];
			if (value)
			{
				logVerbose(@"- Updating DocSet bundle feed '%@' from info plist...", value);
				cmd.docsetBundleFeed = value;
			}
			
		}
		@catch (NSException* e)
		{
			logError(@"Failed readong DocSet info plist data from '%@', error was %@!",
					 cmd.docsetSourcePlistPath,
					 [e reason]);
			@throw;
		}
		logInfo(@"Finished reading DocSet info plist data.");
	}
}

//----------------------------------------------------------------------------------------
- (void) createDocSetNodesFile
{
	logNormal(@"Creating DocSet Nodes.xml file...");	
	NSAutoreleasePool* loopAutoreleasePool = [[NSAutoreleasePool alloc] init];	
	NSXMLDocument* document = [NSXMLDocument document];
	NSString* indexFileName = [documentationFilesInfoProvider outputIndexFilename];
	NSString* hierarchyFileName = [documentationFilesInfoProvider outputHierarchyFilename];
	
	// Create the version and ecoding elements.
	[document setVersion:@"1.0"];
	[document setCharacterEncoding:@"UTF-8"];
	
	// Create the root <DocSetNodes version="1.0"> element.
	NSXMLElement* rootElement = [NSXMLNode elementWithName:@"DocSetNodes"];
	[rootElement addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.0"]];
	[document setRootElement:rootElement];
	
	// Create <TOC> element.
	NSXMLElement* tocElement = [NSXMLNode elementWithName:@"TOC"];
	[rootElement addChild:tocElement];
	
	// Create <Node> element for main index file and all it's descriptors.
	NSXMLElement* indexNodeElement = [NSXMLNode elementWithName:@"Node"];
	[tocElement addChild:indexNodeElement];
	NSXMLElement* indexNameElement = [NSXMLNode elementWithName:@"Name" stringValue:cmd.projectName];
	[indexNodeElement addChild:indexNameElement];
	NSXMLElement* indexPathElement = [NSXMLNode elementWithName:@"Path" stringValue:indexFileName];
	[indexNodeElement addChild:indexPathElement];
	NSXMLElement* indexSubnodesElement = [NSXMLNode elementWithName:@"Subnodes"];
	[indexNodeElement addChild:indexSubnodesElement];
	
	// Since we will create the structure that groups classes, categories and protocols
	// we'll use the directories key - it is structured in exactly the desired way.
	NSDictionary* directories = [database objectForKey:kTKDataMainDirectoriesKey];
	for (NSString* directoryName in directories)
	{
		// Create the node for the directory. The directory node is of type folder and
		// since we don't use a separate html page for it, we map it to the main index.
		NSXMLElement* directoryNodeElement = [NSXMLNode elementWithName:@"Node"];
		[directoryNodeElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"folder"]];
		[indexSubnodesElement addChild:directoryNodeElement];
		NSXMLElement* directoryNameElement = [NSXMLNode elementWithName:@"Name" stringValue:directoryName];
		[directoryNodeElement addChild:directoryNameElement];
		NSXMLElement* directoryPathElement = [NSXMLNode elementWithName:@"Path" stringValue:indexFileName];
		[directoryNodeElement addChild:directoryPathElement];
		NSXMLElement* directorySubnodesElement = [NSXMLNode elementWithName:@"Subnodes"];
		[directoryNodeElement addChild:directorySubnodesElement];
		
		// The directory is represented by an array of object data dictionaries which are
		// simply links to the main "Objects" dictionary, so we can use the data from there.
		NSArray* directoryObjects = [directories objectForKey:directoryName];
		for (NSDictionary* objectData in directoryObjects)
		{
			NSString* objectName = [objectData objectForKey:kTKDataObjectNameKey];
			NSString* objectPath = [documentationFilesInfoProvider outputObjectFilenameForObject:objectData];
			
			NSXMLElement* objectElement = [NSXMLNode elementWithName:@"Node"];
			[directorySubnodesElement addChild:objectElement];
			NSXMLElement* objectNameElement = [NSXMLNode elementWithName:@"Name" stringValue:objectName];
			[objectElement addChild:objectNameElement];
			NSXMLElement* objectPathElement = [NSXMLNode elementWithName:@"Path" stringValue:objectPath];
			[objectElement addChild:objectPathElement];
		}
	}
	
	// At the end of the directories create class hierarchy.
	NSXMLElement* hierarchyNodeElement = [NSXMLNode elementWithName:@"Node"];
	[hierarchyNodeElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"folder"]];
	[indexSubnodesElement addChild:hierarchyNodeElement];
	NSXMLElement* hierarchyNameElement = [NSXMLNode elementWithName:@"Name" stringValue:@"Class hierarchy"];
	[hierarchyNodeElement addChild:hierarchyNameElement];
	NSXMLElement* hierarchyPathElement = [NSXMLNode elementWithName:@"Path" stringValue:hierarchyFileName];
	[hierarchyNodeElement addChild:hierarchyPathElement];
	NSXMLElement* hierarchySubnodesElement = [NSXMLNode elementWithName:@"Subnodes"];
	[hierarchyNodeElement addChild:hierarchySubnodesElement];
	
	// Scan for all classes in the hierarchy.
	NSMutableDictionary* hierarchies = [database objectForKey:kTKDataMainHierarchiesKey];
	for (NSString* objectName in hierarchies)
	{
		NSDictionary* hierarchyData = [hierarchies objectForKey:objectName];
		[self addDocSetNodeToElement:hierarchySubnodesElement fromHierarchyData:hierarchyData];
	}
	
	// Save the document.
	NSError* error = nil;
	NSString* filename = [cmd.outputDocSetResourcesPath stringByAppendingPathComponent:@"Nodes.xml"];
	NSData* documentData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
	if (![documentData writeToFile:filename options:0 error:&error])
	{
		[loopAutoreleasePool drain];
		logError(@"Failed saving DocSet Nodes.xml to '%@'!", filename);
		[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
	}
	
	[loopAutoreleasePool drain];	
	logInfo(@"Finished creating DocSet Nodes.xml file.");
}

//----------------------------------------------------------------------------------------
- (void) createDocSetTokesFile
{
	logNormal(@"Creating DocSet Tokens.xml file...");
	NSAutoreleasePool* loopAutoreleasePool = [[NSAutoreleasePool alloc] init];	
	NSXMLDocument* document = [NSXMLDocument document];
	
	// Create the version and ecoding elements.
	[document setVersion:@"1.0"];
	[document setCharacterEncoding:@"UTF-8"];
	
	// Create the root <Tokens version="1.0"> element.
	NSXMLElement* rootElement = [NSXMLNode elementWithName:@"Tokens"];
	[rootElement addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.0"]];
	[document setRootElement:rootElement];
	
	// The root <Tokens> element contains <File> elements representing individual
	// object files, so we can enumerate over the objects dictionary.
	NSDictionary* objects = [database objectForKey:kTKDataMainObjectsKey];
	for (NSString* objectName in objects)
	{
		// Get required object data.
		NSDictionary* objectData = [objects objectForKey:objectName];
		NSXMLDocument* objectDocument = [objectData objectForKey:kTKDataObjectMarkupKey];
		NSString* objectKind = [objectData objectForKey:kTKDataObjectKindKey];
		NSString* objectRelPath = [documentationFilesInfoProvider outputObjectFilenameForObject:objectData];
		
		// Prepare the object identifier.
		NSString* objectIdentifier = nil;
		if ([objectKind isEqualToString:@"category"])
			objectIdentifier = @"//apple_ref/occ/cat/";
		else if ([objectKind isEqualToString:@"protocol"])
			objectIdentifier = @"//apple_ref/occ/intf/";
		else
			objectIdentifier = @"//apple_ref/occ/cl/";
		objectIdentifier = [objectIdentifier stringByAppendingString:objectName];
		
		// Prepare the object filename.
		NSArray* fileNodes = [objectDocument nodesForXPath:@"object/file" error:nil];
		NSString* objectSrcFilename = ([fileNodes count] > 0) ? [[fileNodes objectAtIndex:0] stringValue] : @"";
		
		// Prepare the object description.
		NSArray* descriptionNodes = [objectDocument nodesForXPath:@"object/description" error:nil];
		NSString* objectDescription = ([descriptionNodes count] > 0) ? [[descriptionNodes objectAtIndex:0] stringValue] : @"";
		
		// Create the <File> element.
		NSXMLElement* fileElement = [NSXMLNode elementWithName:@"File"];
		[fileElement addAttribute:[NSXMLNode attributeWithName:@"path" stringValue:objectRelPath]];
		[rootElement addChild:fileElement];

		// Add the object <Token> element.		
		NSXMLElement* objectTokenElement = [NSXMLNode elementWithName:@"Token"];
		[fileElement addChild:objectTokenElement];
		NSXMLElement* objectIdentElement = [NSXMLNode elementWithName:@"TokenIdentifier" stringValue:objectIdentifier];
		[objectTokenElement addChild:objectIdentElement];
		NSXMLElement* objectDeclaredInElement = [NSXMLNode elementWithName:@"DeclaredIn" stringValue:objectSrcFilename];
		[objectTokenElement addChild:objectDeclaredInElement];
		NSXMLElement* objectAbstractElement = [NSXMLNode elementWithName:@"Abstract" stringValue:objectDescription];
		[objectTokenElement addChild:objectAbstractElement];
		
		// Handle all object members.
		NSArray* memberNodes = [objectDocument nodesForXPath:@"//member" error:nil];
		for (NSXMLElement* memberNode in memberNodes)
		{
			// Prepare member name.
			NSArray* memberNameNodes = [memberNode nodesForXPath:@"name" error:nil];
			NSString* memberName = ([memberNameNodes count] > 0) ? 
				[[memberNameNodes objectAtIndex:0] stringValue] : @"";
			
			// Prepare member file.
			NSArray* memberFileNodes = [memberNode nodesForXPath:@"file" error:nil];
			NSString* memberFile = ([memberFileNodes count] > 0) ? 
				[[memberFileNodes objectAtIndex:0] stringValue] : @"";
			
			// Prepare member prototype.
			NSArray* memberPrototypeNodes = [memberNode nodesForXPath:@"prototype" error:nil];
			NSString* memberPrototype = ([memberPrototypeNodes count] > 0) ? 
				[[memberPrototypeNodes objectAtIndex:0] stringValue] : @"";
			
			// Prepare member description.
			NSArray* memberDescNodes = [memberNode nodesForXPath:@"description" error:nil];
			NSString* memberDescription = ([memberDescNodes count] > 0) ? 
				[[memberDescNodes objectAtIndex:0] stringValue] : @"";
			
			// Prepare member identifier.
			NSString* memberIdentifier = nil;
			if ([objectKind isEqualToString:@"class"])
				memberIdentifier = @"//apple_ref/occ/instm/";
			else
				memberIdentifier = @"//apple_ref/occ/intfm/";
			memberIdentifier = [memberIdentifier stringByAppendingFormat:@"%@/%@", objectName, memberName];
			
			// Add the member <Token> element.
			NSXMLElement* memberTokenElement = [NSXMLNode elementWithName:@"Token"];
			[fileElement addChild:memberTokenElement];
			NSXMLElement* memberIdentElement = [NSXMLNode elementWithName:@"TokenIdentifier" stringValue:memberIdentifier];
			[memberTokenElement addChild:memberIdentElement];
			NSXMLElement* memberAnchorElement = [NSXMLNode elementWithName:@"Anchor" stringValue:memberName];
			[memberTokenElement addChild:memberAnchorElement];
			NSXMLElement* memberDeclaredInElement = [NSXMLNode elementWithName:@"DeclaredIn" stringValue:memberFile];
			[memberTokenElement addChild:memberDeclaredInElement];
			NSXMLElement* memberDeclElement = [NSXMLNode elementWithName:@"Declaration" stringValue:memberPrototype];
			[memberTokenElement addChild:memberDeclElement];
			NSXMLElement* memberAbstractElement = [NSXMLNode elementWithName:@"Abstract" stringValue:memberDescription];
			[memberTokenElement addChild:memberAbstractElement];
		}
	}
	
	// Save the document.
	NSError* error = nil;
	NSString* filename = [cmd.outputDocSetResourcesPath stringByAppendingPathComponent:@"Tokens.xml"];
	NSData* documentData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
	if (![documentData writeToFile:filename options:0 error:&error])
	{
		[loopAutoreleasePool drain];
		logError(@"Failed saving DocSet Tokens.xml to '%@'!", filename);
		[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
	}
	
	[loopAutoreleasePool drain];	
	logInfo(@"Finished creating DocSet Tokens.xml file.");
}

//----------------------------------------------------------------------------------------
- (void) createDocSetBundle
{
	logNormal(@"Creating DocSet bundle...");
	
	// First copy the info plist file into the contents output.
	NSString* plistDestPath = [cmd.outputDocSetContentsPath stringByAppendingPathComponent:@"Info.plist"];
	logVerbose(@"Copying info plist file to '%@'...", plistDestPath);
	[Systemator copyItemAtPath:cmd.docsetSourcePlistPath toPath:plistDestPath];
	
	// Copy all html files to the bundle structure.
	logVerbose(@"Copying clean XHTML to '%@'...", cmd.outputDocSetDocumentsPath);
	[Systemator copyItemAtPath:cmd.outputCleanXHTMLPath toPath:cmd.outputDocSetDocumentsPath];
	
	// Index the documentation set.
	logVerbose(@"Indexing DocSet...");
	[Systemator runTask:cmd.docsetutilCommandLine, @"index", cmd.outputDocSetPath, nil];
	
	// Copy the documentation set to the proper directory. First we need to remove
	// previous files otherwise copying will fail.
	NSString* docsetInstallPath = [cmd.docsetInstallPath stringByAppendingPathComponent:cmd.docsetBundleID];
	logVerbose(@"Copying DocSet bundle to '%@'...", docsetInstallPath);
	[Systemator copyItemAtPath:cmd.outputDocSetPath toPath:docsetInstallPath];
	
	// Install the script to the Xcode.
	logVerbose(@"Installing DocSet to Xcode...");
	NSMutableString* installCode = [NSMutableString string];
	[installCode appendString:@"tell application \"Xcode\"\n"];
	[installCode appendFormat:@"\tload documentation set with path \"%@\"\n", docsetInstallPath];
	[installCode appendString:@"end tell"];
	
	NSAppleScript* installScript = [[NSAppleScript alloc] initWithSource:installCode];
	NSDictionary* errorDict = nil;
	if (![installScript executeAndReturnError:&errorDict])
	{
		[installScript release];
		NSString* message = [NSString stringWithFormat:@"Installation of DocSet failed with message:\n'%@'!", 
							 [errorDict objectForKey:NSAppleScriptErrorMessage]];
		logError(@"Failed installing DocSet to Xcode documentation!");
		[Systemator throwExceptionWithName:kTKConverterException withDescription:message];
	}
	[installScript release];
		
	// If cleantemp is used, remove clean html and docset temporary files.
	if (cmd.cleanTempFilesAfterBuild && [manager fileExistsAtPath:cmd.outputCleanXHTMLPath])
	{
		logInfo(@"Removing temporary clean XHTML files at '%@'...", cmd.outputCleanXHTMLPath);
		NSError* error = nil;
		if (![manager removeItemAtPath:cmd.outputCleanXHTMLPath error:&error])
		{
			logError(@"Failed removing temporary XHTML files at '%@'!", cmd.outputCleanXHTMLPath);
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}		
	}
	
	// If cleantemp is used, remove docset temporary files.
	if (cmd.cleanTempFilesAfterBuild && [manager fileExistsAtPath:cmd.outputDocSetPath])
	{
		logInfo(@"Removing temporary clean XHTML files at '%@'...", cmd.outputDocSetPath);
		NSError* error = nil;
		if (![manager removeItemAtPath:cmd.outputDocSetPath error:&error])
		{
			logError(@"Failed removing temporary DocSet files at '%@'!", cmd.outputDocSetPath);
			[Systemator throwExceptionWithName:kTKConverterException basedOnError:error];
		}		
	}
	
	logInfo(@"Finished creating DocSet bundle.");
}

//----------------------------------------------------------------------------------------
- (void) addDocSetNodeToElement:(NSXMLElement*) parent
			  fromHierarchyData:(NSDictionary*) data
{
	NSDictionary* children = [data objectForKey:kTKDataHierarchyChildrenKey];
	NSDictionary* objectData = [data objectForKey:kTKDataHierarchyObjectDataKey];
	NSString* objectName = [data objectForKey:kTKDataHierarchyObjectNameKey];
	NSString* objectPath = [objectData objectForKey:kTKDataObjectRelPathKey];
	objectPath = objectPath ?
		[documentationFilesInfoProvider outputObjectFilenameForObject:objectData] :
		[documentationFilesInfoProvider outputHierarchyFilename];

	// Create the main node that will represent the object.
	NSXMLElement* node = [NSXMLNode elementWithName:@"Node"];
	[parent addChild:node];
	
	// Create the name and path subnodes. Note that the path will be the main hierarchy
	// index file if the node is not documented.
	NSXMLElement* nameElement = [NSXMLNode elementWithName:@"Name" stringValue:objectName];
	[node addChild:nameElement];
	NSXMLElement* pathElement = [NSXMLNode elementWithName:@"Path" stringValue:objectPath];
	[node addChild:pathElement];
	
	// If there are children, set the node type to folder and add subnodes.
	if ([children count] > 0)
	{
		[node addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"folder"]];
		
		NSXMLElement* subnodesElement = [NSXMLNode elementWithName:@"Subnodes"];
		[node addChild:subnodesElement];
		
		for (NSString* childName in children)
		{
			NSDictionary* childHierarchyData = [children objectForKey:childName];
			[self addDocSetNodeToElement:subnodesElement fromHierarchyData:childHierarchyData];
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

@synthesize documentationFilesInfoProvider;

@end
