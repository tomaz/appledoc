//
//  Created by Tomaz Kragelj on 16.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Helper class for unifiying access to user presentable and full path.

The class takes user presentable path and automatically converts it to full path useable by various components. Because full path is lazily prepared on first use, it's efficient and reusable representation.

**Note:** it's nice UX to present them with paths they give. If they use relative path, or tilde, it's nicer to use that while logging. However internal methods need to operate on full paths. This class wraps that conversion while making sure any given path is only converted once.

**Implementation detail:** The class is immutable; once it gets the path, it's no longer possible to change it. Being short little implementation, it's good candidate for being implemented as struct. However, I chose class because the same path info can be shared amongst multiple methods and classes. It feels like wasting precious CPU cycles if it needed to be copied every time it gets passed over. Besides, it's immutable, so there's no fear of some component messing it up for everybody.
*/
class PathInfo: CustomStringConvertible {
	
	init(path: String) {
		self.path = path
	}
	
	// MARK: - CustomStringConvertible
	
	var description: String {
		return path
	}
	
	// MARK: - Properties
	
	/// User friendly path description.
	let path: String
	
	/// Full path representation of given `path`.
	lazy fileprivate(set) internal var fullPath: String = {
		return self.path.stringByStandardizingPath
	}()
}

