//
//  GeneratorBase+IndexSubclassAPI.m
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "GeneratorBase+IndexSubclassAPI.h"
#import "DoxygenConverter.h"

@implementation GeneratorBase (IndexSubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark File header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexHeaderToData:(NSMutableData*) data
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexFooterToData:(NSMutableData*) data
{	
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Group handling
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupHeaderToData:(NSMutableData*) data
								 type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupFooterToData:(NSMutableData*) data
								 type:(int) type
{
}

//----------------------------------------------------------------------------------------
- (void) appendIndexGroupItemToData:(NSMutableData*) data
						   fromItem:(id) item
							  index:(int) index
							   type:(int) type
{
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
//////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------
- (NSString*) indexTitle
{
	NSString* project =
		(self.projectName != nil && [self.projectName length] > 0) ?
		self.projectName : @"Project";
	return [NSString stringWithFormat:@"%@ reference", project];
}

//----------------------------------------------------------------------------------------
- (NSXMLDocument*) indexMarkup
{
	return indexMarkup;
}

@end