//
//  NSString+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@interface NSString (Appledoc)

+ (NSString *)gb_format:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (NSUInteger)gb_defaultDescriptionLength;
- (NSString *)gb_description;
- (NSString *)gb_descriptionWithLength:(NSUInteger)length;
- (NSString *)gb_stringByStandardizingCurrentDir;
- (NSString *)gb_stringByStandardizingCurrentDirAndPath;
- (NSString *)gb_stringByReplacingWhitespaceWithSpaces;
- (NSString *)gb_stringByReplacing:(NSDictionary *)info;
- (NSString *)gb_stringByTrimmingNewLines;
- (NSString *)gb_stringByTrimmingWhitespaceAndNewLine;
- (NSUInteger)gb_indexOfString:(NSString *)string;
- (NSRange)gb_range;
- (BOOL)gb_contains:(NSString *)string;
- (BOOL)gb_stringContainsOnlyWhitespace;
- (BOOL)gb_stringContainsOnlyCharactersFromSet:(NSCharacterSet *)set;

@end
