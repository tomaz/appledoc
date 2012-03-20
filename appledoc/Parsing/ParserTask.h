//
//  ParserTask.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class GBSettings;
@class Store;

/** Helper base class for handling parsing of individual files.
 
 This class simplifies and unifies behavior for all different parsing tasks. For example a concrete parsing task may be particular language parser etc. Each concrete parser task should be designed to have its instance objects reusable. That is - each instance is only constructed once and the same instance gets invoked for parsing each different file.
 */
@interface ParserTask : NSObject

- (NSInteger)parseFile:(NSString *)filename withSettings:(GBSettings *)settings store:(Store *)store;

@end

#pragma mark - 


/** Private API for ParserTask subclasses.
 
 This is sent internally by ParserTask and should not be used otherwise.
 */
@interface ParserTask (Subclass)
- (NSInteger)parseString:(NSString *)string;
@property (nonatomic, strong, readonly) Store *store;
@property (nonatomic, strong, readonly) GBSettings *settings;
@property (nonatomic, strong, readonly) NSString *filename;
@end
