//
//  Created by Tomaz Kragelj on 11.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Holds parsed and processed model objects and handles registation.
*/
class Store {

	/// Array of all classes.
	lazy var classes = [ClassInfo]()
	
	/// Array of all categories.
	lazy var categories = [CategoryInfo]()
	
	/// Array of all protocols.
	lazy var protocols = [ProtocolInfo]()
	
}
