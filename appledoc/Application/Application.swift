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
		// Hande all top-level tasks.
		do {
			try initializeApplication()
			ginfo("Started")
			try parser.run()
			try processor.run()
			try generator.run()
			gdelimit()
			ginfo("Completed")
		} catch {
			ginfo("Cancelled")
			return
		}
	}
	
	fileprivate func initializeApplication() throws {
		// Parse command line. Bail out in case of errors
		try commandLineParser.run()
		
		// Initialize logger.
		Logger.sharedInstance.initialize(settings)
	}
	
	// MARK: - Properties
	
	/// The command line parser. Lazy instantates to default instance, but you can assign a different object at any point.
	lazy var commandLineParser: CommandLineParser = {
		let result = CommandLineParser()
		result.registerOptions(self.options)
		result.register(self.settings)
		return result
	}()
	
	/// Source files parser. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var parser: Parser = {
		let result = Parser()
		result.settings = self.settings
		result.store = self.store
		return result
	}()
	
	/// Post processor of parsed data. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var processor: Processor = {
		let result = Processor()
		result.settings = self.settings
		result.store = self.store
		return result
	}()
	
	/// Generator entry point for output. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var generator: Generator = {
		let result = Generator()
		result.settings = self.settings
		result.store = self.store
		return result
	}()
	
	/// Parsed and processed objects store. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var store = Store()
	
	/// The options class that defines setting groups for help and values printout. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var options = Options()
	
	/// The settings instance that stores current session values to the application. Lazy instantiates to default instance, but you can assign a different object prior to first use.
	lazy var settings = Settings()
	
}
