//
//  Created by Tomaz Kragelj on 11.06.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

enum LogVerbosity: Int {
	case none
	case error
	case warning
	case info
	case verbose
	case debug
}

func >= (left: LogVerbosity, right: LogVerbosity) -> Bool {
	return left.rawValue >= right.rawValue
}

class Logger {

	static let sharedInstance = Logger()
	
	fileprivate init() {
		self.timestampFormatter = DateFormatter()
		self.timestampFormatter.dateFormat = "HH:mm:ss.SSS"
	}
	
	// MARK: - Initialization
	
	func initialize(_ settings: Settings) {
		var verbosity = LogVerbosity(rawValue: settings.loggingVerbosity)!
		
		if ProcessInfo.processInfo.environment["TESTING"] != nil {
			verbosity = .none
		}
		
		if verbosity >= LogVerbosity.error {
			Logger.error = LogChannel(name: "0")
		}
		
		if verbosity >= LogVerbosity.warning {
			Logger.warning = LogChannel(name: "1")
		}
		
		if verbosity >= LogVerbosity.info {
			Logger.info = LogChannel(name: "2")
		}
		
		if verbosity >= LogVerbosity.verbose {
			Logger.verbose = LogChannel(name: "3")
		}
		
		if verbosity >= LogVerbosity.debug {
			Logger.debug = LogChannel(name: "4")
		}
	}
	
	// MARK: - Properties

	lazy var times = [Date]()
	fileprivate var timestampFormatter: DateFormatter

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
	
	func message(_ message: String, function: String, filename: String, line: Int) {
		let logger = Logger.sharedInstance
		let time = logger.timestampFormatter.string(from: Date())
		let file = (filename as NSString).lastPathComponent
		write("\(time) [\(self.name)] \(message) | \(file):\(line)")
	}
	
	func write(_ message: String) {
		print(message)
	}
	
	fileprivate var name: String
	
}

// MARK: - Logging functions

func gerror(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.error?.message(message(), function: function, filename: filename, line: line)
}

func gwarn(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.warning?.message(message(), function: function, filename: filename, line: line)
}

func ginfo(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.info?.message(message(), function: function, filename: filename, line: line)
}

func gverbose(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.verbose?.message(message(), function: function, filename: filename, line: line)
}

func gdebug(_ message: @autoclosure () -> String, function: String = #function, filename: String = #file, line: Int = #line) {
	Logger.debug?.message(message(), function: function, filename: filename, line: line)
}

// MARK: - "Higher level" logging functions

func gdelimit() {
	// Only logging on verbose...
	Logger.verbose?.write("")
}

func gtaskstart() {
	// Only logging on verbose...
	Logger.sharedInstance.times.append(Date())
	Logger.verbose?.write("")
	Logger.verbose?.write("============================================================")
}

func gtaskend() {
	// Only logging on verbose...
	let endTime = Date()
	if let startTime = Logger.sharedInstance.times.last {
		Logger.sharedInstance.times.removeLast()
		let difference = Int(endTime.timeIntervalSince(startTime) * 1000.0)
		Logger.verbose?.write("> \(difference)ms")
	}
}
