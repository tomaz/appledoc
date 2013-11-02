//
//  GBDocSetPublishGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 18.1.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBTask.h"
#import "GBDataObjects.h"
#import "GBTemplateHandler.h"
#import "GBDocSetPublishGenerator.h"

@implementation GBDocSetPublishGenerator

#pragma Generation handling

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
	NSParameterAssert(self.previousGenerator != nil);
	GBLogInfo(@"Preparing DocSet for publishing...");
	
	// Prepare for run.
	if (![super generateOutputWithStore:store error:error]) return NO;
	GBTask *task = [GBTask task];
	task.reportIndividualLines = YES;
	
	// Get the path to the installed documentation set and extract the name. Then replace the name's extension with .xar.
	NSString *inputDocSetPath = self.inputUserPath;
	NSString *atomName = self.settings.docsetAtomFilename;
    NSString *xmlName = self.settings.docsetXMLFilename;
    NSString *installedDocSetPath = inputDocSetPath;
    
    // If installation was skipped, move the docset folder to a .docset bundle.
    if (!self.settings.installDocSet) {
        installedDocSetPath = [self.settings.outputPath stringByAppendingPathComponent:self.settings.docsetBundleFilename];
        installedDocSetPath = [installedDocSetPath stringByStandardizingPath];
        GBLogVerbose(@"Moving DocSet files from '%@' to '%@'...", inputDocSetPath, installedDocSetPath);
        if (![self copyOrMoveItemFromPath:inputDocSetPath toPath:installedDocSetPath error:error]) {
            GBLogWarn(@"Failed moving DocSet files from '%@' to '%@'!", inputDocSetPath, installedDocSetPath);
            return  NO;
        }
    }
	
	// Prepare command line arguments for packaging.
	NSString *outputDir = self.outputUserPath;
	NSString *outputDocSetPath = [outputDir stringByAppendingPathComponent:self.settings.docsetPackageFilename];
	NSString *outputAtomPath = [outputDir stringByAppendingPathComponent:atomName];
    NSString *outputXMLPath = [outputDir stringByAppendingPathComponent:xmlName];
	NSString *signer = self.settings.docsetCertificateSigner;
	NSString *url = self.settings.docsetPackageURL;
    
    NSMutableArray *outputPaths = [NSMutableArray arrayWithCapacity:2];
    if(self.settings.docsetFeedFormats & GBPublishedFeedFormatAtom)
        [outputPaths addObject:outputAtomPath];
    if(self.settings.docsetFeedFormats & GBPublishedFeedFormatXML)
        [outputPaths addObject:outputXMLPath];

	if ([url length] == 0) {
		url = ([outputPaths count] > 0) ? outputPaths[0] : @"";
		GBLogWarn(@"--docset-package-url is required for publishing DocSet; placeholder will be used in '%@'!", [outputPaths componentsJoinedByString:@", "]);
	}
	
	// Create destination directory.
	if (![self initializeDirectoryAtPath:outputDir preserve:[NSArray arrayWithObject:atomName] error:error]) {
		GBLogWarn(@"Failed initializing DocSet publish directory '%@'!", outputDir);
		return NO;
	}
	
    if(self.settings.docsetFeedFormats & GBPublishedFeedFormatAtom)
    {
        // typical atom enclosure url does not have an extension, add it if it doesn't
        if ([url length] > 0 && ![url hasSuffix:@".xar"]) url = [url stringByAppendingPathExtension:@"xar"];
        
        // Create command line arguments array.
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:@"docsetutil"];
        [args addObject:@"package"];
		[args addObject:@"-verbose"];
        [args addObject:@"-output"];
        [args addObject:[[outputDocSetPath stringByStandardizingPath] stringByAppendingString:@".xar"]];
        [args addObject:@"-atom"];
        [args addObject:[outputAtomPath stringByStandardizingPath]];
        if ([signer length] > 0) {
            [args addObject:@"-signid"];
            [args addObject:signer];
        }
        if ([url length] > 0) {
            [args addObject:@"-download-url"];
            [args addObject:url];
        }
        [args addObject:installedDocSetPath];
        
        // Run the task.
        BOOL result = [task runCommand:self.settings.xcrunPath arguments:args block:^(NSString *output, NSString *error) {
            if (output) GBLogDebug(@"> %@", [output stringByTrimmingWhitespaceAndNewLine]);
            if (error) GBLogError(@"!> %@", [error stringByTrimmingWhitespaceAndNewLine]);
        }];
        if (!result) {
            if (error) *error = [NSError errorWithCode:GBErrorDocSetUtilIndexingFailed description:@"docsetutil failed to package the documentation set!" reason:task.lastStandardError];
            return NO;
        }
    }
    
    if(self.settings.docsetFeedFormats & GBPublishedFeedFormatXML)
    {
        NSString *extension = @"tgz";
        
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:@"tar"];
        [args addObject:@"--exclude"];
        [args addObject:@".DS_Store"];
        [args addObject:@"-czPf"];
        [args addObject:[[outputDocSetPath stringByStandardizingPath] stringByAppendingPathExtension:extension]];
        [args addObject:installedDocSetPath];
        
        // Run the task.
        BOOL result = [task runCommand:self.settings.xcrunPath arguments:args block:^(NSString *output, NSString *error) {
            if (output) GBLogDebug(@"> %@", [output stringByTrimmingWhitespaceAndNewLine]);
            if (error) GBLogError(@"!> %@", [error stringByTrimmingWhitespaceAndNewLine]);
        }];
        if (!result) {
            if (error) *error = [NSError errorWithCode:GBErrorDocSetUtilIndexingFailed description:@"tar failed to package the documentation set!" reason:task.lastStandardError];
            return NO;
        }
        
        NSString *xmlTemplatePath = [[NSString stringWithFormat:@"%@/%@", [self templateUserPath], [self templatePathForTemplateEndingWith:@"xml-template.xml"]] stringByExpandingTildeInPath];
        
        NSString *xmlString = [NSString stringWithContentsOfFile:xmlTemplatePath encoding:NSUTF8StringEncoding error:error];
        
        if(!xmlString)
        {
            if (error) *error = [NSError errorWithCode:GBErrorDocSetUtilIndexingFailed description:[NSString stringWithFormat:@"failed to read the xml template document in %@!", xmlTemplatePath] reason:task.lastStandardError];
            return NO;
        }
        NSString *tarURL = self.settings.docsetPackageURL;
        tarURL = [[tarURL stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
        
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"${DOCSET_PACKAGE_URL}" withString:tarURL];
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"${DOCSET_FEED_VERSION}" withString:self.settings.projectVersion];
        result = [self writeString:xmlString toFile:[outputXMLPath stringByStandardizingPath] error:error];
        if(!result)
        {
            if (error) *error = [NSError errorWithCode:GBErrorDocSetUtilIndexingFailed description:@"failed to write the xml feed!" reason:task.lastStandardError];
            return NO;
        }
    }

	return YES;
}

#pragma mark Overriden methods

- (NSString *)outputSubpath {
	return @"publish";
}

@end
