//
//  Created by Tomaz Kragelj on 11.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Defines requirements for a task.

A task is a single step of an execution phase. Multiple tasks can be stacked to form a flow of execution.

Note that in case task fails, it should log the reason and then throw an error (see `Result` enumeration for commonly used ones - for example `Result.Cancel` to cancel execution). This allows leveraging Swift 2 do/catch statement:

	do {
		try task1.run()
		try task2.run()
		try task3.run()
	} catch {
	}

Tasks can themselves use sub-tasks. An example task implementation:

	func run() throws {
		try subtask1.run()
		try subtask2.run()
	}

As you can see, you can simply allow error to propagate down to calling function if you don't need to handle it internally.
*/
protocol Task {

	/** Runs the task.
	
	If everything is fine, execution should continue, otherwise reason for error should be logged and error thrown.
	*/
	func run() throws
	
}
