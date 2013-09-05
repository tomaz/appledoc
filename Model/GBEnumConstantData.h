//
//  GBEnumConstantData.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

/** Describes a single enumeration constant */
@interface GBEnumConstantData : GBModelBase
{
    @private
    NSString *_name;
    NSString *_assignedValue;
}
+(id)constantWithName:(NSString *)name;

/** the name of the constant */
@property (readonly) NSString *name;

/** An option assigned value for this constant */
@property (copy) NSString *assignedValue;

/** A boolean indicating if this enum has an assigned value. The boolean is used in the generation phase */
@property (readonly) bool hasAssignedValue;
@end
