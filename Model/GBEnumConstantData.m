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
    return [[GBEnumConstantData alloc] initWithName:name];
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

- (NSString *)description {
	return self.name;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@: %@", [self className], self.name];
}

- (bool)hasAssignedValue
{
    return _assignedValue != nil;
}

@synthesize name = _name;
@synthesize assignedValue = _assignedValue;
@end
