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
				
				it("registers class") {
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "simple interface")

					try! parser.run()

					expect(store.classes.count) == 1
					expect(store.classes[0].name) == "Name"
					expect(store.classes[0].adoptedProtocols.count) == 0
					expect(store.classes[0].categories.count) == 0
				}
				
				it("registers superclass") {
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "superclass")

					try! parser.run()

					expect(store.classes[0].superclass).toNot(beNil())
					expect(store.classes[0].superclass!.name) == "SuperClassName"
				}
				
				it("registers adopted protocols") {
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "adopted protocols")

					try! parser.run()

					expect(store.classes[0].adoptedProtocols.count) == 2
					expect(store.classes[0].adoptedProtocols[0].name) == "Protocol1"
					expect(store.classes[0].adoptedProtocols[1].name) == "Protocol2"
				}

				it("registers superclass with adopted protocols") {
					let store = Store()
					let parser = ObjectiveCParser().withStore(store).withPath("objectivec-class.md", example: "superclass with adopted protocols")

					try! parser.run()

					expect(store.classes[0].superclass!.name) == "SuperClassName"
					expect(store.classes[0].adoptedProtocols.count) == 2
					expect(store.classes[0].adoptedProtocols[0].name) == "Protocol1"
					expect(store.classes[0].adoptedProtocols[1].name) == "Protocol2"
				}
			}
		}
	}
	
}
