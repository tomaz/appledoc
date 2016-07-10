//
//  Created by Tomaz Kragelj on 20.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

extension ObjectiveCParser {
	
	func withPath(_ path: PathInfo) -> Self {
		self.path = path
		return self
	}
	func withPath(_ filename: String, example: String) -> Self {
		self.path = Loader.path(filename, example: example)
		return self
	}
	
	func withSettings(_ settings: Settings) -> Self {
		self.settings = settings
		return self
	}
	
	func withStore(_ store: Store) -> Self {
		self.store = store
		return self
	}
	
}
