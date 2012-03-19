//
//  Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class GBSettings;
@class Store;

/** Main appledoc class.
 
 To use it, instantiate it, pass it desired settings stack and invoke run method!
 */
@interface Appledoc : NSObject

- (void)runWithSettings:(GBSettings *)settings;

@property (nonatomic, strong) Store *store;

@end
