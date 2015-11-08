//
//  Created by Tomaz Kragelj on 12.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

class FakeGenerator: Generator {
	
	// MARK: - run
	
	override func run() throws {
		runNumberOfCalls++
		
		if runSimulateFailure {
			throw Result.Cancel
		}
	}
	
	func runWithFailure(fail: Bool) -> Self {
		runSimulateFailure = fail
		return self
	}
	
	var runNumberOfCalls = 0
	var runSimulateFailure = false
	var runWasCalled: Bool {
		return runNumberOfCalls > 0
	}
		
}
