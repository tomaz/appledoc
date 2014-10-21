/*

Created by Tomaz Kragelj on 20.10.2014.
Copyright (c) 2014 Gentle Bytes. All rights reserved.

*/

import Foundation

func run() {
	let settings = Settings()
	let options = Options()
	let commandLineParser = GBCommandLineParser()

	// Register options and settings to parser to allow simple parsing.
	commandLineParser.registerOptions(options)
	commandLineParser.registerSettings(settings)

	// Print version.
	options.printVersion()
	println()

	// Parse options.
	if !commandLineParser.parseOptionsUsingDefaultArguments() {
		options.printHelp()
		return
	}
	
	// Print version and exit if needed.
	if settings.printVersion {
		return
	}
	
	// Print help and exit if needed.
	if settings.printHelp {
		options.printHelp()
		return
	}
	
	// Proceed with application.
}

run()

