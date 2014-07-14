//
//  GBTypedefEnumData.m
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBTypedefEnumData.h"

@implementation GBTypedefEnumData
+(id)typedefEnumWithName:(NSString *)name
{
 return [[self alloc] initWithName:name];
}

-(id)initWithName:(NSString *)name
{
    self = [super init];
    if(self)
    {
        _typedefName = name;
        _constants = [[GBEnumConstantProvider alloc] initWithParentObject:self];
    }
    return self;
}

- (NSString *)description {
	return self.nameOfEnum;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"enum %@\n%@", self.nameOfEnum, self.constants.debugDescription];
}

- (BOOL)isTopLevelObject {
	return YES;
}

- (NSString *)enumStyle
{
    return _isOptions?@"NS_OPTIONS":@"NS_ENUM";
}

@synthesize nameOfEnum = _typedefName;
@synthesize constants = _constants;
@synthesize isOptions = _isOptions;
@synthesize enumPrimitive = _enumPrimitive;
@end
