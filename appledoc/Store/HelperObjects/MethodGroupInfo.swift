//
//  Created by Tomaz Kragelj on 21.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Describes a method group.

Method group is, well, a group of methods, delimited by `@name` or `#pragma mark`.
*/
struct MethodGroupInfo {
	
	/// The name of the group.
	let name: String
	
	/// The range of the method group in the source file.
	var range = SourceRangeInfo()
	
	/// The array of methods in the order registered.
	var methods = [MethodInfo]()
	
}
