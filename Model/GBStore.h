//
//  GBStore.h
//  appledoc
//
//  Created by Tomaz Kragelj on 25.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStoreProviding.h"

/** Implements the application's in-memory objects data store.
 */
@interface GBStore : NSObject <GBStoreProviding> {
	@private
	NSMutableSet *_classes;
	NSMutableDictionary *_classesByName;
}

/** Returns all registered classes sorted by their name. */
- (NSArray *)classesSortedByName;

@end
