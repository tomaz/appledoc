//
//  GBRealLifeDataProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBRealLifeDataProvider : NSObject

+ (NSString *)headerWithClassCategoryAndProtocol;
+ (NSString *)codeWithClassAndCategory;
+ (NSString *)trickyMethodComment;

@end
