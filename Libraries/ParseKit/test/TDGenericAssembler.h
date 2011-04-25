//
//  PKGenericAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/22/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKAssembly;

@interface TDGenericAssembler : NSObject {
    NSMutableDictionary *attributes;
    NSMutableDictionary *defaultProperties;
    NSMutableDictionary *productionNames;
    PKAssembly *currentAssembly;
    NSString *prefix;
    NSString *suffix;
}
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, retain) NSMutableDictionary *defaultProperties;
@property (nonatomic, retain) NSMutableDictionary *productionNames;
@property (nonatomic, retain) PKAssembly *currentAssembly;
@end
