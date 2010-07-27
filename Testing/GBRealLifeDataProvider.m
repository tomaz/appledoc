//
//  GBRealLifeDataProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBRealLifeDataProvider.h"

@implementation GBRealLifeDataProvider

+ (NSString *)headerWithClassCategoryAndProtocol {
	return 
	@"#import <Foundation/Foundation.h>\n"
	@"\n"
	@"@class DeclaredClass;\n"
	@"@protocol DeclaredProtocol;\n"
	@"\n"
	@"@interface GBCalculator : NSObject {\n"
	@"	NSString *_cachedResult;\n"
	@"}\n"
	@"\n"
	@"- (NSInteger)add:(NSInteger)value1 to:(NSInteger)value2;\n"
	@"- (NSInteger)subtract:(NSInteger)value1 from:(NSInteger)value2;\n"
	@"@property (readonly) NSInteger cachedResult;\n"
	@"\n"
	@"@end"
	@"\n"
	@"@interface GBCalculator (Multiplication)\n"
	@"- (NSInteger)multiply:(NSInteger)value1 with:(NSInteger)value2;\n"
	@"@end\n"
	@"\n"
	@"@interface GBCalculator ()\n"
	@"- (NSInteger)setCachedResult:(NSInteger)value;\n"
	@"@end\n"
	@"\n"
	@"@protocol GBObserving\n"
	@"- (void)observeCachedData;\n"
	@"@end\n"
	@"\n";
}

@end
