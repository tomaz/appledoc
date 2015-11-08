//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Application's options descriptions.

This class defines all descriptions for help and values output. As well as provide option keys to `GBCommandLineParser`. It's a higher level class that combines both, `GBCommandLineParser` and `Settings` as well as helper methods for printing out help and debug values.
*/
class Options: GBOptionsHelper {
	
	override init() {
		super.init()
		
		// TODO: change this so it uses dynamically generated values from git - https://trello.com/c/UZ3MHcMB
		applicationVersion = { ApplicationInfoProvider.sharedInstance.version }
		applicationBuild = { ApplicationInfoProvider.sharedInstance.build }
		printHelpHeader = { "Usage: %APPNAME [OPTIONS] <input paths>" }

		register()
	}
	
}

// MARK: - Options registrations

extension Options {

	private func register() {
		// Registers all settings for command line parser - this is where
		SwiftyOptions.sharedInstance.register(self) {
			section("OPTIONS") {
				option(nil, long: settingsGeneralValuesKey, description: "Print option values and sources")
				option(nil, long: settingsGeneralVersionKey, description: "Print version and exit")
				option(nil, long: settingsGeneralPrintHelpKey, description: "Print this help and exit")
				option(nil, long: settingsGeneralLoggingVerbosityKey, description: "Logging verbosity [0-5]", flags: .RequiredValue)
			}
		}
	}
	
}
