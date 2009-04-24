//
//  DoxygenConverter+Helpers.m
//  objcdoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import "DoxygenConverter+Helpers.h"

@implementation DoxygenConverter (Helpers)

//----------------------------------------------------------------------------------------
- (id) applyXSLTFromFile:(NSString*) filename 
			  toDocument:(NSXMLDocument*) document 
				   error:(NSError**) error
{
	return [self applyXSLTFromFile:filename toDocument:document arguments:nil error:error];
}

//----------------------------------------------------------------------------------------
- (id) applyXSLTFromFile:(NSString*) filename 
			  toDocument:(NSXMLDocument*) document 
			   arguments:(NSDictionary*) arguments
				   error:(NSError**) error
{
	NSString* xsltString = [NSString stringWithContentsOfFile:filename 
													 encoding:NSASCIIStringEncoding 
														error:error];
	if (xsltString)
	{
		return [document objectByApplyingXSLTString:xsltString 
										  arguments:arguments
											  error:error];
	}
	
	return nil;
}

@end
