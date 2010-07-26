//
//  GBObjectiveCParser.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBTokenizer;
@protocol GBApplicationSettingsProviding;
@protocol GBStoreProviding;

/** Implements Objective-C source code parser.
 
 The main responsibility of this class is encapsulation of Objective-C source code parsing into in-memory representation.
 */
@interface GBObjectiveCParser : NSObject {
	@private
	GBTokenizer *_tokenizer;
}

///---------------------------------------------------------------------------------------
/// @name ￼Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased parser to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)parserWithSettingsProvider:(id)settingsProvider;

/** Initializes the parser to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Parsing handling
///---------------------------------------------------------------------------------------

/** Parses all objects from the given string.
 
 The method adds all detected objects to the given store.
 
 @param input The input string to parse from.
 @param store Store into which the objects should be added.
 @exception NSException Thrown if the given input or store is `nil`.
 */
- (void)parseObjectsFromString:(NSString *)input toStore:(id)store;

@end
