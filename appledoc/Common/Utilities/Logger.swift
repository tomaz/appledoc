//
//  Created by Tomaz Kragelj on 11.06.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

private let MarkerPrefix = "---------- "

enum LogVerbosity: Int {
	case None
	case Error
	case Warning
	case Info
	case Verbose
	case Debug
}

func >= (left: LogVerbosity, right: LogVerbosity) -> Bool {
	return left.rawValue >= right.rawValue
}

class Logger {

	static let sharedInstance = Logger()
	
	private init() {
		self.timestampFormatter = NSDateFormatter()
		self.timestampFormatter.dateFormat = "HH:mm:ss.SSS"
	}
	
	// MARK: - Initialization
	
	func initialize(settings: Settings) {
		var verbosity = LogVerbosity(rawValue: settings.loggingVerbosity)!
		
		if NSProcessInfo.processInfo().environment["TESTING"] != nil {
			verbosity = .None
		}
		
		if verbosity >= LogVerbosity.Error {
			Logger.error = LogChannel(name: "0")
		}
		
		if verbosity >= LogVerbosity.Warning {
			Logger.warning = LogChannel(name: "1")
		}
		
		if verbosity >= LogVerbosity.Info {
			Logger.info = LogChannel(name: "2")
		}
		
		if verbosity >= LogVerbosity.Verbose {
			Logger.verbose = LogChannel(name: "3")
		}
		
		if verbosity >= LogVerbosity.Debug {
			Logger.debug = LogChannel(name: "4")
		}
	}
	
	// MARK: - Properties
	
	private var timestampFormatter: NSDateFormatter

	// MARK: - Channels
	
	static var error: LogChannel?
	static var warning: LogChannel?
	static var info: LogChannel?
	static var verbose: LogChannel?
	static var debug: LogChannel?
}

class LogChannel {
	
	init(name: String) {
		self.name = name
	}
	
	func message(message: String, function: String, filename: String, line: Int) {
		let logger = Logger.sharedInstance
		let time = logger.timestampFormatter.stringFromDate(NSDate())
		let file = (filename as NSString).lastPathComponent
		print("\(time) [\(self.name)] \(message) | \(file):\(line)")
	}
	
	private var name: String
	
}

// MARK: - Logging functions

func gerror(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.error?.message(message(), function: function, filename: filename, line: line)
}

func gwarn(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.warning?.message(message(), function: function, filename: filename, line: line)
}

func ginfo(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.info?.message(message(), function: function, filename: filename, line: line)
}

func gverbose(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.verbose?.message(message(), function: function, filename: filename, line: line)
}

func gdebug(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.debug?.message(message(), function: function, filename: filename, line: line)
}

func gmarker(@autoclosure message: () -> String, function: String = __FUNCTION__, filename: String = __FILE__, line: Int = __LINE__) {
	Logger.debug?.message("\(MarkerPrefix)\(message())", function: function, filename: filename, line: line)
}
