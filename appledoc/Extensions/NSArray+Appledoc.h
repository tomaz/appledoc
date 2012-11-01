//
//  NSArray+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@interface NSArray (Appledoc)

- (BOOL)gb_containsObjectWithValue:(id)value forSelector:(SEL)selector;
- (NSUInteger)gb_indexOfObjectWithValue:(id)value forSelector:(SEL)selector;

@end
