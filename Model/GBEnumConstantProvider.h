//
//  GBEnumConstantProvider.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBEnumConstantData.h"

@interface GBEnumConstantProvider : NSObject
{
    @private
    NSMutableArray *_constants;
    id _parent;
    BOOL _useAlphabeticalOrder;
}

- (id)initWithParentObject:(id)parent;
- (void)registerConstant:(GBEnumConstantData *)constant;

@property (readonly) NSArray *constants;
@end
