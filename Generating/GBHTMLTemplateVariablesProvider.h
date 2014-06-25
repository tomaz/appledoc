//
//  GBHTMLTemplateVariablesProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBClassData;

/** Provides variables for HTML template string for given objects.
 
 The main purpose of this class is to prepare an intermediate variables from given objects suitable for template generation. Although original object could easily be used within templates, using simplified, intermediate, form greatly simplifies template files. Think of the variables as the controlley layer for the template engine.
 
 This class is intended to be reused, create a single instance and pass it the objects - one by one - for which you'd like to get template variables.
 */
@interface GBHTMLTemplateVariablesProvider : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased provider that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)providerWithSettingsProvider:(id)settingsProvider;

/** Initializes the provider to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Variables handling
///---------------------------------------------------------------------------------------

/** Returns the variables for the given `GBClassData` using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate class specific output.
 
 @param object The class for which to return variables.
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForCategory:withStore:
 @see variablesForProtocol:withStore:
 @see variablesForDocument:withStore:
 @see variablesForIndexWithStore:
 @see variablesForHierarchyWithStore:
 */
- (NSDictionary *)variablesForClass:(GBClassData *)object withStore:(id)store;

/** Returns the variables for the given `GBCategoryData` using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate category specific output.
 
 @param object The category for which to return variables.
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForClass:withStore:
 @see variablesForProtocol:withStore:
 @see variablesForDocument:withStore:
 @see variablesForIndexWithStore:
 @see variablesForHierarchyWithStore:
 */
- (NSDictionary *)variablesForCategory:(GBCategoryData *)object withStore:(id)store;

/** Returns the variables for the given `GBProtocolData` using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate protocol specific output.
 
 @param object The protocol for which to return variables.
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForClass:withStore:
 @see variablesForCategory:withStore:
 @see variablesForDocument:withStore:
 @see variablesForIndexWithStore:
 @see variablesForHierarchyWithStore:
 */
- (NSDictionary *)variablesForProtocol:(GBProtocolData *)object withStore:(id)store;

- (NSDictionary *)variablesForConstant:(GBTypedefEnumData *)object withStore:(id)store;

- (NSDictionary *)variablesForBlocks:(GBTypedefBlockData *)typedefBlock withStore:(id)store;

/** Returns the variables for the given `GBDocumentData` using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate document specific output.
 
 @param object The document for which to return variables.
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForClass:withStore:
 @see variablesForCategory:withStore:
 @see variablesForProtocol:withStore:
 @see variablesForIndexWithStore:
 @see variablesForHierarchyWithStore:
 */
- (NSDictionary *)variablesForDocument:(GBDocumentData *)object withStore:(id)store;

/** Returns the variables for the index file using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate protocol specific output.
 
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForClass:withStore:
 @see variablesForCategory:withStore:
 @see variablesForProtocol:withStore:
 @see variablesForDocument:withStore:
 @see variablesForHierarchyWithStore:
 */
- (NSDictionary *)variablesForIndexWithStore:(id)store;

/** Returns the variables for the hierarchy file using the given `GBStore` for links. 
 
 The result can be used with `GBTemplateHandler` to generate protocol specific output.
 
 @param store Store provider to be used for links generation.
 @return Returns dictionary of all variables.
 @exception NSException Thrown if the given object or store is `nil`.
 @see variablesForClass:withStore:
 @see variablesForCategory:withStore:
 @see variablesForProtocol:withStore:
 @see variablesForDocument:withStore:
 @see variablesForIndexWithStore:
 */
- (NSDictionary *)variablesForHierarchyWithStore:(id)store;

@end
