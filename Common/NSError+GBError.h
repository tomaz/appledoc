//
//  NSError+GBError.h
//  appledoc
//
//  Created by Tomaz Kragelj on 29.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Adds helper methods to `NSError` for more organized code.
 */
@interface NSError (GBError)

/** Creates a new `NSError` with appledoc domain and given information.
 
 @param code Error code.
 @param description Error localized description.
 @param reason Error localized failure reason.
 @return Returns autoreleased `NSError` with the given data.
 */
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;

@end

enum {
	GBErrorTemplatePathDoesntExist = 1000,
	GBErrorTemplatePathNotDirectory,
	
	GBErrorHTMLObjectTemplateMissing = 8000,
	GBErrorHTMLDocumentTemplateMissing,
	GBErrorHTMLIndexTemplateMissing,
	GBErrorHTMLHierarchyTemplateMissing,
	
	GBErrorDocSetDocumentTemplateMissing = 9000,
	GBErrorDocSetInfoPlistTemplateMissing,
	GBErrorDocSetNodesTemplateMissing,
	GBErrorDocSetUtilIndexingFailed,
	GBErrorDocSetXcodeReloadFailed,
};
typedef NSUInteger GBErrorCode;
