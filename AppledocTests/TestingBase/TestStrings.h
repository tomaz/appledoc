//
//  TestStrings.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@interface TestStrings : NSObject

+ (NSDictionary *)dictionaryFromResourceFile:(NSString *)file;
+ (NSString *)stringFromResourceFile:(NSString *)file;

@end
