//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Swiftified `GBOptionsHelpers` registration.

This class allows to use convenience functions for options registrations. To use, you need to pass `Options` instance on which to operate to `register` function and then you can call convenience functions for actual registrations inside the block. Using convenience functions outside this block will result in runtime exceptions!
*/
open class SwiftyOptions {
	
	/// The one and only `OptionsRegistrator` instance
	open static let sharedInstance = SwiftyOptions()
	
	/** Registers options using helper methods.
	
	It's required to wrap all convenience registration method calls the block!
	*/
	open func register(_ options: GBOptionsHelper, block: () -> Void) {
		self.options = options
		block()
		self.options = nil
	}
	
	/// Current `Options` instance on which registration functions will operate.
	fileprivate(set) internal var options: GBOptionsHelper!
}

/** Starts options section with given separator.

Register all options or groups inside the given block.

Note this method registers section to last instance of the `Options` class, assigned to `lastOptionsInstance` global variable.

@param separator The name of separator to use on help output.
@param block Block inside which to register all options or groups of this section.
*/
public func section(_ separator: String, block: () -> Void) {
	SwiftyOptions.sharedInstance.options.registerSeparator(separator)
	block()
}

/** Starts an option group.

Register all options inside the given block.

@param name The name of the group as used on command line.
@param description The description of the group as shown on help output.
@param flags Optional group flags - whether there's a value attached etc. Defaults to `.NoValue`.
@param block Block inside which to register all options of this group.
*/
public func group(_ name: String, description: String, flags: GBOptionFlags = .noValue, block: @escaping () -> Void) {
	SwiftyOptions.sharedInstance.options.registerGroup(name, description: description, flags: flags) { options in
		block()
	}
}

/** Describes an option.

@param short Optional short option key as used on command line. Pass nil to not use short key.
@param long Long option key as used on command line, required.
@param description The description of the option as shown on help output.
@param flags Optional option flags - whether there's value required or not etc. Defaults to `.NoValue`
*/
public func option(_ short: Character?, long: String, description: String, flags: GBOptionFlags = .noValue) {
	// Convert Character to Int8. Not sure this is the best approach...
	var shorty = Int8(0)
	if let short = short {
		shorty = Int8("\(short)".utf8.first!)
	}
	SwiftyOptions.sharedInstance.options.registerOption(shorty, long: long, description: description, flags: flags)
}
