/*

Created by Tomaz Kragelj on 20.10.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

import Cocoa

class Settings: GBSettings {
	
	override init() {
		let factoryDefaults = Settings.initializeFactoryDefaults()
		
		super.init(name: "Command Line", parent: factoryDefaults)
	}
	
	private init(name: String, parent: Settings?) {
		super.init(name: name, parent: parent)
	}
	
	// MARK: - Initialization
	
	private class func initializeFactoryDefaults() -> Settings {
		let result = Settings(name: "Factory Defaults", parent: nil)
		result.printVersion = false
		result.printHelp = false
		return result
	}

	// MARK: - Application settings
	
	var printVersion: Bool {
		get { return self.boolForKey(GSettingsPrintVersionKey) }
		set { self.setBool(newValue, forKey: GSettingsPrintVersionKey) }
	}
	
	var printHelp: Bool {
		get { return self.boolForKey(GSettingsPrintHelpKey) }
		set { self.setBool(newValue, forKey: GSettingsPrintHelpKey) }
	}
}

// MARK: - 

let GSettingsPrintVersionKey = "version"
let GSettingsPrintHelpKey = "help"
