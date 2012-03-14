//
//  Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class Settings;

/** Main appledoc class.
 
 To use it, instantiate it, pass it desired settings stack and invoke run method!
 */
@interface Appledoc : NSObject

@property (nonatomic, strong) Settings *settings;

@end
