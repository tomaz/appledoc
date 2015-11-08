//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Defines all command line settings.

The main responsibility of this class is to define and provide settings values from command line (and other sources such as global and project settings files) to the rest of the application.
*/
class Settings: GBSettings {
	
	override init() {
		Settings.factoryDefaults.initializeFactoryDefaults()
		super.init(name: "Settings", parent: Settings.projectDefaults)
	}
	
	override init!(name: String!, parent: GBSettings!) {
		super.init(name: name, parent: parent)
	}
	
	// MARK: - Helper functions
	
	func injectGlobalSettings() {
		// TODO: Attempt to load from root of --templates option.
		
		// Attempt to load from ~/Library/Application Support/appledoc/appledoc.plist
		if let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first {
			let appledocSupportPath = applicationSupportPath.stringByAppendingPathComponent("Appledoc")
			let path = Settings.settingsFileNameForPath(appledocSupportPath)
			if Settings.globalDefaults.loadSettingsFromFile(path) {
				gdebug("Using global setings at \(path)")
				return
			}
		}
		
		// Attempt to load from ~/.appledoc.plist
		let userRootPath = Settings.settingsFileNameForPath("~/")
		if Settings.globalDefaults.loadSettingsFromFile(userRootPath) {
			gdebug("Using global settings at \(userRootPath)")
			return
		}
	}
	
	func injectProjectSettings() {
		// See if any of supplied input paths contains project settings and use the first one, in the given order.
		for path in self.arguments {
			let inputPath = path as! String
			let settingsPath = Settings.settingsFileNameForPath(inputPath)
			if Settings.projectDefaults.loadSettingsFromFile(settingsPath) {
				gdebug("Using project settings at \(settingsPath)")
				return
			}
		}
	}
	
}

// MARK: - Factory defaults

extension Settings {
	
	private func initializeFactoryDefaults() {
		loggingVerbosity = 3 // Use info logging verbosity by default
	}
	
	private static let factoryDefaults = Settings(name: "Factory Defaults", parent: nil)
	
}

// MARK: - Global and project settings.

extension Settings {
	
	private func loadSettingsFromFile(path: String) -> Bool {
		// This function is just convenience wrapper over loadSettingsFromPlist - it converts try/catch into Bool result (we don't really care why loading failed outside the function, just interested if it succedded or not).
		let standardizedPath = path.stringByStandardizingPath
		
		// Load settings from given file.
		do {
			try loadSettingsFromPlist(standardizedPath)
			return true
		} catch {
			gwarn("Failed loading settings from \(path)!")
		}
		
		return false
	}
	
	private class func settingsFileNameForPath(path: String) -> String {
		return path.stringByAppendingPathComponent("appledoc.plist")
	}
	
	private static let globalDefaults = Settings(name: "Global Defaults", parent: Settings.factoryDefaults)
	private static let projectDefaults = Settings(name: "Project Defaults", parent: Settings.globalDefaults)

}

// MARK: - General settings

extension Settings {
	
	var loggingVerbosity: Int {
		get { return integerForKey(settingsGeneralLoggingVerbosityKey) }
		set { setInteger(newValue, forKey: settingsGeneralLoggingVerbosityKey) }
	}
	
	var printValues: Bool {
		get { return boolForKey(settingsGeneralValuesKey) }
		set { setBool(newValue, forKey: settingsGeneralValuesKey) }
	}
	
	var printVersion: Bool {
		get { return boolForKey(settingsGeneralVersionKey) }
		set { setBool(newValue, forKey: settingsGeneralVersionKey) }
	}
	
	var printHelp: Bool {
		get { return boolForKey(settingsGeneralPrintHelpKey) }
		set { setBool(newValue, forKey: settingsGeneralPrintHelpKey) }
	}
	
}

let settingsGeneralLoggingVerbosityKey = "verbose"
let settingsGeneralValuesKey = "values"
let settingsGeneralVersionKey = "version"
let settingsGeneralPrintHelpKey = "help"
