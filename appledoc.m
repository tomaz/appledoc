//
//  appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <objc/objc-auto.h>
#import "DDCommandLineInterface.h"
#import "GBAppledocApplication.h"

int main(int argc, const char *argv[]) {
	return DDCliAppRunWithClass([GBAppledocApplication class]);
}
