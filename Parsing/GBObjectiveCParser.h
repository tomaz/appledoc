//
//  GBObjectiveCParser.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implements Objective-C source code parser.
 
 The main responsibility of this class is encapsulation of Objective-C source code parsing into in-memory representation. As we're only parsing a small subset of Objective-C and even then we don't need to handle much specifics beyond recognizing different classes, variables, methods etc., overall the parsing process is quite simple. Basically we use ParseKit's `PKTokenizer` to split given input string into tokens and then traverse the list of tokens to get the data we need.
 */
@interface GBObjectiveCParser : NSObject

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
 @param filename The name of the file including extension.
 @param store Store into which the objects should be added.
 @exception NSException Thrown if the given input or store is `nil`.
 */
- (void)parseObjectsFromString:(NSString *)input sourceFile:(NSString *)filename toStore:(id)store;

@end
