//
//  GBEnumConstantData.m
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBEnumConstantData.h"

@implementation GBEnumConstantData
+(id)constantWithName:(NSString *)name
{
    return [[[GBEnumConstantData alloc] initWithName:name] retain];
}

-(id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        _name = name;
    }
    return self;
}

@synthesize name = _name;
@end
