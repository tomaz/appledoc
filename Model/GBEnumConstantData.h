//
//  GBEnumConstantData.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@interface GBEnumConstantData : GBModelBase
{
    @private
    NSString *_name;
    NSString *_assignedValue;
}
+(id)constantWithName:(NSString *)name;

@property (readonly) NSString *name;
@property (copy) NSString *assignedValue;
@property (readonly) bool hasAssignedValue;
@end
