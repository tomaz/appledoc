//
//  DoxygenConverter+CleanHTML.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoxygenConverter.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Implements clean HTML documentation related functionality for @c DoxygenConverter 
class.

￼￼This category handles conversion from clean XML files to clean HTML. It's members 
create clean HTML object and index files, and saves them in the proper directory 
structure.
*/
@interface DoxygenConverter (CleanHTML)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Clean HTML handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates cleaned XHTML documentation￼.

This method will convert all clean XML markups in the database to XHTML files in the
proper output directory.
 
This message is automatically sent from @c DoxygenConverter::convert() in the proper order.

@exception ￼￼￼￼￼NSException Thrown if creation fails.
*/
- (void) createCleanXHTMLDocumentation;

@end
