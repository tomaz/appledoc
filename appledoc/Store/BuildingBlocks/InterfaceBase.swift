//
//  Created by Tomaz Kragelj on 20.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Base class for interfaces - classes, categories, protocols.
*/
class InterfaceBase {
	
	/// Name of the object.
	lazy var name = ""
	
	/// The range of the interface in the source file.
	lazy var range = SourceRangeInfo()

	/// Array of method groups in the order registered.
	lazy var methodGroups = [MethodGroupInfo]()
	
	/// Array of all methods in the order registered.
	lazy var methods = [MethodInfo]()
	
}
