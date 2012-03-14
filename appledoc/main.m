//
//  main.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "Appledoc.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		Appledoc *appledoc = [[Appledoc alloc] init];
		[appledoc setupSettingsFromCmdLineArgs:argv count:argc];
	}
    return 0;
}
