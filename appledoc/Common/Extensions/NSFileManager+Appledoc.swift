//
//  Created by Tomaz Kragelj on 16.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

extension NSFileManager {

	/** Determines whether the given path exists and represents a directory.
	
	@param path Path to examine.
	@return Returns true if path exists and is directory, false otherwise.
	*/
	func isPathDirectory(path: String) -> Bool {
		var isDirectory = ObjCBool(false)
		
		if !fileExistsAtPath(path, isDirectory: &isDirectory) {
			return false
		}
		
		return isDirectory.boolValue
	}
	
}
