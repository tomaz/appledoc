//
//  GBEnumConstantProvider.m
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBEnumConstantProvider.h"

@implementation GBEnumConstantProvider

- (id)initWithParentObject:(id)parent {
    NSParameterAssert(parent != nil);
    GBLogDebug(@"Initializing enumConstant provider for %@...", parent);
    self = [super init];
    if (self) {
        _parent = [parent retain];
        _constants = [[NSMutableArray alloc] init];
        _useAlphabeticalOrder = YES;
    }
    return self;
}

-(void)registerConstant:(GBEnumConstantData *)constant {
    
}

@synthesize constants = _constants;
@end
