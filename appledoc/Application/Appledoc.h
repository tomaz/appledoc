//
//  Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class CommandLineArgumentsParser;

/** Main appledoc class.
 
 To use it, instantiate it, pass it command line arguments (this will also setup factory defaults, global and project settings). Once ready, run the tool to do its job.
 */
@interface Appledoc : NSObject

- (void)setupSettingsFromCmdLineArgs:(char **)argv count:(int)argc;

@property (nonatomic, strong) CommandLineArgumentsParser *commandLineParser;

@end
