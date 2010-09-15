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

+ (NSString *)codeWithClassAndCategory {
	return
	@"#import \"Header.h\"\n"
	@"\n"
	@"@implementation GBCalculator\n"
	@"\n"
	@"- (NSInteger)add:(NSInteger)value1 to:(NSInteger)value2 {\n"
	@"  if (!_cachedResult) { _cachedResult = @\"Ready\"; }\n"
	@"  return value1 + value2;\n"
	@"}\n"
	@"\n"
	@"@end\n"
	@"\n"
	@"@implementation GBCalculator (Multiplication)\n"
	@"\n"
	@"- (NSInteger)multiply:(NSInteger)value1 with:(NSInteger)value2 {\n"
	@"  return value1 * value2;\n"
	@"}\n"
	@"\n"
	@"@end\n"
	@"\n";
}

+ (NSString *)fullMethodComment {
	return
	// Short description.
	@"Short description.\n"
	@"\n"
	
	// Second paragraph with several empty lines to make sure empty paragraphs are not created.
	@"Second paragraph with lot's of text\n"
	@"split into two lines.\n"
	@"\n\n\n"
	
	// Two unordered list separated with an empty line.
	@"- Unordered item 1.\n"
	@"- Unordered item 2.\n"
	@"\n\n"
	@"- Second unordered list\n"
	
	// Ordered list (should work even if no empty line before unordered list!)
	@"1. Ordered item 1.\n"
	@"999. Ordered item 2.\n"
	@"\n"
	
	// Example with empty line and tabs.
	@"\tSource line 1\n"
	@"\t\n"
	@"\t\tSource line with tab\n"
	@"\n"
	
	// Second example without empty line before next paragraph.
	@"\tSecond example\n"
	
	// Third paragraph.
	@"Third paragraph.\n"
	
	// Warning and bug.
	@"@warning Warning\n"
	@"@bug Bug\n"
	
	// Parameters block, note there's no empty line before!
	@"@param name1 Description1\n"
	@"@param name2 Description2\n"
	@"@return Return\n"
	@"@exception exc1 Exception1\n"
	@"@exception exc2 Exception2\n"
	@"@see link1\n"
	@"@sa link2\n";
}

@end
