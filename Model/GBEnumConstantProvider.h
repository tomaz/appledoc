//
//  GBEnumConstantProvider.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBEnumConstantData.h"

/** Provides abstract access to enumerated constants withing a typedef'd enum */
@interface GBEnumConstantProvider : NSObject
{
    @private
    NSMutableArray *_constants;
    id _parent;
    BOOL _useAlphabeticalOrder;
}

- (id)initWithParentObject:(id)parent;
- (void)registerConstant:(GBEnumConstantData *)constant;

/** the collection of constants defined for this enum */
@property (readonly) NSArray *constants;
@end
