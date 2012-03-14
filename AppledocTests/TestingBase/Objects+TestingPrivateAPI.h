//
//  Objects+TestingPrivateAPI.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommandLineArgumentsParser.h"

// Commonly used objects private APIs that allow unit testing

@interface Settings (TestingPrivateAPI)
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Settings *parent;
@property (nonatomic, strong) NSMutableDictionary *storage;
@end

@interface CommandLineArgumentsParser (TestingPrivateAPI)
@property (nonatomic, strong) NSDictionary *registeredOptionsByLongNames;
@end
