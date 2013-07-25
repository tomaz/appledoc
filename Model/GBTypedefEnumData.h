//
//  GBTypedefEnumData.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"
#import "GBEnumConstantProvider.h"

@interface GBTypedefEnumData : GBModelBase
{
    @private
    NSString *_typedefName;
    GBEnumConstantProvider *_constants;
}

+(id)typedefEnumWithName:(NSString *)name;

@property (readonly) NSString *nameOfEnum;
@property (readonly) GBEnumConstantProvider *constants;
@end
