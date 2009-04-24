//
//  DoxygenConverter+Helpers.h
//  objcdoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoxygenConverter.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines common helper methods for @c DoxygenConverter and it's helper categories

￼￼This category defines several lower level methods which are used through other conversion
methods implemented in the main converter class or it's main categories. The main reason
for implementing these in a separate file instead of in private category is in the fact
that we need to link to these methods in other categories besides the main class.
*/
@interface DoxygenConverter (Helpers)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Applies the XSLT from the given file to the document and returns the resulting object.￼

This will first load the XSLT from the given file and will apply it to the document. It
will return the transformed object which is either an @c NSXMLDocument if transformation
created an XML or @c NSData otherwise. If transformation failed, @c nil is returned and
error description is passed over the @c error parameter.
 
This message internally sends @c applyXSLTFromFile:toDocument:arguments:error() with
arguments set to @c nil.

@param filename ￼￼￼￼￼￼The name of the XSLT file including full path.
@param document ￼￼￼￼￼￼The @c NSXMLDocument to transform.
@param error ￼￼￼￼￼￼If transformation failed, error is reported here.
@return ￼￼￼￼Returns transformed object or @c nil if transformation failed.
*/
- (id) applyXSLTFromFile:(NSString*) filename 
			  toDocument:(NSXMLDocument*) document 
				   error:(NSError**) error;

/** Applies the XSLT from the given file to the document and returns the resulting object.￼

This will first load the XSLT from the given file and will apply it to the document. It
will return the transformed object which is either an @c NSXMLDocument if transformation
created an XML or @c NSData otherwise. If transformation failed, @c nil is returned and
error description is passed over the @c error parameter.

@param filename ￼￼￼￼￼￼The name of the XSLT file including full path.
@param document ￼￼￼￼￼￼The @c NSXMLDocument to transform.
@param arguments An @c NSDictionary containing all arguments to be passed to the XSLT.
	May be @c nil if no argument is to be passed.
@param error ￼￼￼￼￼￼If transformation failed, error is reported here.
@return ￼￼￼￼Returns transformed object or @c nil if transformation failed.
*/
- (id) applyXSLTFromFile:(NSString*) filename 
			  toDocument:(NSXMLDocument*) document 
			   arguments:(NSDictionary*) arguments
				   error:(NSError**) error;

@end
