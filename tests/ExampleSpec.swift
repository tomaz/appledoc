//
//  Created by Tomaz Kragelj on 8.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Quick
import Nimble

class ExampleSpec: QuickSpec {

	override func spec() {
	
		describe("example test") {
			
			context("with some arguments") {
				
				it("should equal 1 to 1") {
					expect(1) == 1
				}
				
				it("should not equal 1 to 2") {
					expect(1) != 2
				}
			}
		}
		
	}
	
}
