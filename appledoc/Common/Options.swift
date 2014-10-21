/*
 
Created by Tomaz Kragelj on 20.10.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

import Cocoa

class Options: GBOptionsHelper {
	override init() {
		super.init();
		
		self.applicationVersion = { GAppledocVersion }
		self.applicationBuild = { "\(GAppledocBuildNumber)" }
		self.printHelpHeader = { "Usage: %APPNAME [OPTIONS] <input paths>" }
		
		self.registerSeparator("OPTIONS")
		self.registerOption(0, long: GSettingsPrintVersionKey, description: "Print version and exit", flags: GBOptionFlags.NoValue)
		self.registerOption(0, long: GSettingsPrintHelpKey, description: "Print this help and exit", flags: GBOptionFlags.NoValue)
	}
}
