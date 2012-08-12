//
//  Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class GBSettings;
@class Store;
@class Parser;
@class Processor;

/** Main appledoc class.
 
 To use it, instantiate it and invoke `runWithSettings:`! You can optionally supply it desired objects to work with, such as store or parser, but this is meant more or less for unit testing purposes; default objects are used if nothing is given.
 */
@interface Appledoc : NSObject

- (NSInteger)runWithSettings:(GBSettings *)settings;

@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) Parser *parser;
@property (nonatomic, strong) Processor *processor;

@end
