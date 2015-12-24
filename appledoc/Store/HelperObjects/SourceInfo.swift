//
//  Created by Tomaz Kragelj on 17.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Describes the location of an object in its source file.
*/
struct SourceInfo {
	
	// MARK: - Derived properties
	
	/// Determines if this source info has some information about source or not.
	var empty: Bool {
		return filename.characters.count == 0
	}
	
	// MARK: - Properties
	
	/// Full path and filename.
	let filename: String
	
	/// Line number within the file.
	let line: Int
	
	/// Column number within the line.
	let column: Int
}

extension SourceInfo: CustomStringConvertible {
	
	var description: String {
		return "\(filename.lastPathComponent)[\(line):\(column)]"
	}
}