//
//  Created by Tomaz Kragelj on 11.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Processes all files in assigned `Store` and prepares it for generation phase.
*/
class Processor: Task {
	
	// MARK: - Task
	
	/** Launches post processing of assigned `store` data.
	
	Note that it's required to assign `settings` and `store` prior to calling this function!
	*/
	func run() throws {
		gtaskstart()
		ginfo("Processing")
		gtaskend()
	}
	
	// MARK: - Properties
	
	/// Application settings. This must be assigned prior to using the object!
	var settings: Settings!
	
	/// Application objects store. This must be assigned prior to using the object!
	var store: Store!
	
}
