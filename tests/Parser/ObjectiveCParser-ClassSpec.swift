//
//  Created by Tomaz Kragelj on 12.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Quick
import Nimble

class ObjectiveCParserClassSpec: QuickSpec {
	
	override func spec() {
		
		describe("run") {
			
			context("classes") {
				
				it("should register class") {
					// setup
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "simple interface")
					// execute
					try! parser.run()
					// verify
//					expect(store.classes.count) == 1
//					expect(store.classes[0].name) == "Name"
//					expect(store.classes[0].adoptedProtocols.count) == 0
//					expect(store.classes[0].categories.count) == 0
				}
				
				it("should register superclass") {
					// setup
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "superclass")
					// execute
					try! parser.run()
					// verify
//					expect(store.classes[0].superclass).toNot(beNil())
//					expect(store.classes[9].superclass!.name) == "SuperClassName"
				}
				
				it("should register adopted protocols") {
					// setup
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "adopted protocols")
					// execute
					try! parser.run()
					// verify
//					expect(store.classes[0].adoptedProtocols.count) == 2
//					expect(store.classes[0].adoptedProtocols[0].name) == "Protocol1"
//					expect(store.classes[0].adoptedProtocols[1].name) == "Protocol2"
				}
			}
		}
	}
	
}
