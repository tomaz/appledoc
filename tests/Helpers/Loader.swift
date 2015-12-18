//
//  Created by Tomaz Kragelj on 20.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

// NOTE: all functions in this class require that files/sections asked for actually exist. Functions will fail otherwise - that's programmers error

class Loader {
	
	class func path(filename: String, example: String) -> PathInfo {
		// Get the path to the file.
		let fullPath = pathString(filename)
		
		// Load the file into string.
		let contents = try! String(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding)
		
		/// Search for the header.
		let headerName = "### \(example)"
		let headerRange = contents.rangeOfString(headerName)!
		
		// Search for next header or end of file.
		let exampleEndIndex: Int
		let headerEndLocation = contents.startIndex.distanceTo(headerRange.endIndex)
		let searchRange = NSMakeRange(headerEndLocation, contents.characters.count - headerEndLocation)
		if let match = headerRegex.firstMatchInString(contents, options: NSMatchingOptions(rawValue: 0), range: searchRange) {
			exampleEndIndex = match.range.location
		} else {
			exampleEndIndex = contents.characters.count
		}
		
		// Extract example string.
		let exampleRange = Range<String.Index>(start: headerRange.endIndex, end: contents.startIndex.advancedBy(exampleEndIndex))
		let value = contents.substringWithRange(exampleRange)
		
		// Prepare temporary path and save the example there.
		let tempPath = NSTemporaryDirectory().stringByAppendingPathComponent("\(NSUUID().UUIDString).m")
		try! value.writeToFile(tempPath, atomically: true, encoding: NSUTF8StringEncoding)
		
		return PathInfo(path: tempPath)
	}
	
	class func path(filename: String) -> PathInfo {
		let path = pathString(filename)
		return PathInfo(path: path)
	}
	
	private class func pathString(filename: String) -> String {
		return NSBundle(forClass: Loader.self).pathForResource(filename.stringByDeletingPathExtension, ofType: filename.pathExtension)!
	}
	
	private static var headerRegex = {
		return try! NSRegularExpression(pattern: "^###.+$\\n?", options: NSRegularExpressionOptions.AnchorsMatchLines)
	}()
	
}
