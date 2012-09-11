//
//  DDXcodeProjectFile.h
//  appledoc
//
//  Created by Dominik Pich on 9/4/12.
//  Copyright (c) 2012 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @file DDXcodeProjectFile.h */

/**
 * reads an xcode 4 Project file and provides an in memory representation
 * @warning WHICH cannot be saved at the moment
 * @warning Does only provide the fundamental project settings right now as that's all I need ATM :D
 */
@interface DDXcodeProjectFile : NSObject

@property(readonly) NSString *path;
@property(readonly) NSDictionary *dictionary;

@property(readonly) NSString *name;
@property(readonly) NSString *minimumVersion;
@property(readonly) NSString *company;
@property(readonly) NSString *projectRoot;
@property(readonly) NSString *classPrefix;
@property(readonly) NSString *developmentRegion;

/**
 * an array of 1-N dicts for all files found in the project. Each dictionary contains 'path' and 'type'
 * the path is resolved to an absolute path
 */
@property(readonly) NSArray *files;

+ (id)xcodeProjectFileWithPath:(NSString*)path error:(NSError**)pError;
+ (id)xcodeProjectFileWithDictionary:(NSDictionary*)dict error:(NSError**)pError;

@end
