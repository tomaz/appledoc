//
//  Store.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** The main data store for the application.
 
 The store contains all objects parsed from input files. It's designed as the central object for passing data around various components.
 */
@interface Store : NSObject

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name;
- (void)beginExtensionForClass:(NSString *)name;
- (void)beginCategoryWithName:(NSString *)category forClass:(NSString *)name;

@end
