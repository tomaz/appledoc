//
//  Created by Tomaz Kragelj on 12.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

extension Application {
	
	// MARK: - Command line parser
	
	func withCommandLineParser(parser: CommandLineParser) -> Self {
		self.commandLineParser = parser
		return self
	}
	
	func withFakeCommandLineParser() -> Self {
		return withCommandLineParser(FakeCommandLineParser())
	}
	
	// MARK: - Parser
	
	func withParser(parser: Parser) -> Self {
		self.parser = parser
		return self
	}
	
	func withFakeParser() -> Self {
		return withParser(FakeParser())
	}
	
	// MARK: - Processor
	
	func withProcessor(processor: Processor) -> Self {
		self.processor = processor
		return self
	}
	
	func withFakeProcessor() -> Self {
		return withProcessor(FakeProcessor())
	}
	
	// MARK: - Generator
	
	func withGenerator(generator: Generator) -> Self {
		self.generator = generator
		return self
	}
	
	func withFakeGenerator() -> Self {
		return withGenerator(FakeGenerator())
	}
	
	// MARK: - Other properties
	
	func withSettings(settings: Settings) -> Self {
		self.settings = settings
		return self
	}
	
	func withStore(store: Store) -> Self {
		self.store = store
		return self
	}
	
}
