//
//  GBDocumentData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"

@class GBAdoptedProtocolsProvider;
@class GBMethodsProvider;

/** Describes a static document.
 */
@interface GBDocumentData : GBModelBase <GBObjectDataProviding> {
	@private
	GBAdoptedProtocolsProvider *_adoptedProtocols;
	GBMethodsProvider *_methods;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the document data with the given contents.
 
 @param contents Contents of the document as read from file.
 @param path Full path to the document.
 @return Returns initialized object.
 @exception NSException Thrown if the given contents is `nil`.
 */
+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path;

/** Returns autoreleased instance of the document data with the given contents.
 
 This is just a convenience initializer that also sets `basePathOfDocument`.
 
 @param contents Contents of the document as read from file.
 @param path Full path to the document.
 @param basePath Full base path of the document as specified from the include switch.
 @return Returns initialized object.
 @exception NSException Thrown if the given contents is `nil`.
 */
+ (id)documentDataWithContents:(NSString *)contents path:(NSString *)path basePath:(NSString *)basePath;

/** Initializes the document with the given contents.
 
 The initializer copies the given contents string into the assigned comment's string value which unifies post processing handling. This is the designated initializer.
 
 @param contents Contents of the document as read from file.
 @param path Full path to the document.
 @return Returns initialized object.
 @exception NSException Thrown if the given contents is `nil`.
 */
- (id)initWithContents:(NSString *)contents path:(NSString *)path;

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

/** The name of the document. 
 
 Name is automatically retrieved from the `pathOfDocument` inside the initializer.
 
 @see pathOfDocument
 @see basePathOfDocument
 */
@property (copy) NSString *nameOfDocument;
@property (copy) NSString *prettyNameOfDocument;

/** Full path of the document source, including the file name and extension.
 
 @see nameOfDocument
 @see basePathOfDocument
 @see subpathOfDocument
 */
@property (copy) NSString *pathOfDocument;

/** Input base path from the setting at which the document was found.
 
 This is used to prepare proper HTML references from the document to other objects among other things.
 
 @warning *Important:* The value must be set by client in order for the object to be usable! The client must supply full, standardized path - i.e. use `stringByStandardizingPath` for the value assigned!
 
 @see pathOfDocument
 @see subpathOfDocument
 @see nameOfDocument
 */
@property (copy) NSString *basePathOfDocument;

/** Returns the subpath of the document including document's filename.
 
 Subpath is simply the subpath within the `basePathOfDocument`. For example, if the value of `pathOfDocument` is `path/sub/document.ext` and value of `basePathOfDocument` is `path`, this returns `sub/document.ext`.
 
 @see pathOfDocument
 @see basePathOfDocument
 */
@property (readonly) NSString *subpathOfDocument;

/** Specifies whether this is custom document or not.
 
 This is used when creating cross references; if the value is `YES`, `basePathOfDocument` is considered as the subpath from the root output path.
 */
@property (assign) BOOL isCustomDocument;

@end
