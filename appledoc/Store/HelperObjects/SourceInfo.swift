//
//  Created by Tomaz Kragelj on 17.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Describes the location of an object in its source file.
*/
class SourceInfo: CustomStringConvertible {
	
	init(filename: String, line: Int, column: Int) {
		self.filename = filename
		self.line = line
		self.column = column
	}
	
	// MARK: - CustomStringConvertible
	
	var description: String {
		return "\(filename.lastPathComponent)[\(line):\(column)]"
	}
	
	// MARK: - Derived properties
	
	/// Determines if this source info has some information about source or not.
	var empty: Bool {
		return filename.characters.count == 0
	}
	
	// MARK: - Properties
	
	/// Full path and filename.
	fileprivate(set) internal var filename: String
	
	/// Line number within the file.
	fileprivate(set) internal var line: Int
	
	/// Column number within the line.
	fileprivate(set) internal var column: Int
}
