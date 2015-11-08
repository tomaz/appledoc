//
//  Created by Tomaz Kragelj on 12.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Quick
import Nimble

// NOTE: This class serves as example for creating unit tests. Because of this, most unit tests coverage is way too detailed and cover cases which would otherwise not be necessary. While the class is principal application entry point, it probably doesn't require unit tests (at least not this detailed) - any regression here would be noticed very easily.

class ApplicationSpec: QuickSpec {
	
	override func spec() {
		
		describe("run") {
			
			context("command line parsing") {
				
				it("should launch command line parser") {
					// Setup
					let commandLineParser = FakeCommandLineParser()
					let sut = Application().withCommandLineParser(commandLineParser)
					// Execute
					sut.run()
					// Verify
					expect(commandLineParser.runWasCalled) == true
				}
			}
			
			context("parsing") {
				
				it("should launch parser") {
					// Setup
					let parser = FakeParser()
					let sut = Application().withFakeCommandLineParser().withParser(parser)
					// Execute
					sut.run()
					// Verify
					expect(parser.runWasCalled) == true
				}
				
				it("should not launch parser if command line parser fails") {
					// Setup
					let parser = FakeParser()
					let commandLineParser = FakeCommandLineParser().runWithFailure(true)
					let sut = Application().withCommandLineParser(commandLineParser).withParser(parser)
					// Execute
					sut.run()
					// Verify
					expect(parser.runWasCalled) == false
				}
			}
			
			context("processing") {
				
				it("should launch processor") {
					// Setup
					let processor = FakeProcessor()
					let sut = Application().withFakeCommandLineParser().withFakeParser().withProcessor(processor)
					// Execute
					sut.run()
					// Verify
					expect(processor.runWasCalled) == true
				}
				
				context("previous steps fail") {
					
					it("should not launch processor if command line parser fails") {
						// Setup
						let processor = FakeProcessor()
						let commandLineParser = FakeCommandLineParser().runWithFailure(true)
						let sut = Application().withCommandLineParser(commandLineParser).withFakeParser().withProcessor(processor)
						// Execute
						sut.run()
						// Verify
						expect(processor.runWasCalled) == false
					}
					
					it("should not launch processor if parser fails") {
						// Setup
						let processor = FakeProcessor()
						let parser = FakeParser().runWithFailure(true)
						let sut = Application().withFakeCommandLineParser().withParser(parser).withProcessor(processor)
						// Execute
						sut.run()
						// Verify
						expect(processor.runWasCalled) == false
					}
				}
			}
			
			context("generating") {
				
				it("should launch generator") {
					// Setup
					let generator = FakeGenerator()
					let sut = Application()
						.withFakeCommandLineParser()
						.withFakeParser()
						.withFakeProcessor()
						.withGenerator(generator)
					// Execute
					sut.run()
					// Verify
					expect(generator.runWasCalled) == true
				}
				
				context("previous steps fail") {
					
					it("should not launch generator if command line parser fails") {
						// Setup
						let generator = FakeGenerator()
						let sut = Application()
							.withCommandLineParser(FakeCommandLineParser().runWithFailure(true))
							.withFakeParser()
							.withFakeProcessor()
							.withGenerator(generator)
						// Execute
						sut.run()
						// Verify
						expect(generator.runWasCalled) == false
					}
					
					it("should not launch generator if parser fails") {
						// Setup
						let generator = FakeGenerator()
						let sut = Application()
							.withFakeCommandLineParser()
							.withParser(FakeParser().runWithFailure(true))
							.withFakeProcessor()
							.withGenerator(generator)
						// Execute
						sut.run()
						// Verify
						expect(generator.runWasCalled) == false
					}
					
					it("should not launch generator if processor fails") {
						// Setup
						let generator = FakeGenerator()
						let sut = Application()
							.withFakeCommandLineParser()
							.withFakeParser()
							.withProcessor(FakeProcessor().runWithFailure(true))
							.withGenerator(generator)
						// Execute
						sut.run()
						// Verify
						expect(generator.runWasCalled) == false
					}
				}
			}
		}
		
		describe("properties") {
			
			context("parser") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let parser = sut.parser
					// Verify
					expect(parser).toNot(beNil())
				}
				
				it("should assign helper classes during creation") {
					// Setup
					let settings = Settings()
					let store = Store()
					let sut = Application().withSettings(settings).withStore(store)
					// Execute
					let parser = sut.parser
					// Verify
					expect(parser.settings) === settings
					expect(parser.store) === store
				}
			}
			
			context("processor") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let processor = sut.processor
					// Verify
					expect(processor).toNot(beNil())
				}
				
				it("should assign helper classes during creation") {
					// Setup
					let settings = Settings()
					let store = Store()
					let sut = Application().withSettings(settings).withStore(store)
					// Execute
					let processor = sut.processor
					// Verify
					expect(processor.settings) === settings
					expect(processor.store) === store
				}
			}
			
			context("generator") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let generator = sut.generator
					// Verify
					expect(generator).toNot(beNil())
				}
				
				it("should assign helper classes during creation") {
					// Setup
					let settings = Settings()
					let store = Store()
					let sut = Application().withSettings(settings).withStore(store)
					// Execute
					let generator = sut.generator
					// Verify
					expect(generator.settings) === settings
					expect(generator.store) === store
				}
			}
			
			context("store") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let store = sut.store
					// Verify
					expect(store).toNot(beNil())
				}
			}
			
			context("options") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let options = sut.options
					// Verify
					expect(options).toNot(beNil())
				}
			}
			
			context("settings") {
				
				it("should instantiate on first call") {
					// Setup
					let sut = Application()
					// Execute
					let settings = sut.settings
					// Verify
					expect(settings).toNot(beNil())
				}
			}
		}
		
	}
	
}
