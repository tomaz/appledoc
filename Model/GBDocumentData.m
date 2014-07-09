//
//  GBDocumentData.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBDocumentData.h"

@implementation GBDocumentData

#pragma mark Initialization & disposal

+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path {
	return [[self alloc] initWithContents:contents path:path];
}

+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path basePath:(NSString *)basePath {
	id result = [self documentDataWithContents:contents path:path];
	[result setBasePathOfDocument:basePath];
	return result;
}

- (id)initWithContents:(NSString *)contents path:(NSString *)path {
	NSParameterAssert(contents != nil);
	GBLogDebug(@"Initializing document with contents %@...", [contents normalizedDescription]);
	self = [super init];
	if (self) {
		GBSourceInfo *info = [GBSourceInfo infoWithFilename:path lineNumber:1];
		[self registerSourceInfo:info];
		self.nameOfDocument = [path lastPathComponent];
		self.pathOfDocument = path;
		self.basePathOfDocument = @"";
		self.comment = [GBComment commentWithStringValue:contents];
		self.comment.sourceInfo = info;
		_adoptedProtocols = [[GBAdoptedProtocolsProvider alloc] initWithParentObject:self];
		_methods = [[GBMethodsProvider alloc] initWithParentObject:self];
        
        self.prettyNameOfDocument = [[self.nameOfDocument stringByDeletingPathExtension]stringByReplacingOccurrencesOfString:@"-template" withString:@""];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.nameOfDocument;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"document %@", self.nameOfDocument];
}

- (BOOL)isStaticDocument {
	return YES;
}

#pragma mark Properties

- (NSString *)subpathOfDocument {
	NSString *result = [self.pathOfDocument stringByReplacingOccurrencesOfString:self.basePathOfDocument withString:@""];
	if ([result hasPrefix:@"/"]) result = [result substringFromIndex:1];
	return result;
}

@synthesize isCustomDocument;
@synthesize nameOfDocument;
@synthesize pathOfDocument;
@synthesize basePathOfDocument;
@synthesize adoptedProtocols = _adoptedProtocols;
@synthesize methods = _methods;
@synthesize prettyNameOfDocument;

@end
