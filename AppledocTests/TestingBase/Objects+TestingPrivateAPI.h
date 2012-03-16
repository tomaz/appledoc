//
//  Objects+TestingPrivateAPI.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "GBCommandLineParser.h"

// Commonly used objects private APIs that allow unit testing

@interface GBSettings (TestingPrivateAPI)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) GBSettings *parent;
@property (nonatomic, strong) NSMutableDictionary *storage;
@end

@interface GBCommandLineParser (TestingPrivateAPI)
@property (nonatomic, strong) NSDictionary *registeredOptionsByLongNames;
@end
