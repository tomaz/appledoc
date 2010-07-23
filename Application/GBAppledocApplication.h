//
//  GBAppledocApplication.h
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCliApplication.h"

/** The appledoc application handler. 
 
 This is the principal tool class. It represents the entry point for the application. The main promises of the class
 are parsing and validating of command line arguments and initiating document extraction.
 */
@interface GBAppledocApplication : NSObject <DDCliApplicationDelegate>

@end
