//
//  GBTypedefBlockArgument.h
//  appledoc
//
//  Created by Teichmann, Bjoern on 23.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@interface GBTypedefBlockArgument : GBModelBase
{
    @private
    NSString *_argumentClass;
    NSString *_argumentName;
}

+ (id)typedefBlockArgumentWithName:(NSString *)name className:(NSString *) className;

@property (readonly) NSString *name;

@property (readonly) NSString *className;

@property (readonly) NSString *href;

@end
