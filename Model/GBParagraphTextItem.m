//
//  GBParagraphTextItem.m
//  appledoc
//
//  Created by Tomaz Kragelj on 31.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphTextItem.h"

@implementation GBParagraphTextItem

- (NSString *)description {
	return [NSString stringWithFormat:@"Text '%@'", [super description]];
}

- (BOOL)isTextItem {
	return YES;
}

@end
