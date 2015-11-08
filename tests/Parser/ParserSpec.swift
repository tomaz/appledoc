//
//  Created by Tomaz Kragelj on 12.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Quick
import Nimble

class ParserSpec: QuickSpec {
	
	override func spec() {
		
		describe("properties") {
			
			context("objectiveCParser") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Parser()
					// Execute
					let parser = sut.objectiveCParser
					// Verify
					expect(parser).toNot(beNil())
				}
				
				it("should assign helper classes during creation") {
					// Setup
					let settings = Settings()
					let store = Store()
					let sut = Parser().withSettings(settings).withStore(store)
					// Execute
					let parser = sut.objectiveCParser
					// Verify
					expect(parser.settings) === settings
					expect(parser.store) === store
				}
			}
		}
		
	}
	
}
