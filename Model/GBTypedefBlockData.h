//
//  GBTypedefBlockData.h
//  appledoc
//
//  Created by Teichmann, Bjoern on 23.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@interface GBTypedefBlockData : GBModelBase
{
    @private
    NSString *_blockName;
    NSString *_returnType;
    NSArray *_parameters;
}

+(id)typedefBlockWithName:(NSString *)name returnType: (NSString *) returnType parameters: (NSArray *) parameters;

@property (readonly) NSString *nameOfBlock;
@property (readonly) NSString *returnType;
@property (readonly) NSArray *parameters;

@property (readonly) NSString *htmlParameterList;

@end
