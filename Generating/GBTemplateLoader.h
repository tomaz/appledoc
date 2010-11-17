//
//  GBTemplateLoader.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Loads a template file and prepares it for output generation.
 
 The main responsibilities of this class are loading template from file to string, scanning for all template subsections and extracting them to internal dictionary. Finally, it prepares clean template file, without all template subsections. Note that processed template can be reused - it's enough to process a single template file once and then reuse the `GBTemplateLoader` instance for all cases where the given template is needed.
 */
@interface GBTemplateLoader : NSObject {
@private
    
}

@end
