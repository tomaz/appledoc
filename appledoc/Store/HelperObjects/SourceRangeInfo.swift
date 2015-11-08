//
//  Created by Tomaz Kragelj on 21.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Describes the range of an object in a source file.
*/
class SourceRangeInfo {
	
	/// Starting location of the range.
	lazy var start = SourceInfo(filename: "", line: 0, column: 0)
	
	/// Ending location of the range.
	lazy var end = SourceInfo(filename: "", line: 0, column: 0)
	
}
