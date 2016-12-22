//
//  Created by Tomaz Kragelj on 11.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Command line parser.
*/
class CommandLineParser: GBCommandLineParser, Task {
	
	// MARK: - Overriden functions
	
	override func registerOptions(_ options: GBOptionsHelper!) {
		self.options = options as! Options
		super.registerOptions(options)
	}
	
	override func register(_ settings: GBSettings!) {
		self.settings = settings as! Settings
		super.register(settings)
	}
	
	// MARK: - Task
	
	/** Launches parsing tasks.
	
	Note that it's required to assign `settings` and `store` prior to calling this function!
	*/
	func run() throws {
		// Always print application version.
		options.printVersion()
		print("")
		
		// Parse command line. If anything fails, print help and exit.
		if !parseOptionsUsingDefaultArguments() {
			options.printHelp()
			throw Result.cancel
		}
		
		// Inject global and project settings; we can only do this after we've read the command line.
		settings.injectGlobalSettings()
		settings.injectProjectSettings()
		
		// Print out information as needed.
		printValuesIfNeeded()
		
		if printVersion() {
			throw Result.cancel
		}
		
		if printHelp() {
			throw Result.cancel
		}
		
		if printMissingArguments() {
			throw Result.cancel
		}
	}
	
	// MARK: - Helper functions
	
	fileprivate func printValuesIfNeeded() {
		// If values printout is instructed, do so, then continue.
		if settings.printValues {
			options.printValues(from: settings)
		}
	}
	
	fileprivate func printVersion() -> Bool {
		// If version printout is instructed, exit (we already printed it).
		if settings.printVersion {
			return true
		}
		return false
	}
	
	fileprivate func printHelp() -> Bool {
		// If help printout is instructed, do so and exit.
		if settings.printHelp {
			options.printHelp()
			return true
		}
		return false
	}
	
	fileprivate func printMissingArguments() -> Bool {
		// If there's no input path, print error exit.
		if arguments.count == 0 {
			print("At least one input path is required!\n")
			options.printHelp()
			return true
		}
		return false
	}
	
	// MARK: - Properties

	var options: Options!
	var settings: Settings!

}
