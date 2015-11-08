//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Main application entry point.

This is the principal class. It launches the application using current command line arguments and invokes all required tasks.
*/
class Application {
	
	// MARK: - Launching application
	
	/** Launches the application and invokes all necessary tasks.
	*/
	func run() {
		if !parseCommandLine() {
			return
		}
	}
	
	// MARK: - Properties
	
	/// The command line parser. Lazy instantates to default instance, but you can assign a different instance at any point.
	lazy var commandLineParser: GBCommandLineParser = {
		let result = GBCommandLineParser()
		result.registerOptions(self.options)
		result.registerSettings(self.settings)
		return result
	}()
	
	/// The options class that defines setting groups for help and values printout. Lazy instantiates to default instance, but you can assign a different instance prior to first use.
	lazy var options = Options()
	
	/// The settings instance that stores current session values to the application. Lazy instantiates to default instance, but you can assign a different instance prior to first use.
	lazy var settings = Settings()
	
}

// MARK: - Command line parsing and handling

extension Application {
	
	private func parseCommandLine() -> Bool {
		// Always print application version.
		options.printVersion()
		print("")
		
		// Parse command line. If anything fails, print help and exit.
		if !commandLineParser.parseOptionsUsingDefaultArguments() {
			options.printHelp()
			return false
		}
		
		// Inject global and project settings; we can only do this after we've read the command line.
		settings.injectGlobalSettings()
		settings.injectProjectSettings()

		// Print out information as needed.
		printValuesIfNeeded()
		if printVersion() { return false }
		if printHelp() { return false }
		if printMissingArguments() { return false }
		
		// Initialize logger.
		Logger.sharedInstance.initialize(settings)
		ginfo("Started")
		return true
	}
	
	private func printValuesIfNeeded() {
		// If values printout is instructed, do so, then continue.
		if settings.printValues {
			options.printValuesFromSettings(settings)
		}
	}
	
	private func printVersion() -> Bool {
		// If version printout is instructed, exit (we already printed it).
		if settings.printVersion {
			return true
		}
		return false
	}
	
	private func printHelp() -> Bool {
		// If help printout is instructed, do so and exit.
		if settings.printHelp {
			options.printHelp()
			return true
		}
		return false
	}
	
	private func printMissingArguments() -> Bool {
		// If there's no input path, print error exit.
		if commandLineParser.arguments.count == 0 {
			print("At least one input path is required!\n")
			options.printHelp()
			return true
		}
		return false
	}
	
}
