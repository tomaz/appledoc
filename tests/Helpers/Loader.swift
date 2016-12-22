//
//  Created by Tomaz Kragelj on 20.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

// NOTE: all functions in this class require that files/sections asked for actually exist. Functions will fail otherwise - that's programmers error

class Loader {
	
	class func path(_ filename: String, example: String) -> PathInfo {
		// Get the path to the file.
		let fullPath = pathString(filename)
		
		// Load the file into string.
		let contents = try! String(contentsOfFile: fullPath, encoding: String.Encoding.utf8)
		
		/// Search for the header.
		let headerName = "### \(example)"
		let headerRange = contents.range(of: headerName)!
		
		// Search for next header or end of file.
		let exampleEndIndex: Int
		let headerEndLocation = contents.characters.distance(from: contents.startIndex, to: headerRange.upperBound)
		let searchRange = NSMakeRange(headerEndLocation, contents.characters.count - headerEndLocation)
		if let match = headerRegex.firstMatch(in: contents, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: searchRange) {
			exampleEndIndex = match.range.location
		} else {
			exampleEndIndex = contents.characters.count
		}
		
		// Extract example string.
		let exampleRange = (headerRange.upperBound ..< contents.characters.index(contents.startIndex, offsetBy: exampleEndIndex))
		let value = contents.substring(with: exampleRange)
		
		// Prepare temporary path and save the example there.
		let tempPath = NSTemporaryDirectory().stringByAppendingPathComponent("\(UUID().uuidString).m")
		try! value.write(toFile: tempPath, atomically: true, encoding: String.Encoding.utf8)
		
		return PathInfo(path: tempPath)
	}
	
	class func path(_ filename: String) -> PathInfo {
		let path = pathString(filename)
		return PathInfo(path: path)
	}
	
	fileprivate class func pathString(_ filename: String) -> String {
		return Bundle(for: Loader.self).path(forResource: filename.stringByDeletingPathExtension, ofType: filename.pathExtension)!
	}
	
	fileprivate static var headerRegex = {
		return try! NSRegularExpression(pattern: "^###.+$\\n?", options: NSRegularExpression.Options.anchorsMatchLines)
	}()
	
}
