//
//  Created by Tomaz Kragelj on 16.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation
import libclang

/** Parses Objective-C files into given `Store` using given `Settings`.

A new instance can be created for each path, passing it the path to scan in convenience initializer. Or the same instance can be reused multiple times by assigning a new path every time. Whichever way, `run` must be called in order to trigger actual parsing.

Everything parsed from the given source path, is registered to given `Store`.
*/
class ObjectiveCParser: Task {
	
	convenience init(path: PathInfo) {
		self.init()
		self.path = path
	}

	// MARK: - Task
	
	/** Launches Objective-C parsing on assigned file.
	
	Note that it's required to assign `path`, `settings` and `store` prior to calling this function!
	*/
	func run() throws {
		guard let path = path else {
			gerror("Filename not specified!")
			throw Result.Cancel
		}
		
		gdebug("Starting Objective-C parser on \(path)")
		
		// NOTE: this is quickly assembled code; it gets parsing going, but will probably need changes in order to have it fully working... Have it do one pass over source files to see results; or better yet, use https://github.com/tomaz/ClangTest which will print out more detailed information (also feel free to experiment with that source code to see what's possible).
		
		// Clang would skip parsing .h files, so we need to copy them to temporary path.
		if path.fullPath.pathExtension == ".h" {
			parsePath = NSTemporaryDirectory().stringByAppendingPathComponent(path.fullPath.lastPathComponent)
			try NSFileManager.defaultManager().copyItemAtPath(path.fullPath, toPath: parsePath)
		} else {
			parsePath = path.fullPath
		}
		
		// Prepare clang translation unit with the given path.
		let index = clang_createIndex(0, 0)
		let flags = CXTranslationUnit_None.rawValue // CXTranslationUnit_Incomplete.rawValue + CXTranslationUnit_SkipFunctionBodies.rawValue + CXTranslationUnit_DetailedPreprocessingRecord.rawValue
		let translationUnit = clang_parseTranslationUnit(index, parsePath, nil, 0, nil, 0, flags)
		
		// Parse all tokens.
		clang_visitChildrenWithBlock(clang_getTranslationUnitCursor(translationUnit)) { (cursor, parent) -> CXChildVisitResult in
			// Get range of object in source file.
			let range = clang_getCursorExtent(cursor)
			let startLocation = self.sourceInfoFromLocation(clang_getRangeStart(range))
			
			// If we're descending into imported files, ignore.
			if startLocation.filename != path.fullPath {
				return CXChildVisit_Continue
			}
			
			// Get remaining object info and kind.
			let endLocation = self.sourceInfoFromLocation(clang_getRangeEnd(range))
			let kindValue = clang_getCursorKind(cursor)
			let kind = self.clangString(clang_getCursorKindSpelling(kindValue))
			
			// Get comment information. (note some comments are not reported through this, for those tokens will need to be parsed.
			let commentRange = clang_Cursor_getCommentRange(cursor)
			let commentText = clang_Cursor_getRawCommentText(cursor)
			print("\(self.clangString(commentText))")
			
			// Get object name.
			let name = self.clangString(clang_getCursorSpelling(cursor))
			print("\(kind) {\(kindValue.rawValue)} \(name) @ \(startLocation)-\(endLocation)")

			if kindValue == CXCursor_ObjCInterfaceDecl {
				let classInfo = ClassInfo()
				classInfo.name = name

				// Get all object tokens.
				var tokens = UnsafeMutablePointer<CXToken>()
				var tokensCount = UInt32(0)
				clang_tokenize(translationUnit, range, &tokens, &tokensCount)
				for i in 0..<Int(tokensCount) {
					let tokenKindValue = clang_getTokenKind(tokens[i])
					let tokenRange = clang_getTokenExtent(translationUnit, tokens[i])
					let token = self.clangString(clang_getTokenSpelling(translationUnit, tokens[i]))
					print("  \(tokenKindValue.rawValue)} \(token)")

					if tokenKindValue == CXToken_Punctuation && token == ":" {
						let superToken = tokens[i + 1]
						let superclass = ClassCrossReference()
						superclass.name = self.clangString(clang_getTokenSpelling(translationUnit, superToken))
						classInfo.superclass = superclass
					}

					if tokenKindValue == CXToken_Punctuation && token == "<" {
						var protocols: [ProtocolCrossReference] = []
						var protocolIndex = i + 1
						var protocolToken: String
						repeat {
							protocolToken = self.clangString(clang_getTokenSpelling(translationUnit, tokens[protocolIndex]))
							if protocolToken != "," && protocolToken != ">" {
								let p = ProtocolCrossReference()
								p.name = protocolToken
								protocols.append(p)
							}

							protocolIndex += 1
						} while (protocolToken != ">")

						classInfo.adoptedProtocols = protocols
					}

				}
				clang_disposeTokens(translationUnit, tokens, tokensCount)

				self.store.classes.append(classInfo)
			}

			// Recurse into all children.
			return CXChildVisit_Recurse
		}
		
		// Dispose all clang objects.
		clang_disposeTranslationUnit(translationUnit)
		clang_disposeIndex(index)
	}
	
	// MARK: - Helper functions

	private func sourceInfoFromLocation(location: CXSourceLocation) -> SourceInfo {
		// Get data from clang.
		var file: CXFile = nil
		var line: uint32 = 0
		var column: uint32 = 0
		clang_getFileLocation(location, &file, &line, &column, nil)
		
		// Since we need to use temporary path for headers, check if we need to swap filename info now. Note we should still leave any auto-imported paths as they are.
		var filename = clangString(clang_getFileName(file))
		if parsePath != path.fullPath && filename.lastPathComponent == path.fullPath.lastPathComponent {
			filename = path.fullPath
		}
		
		// Create and return source info.
		return SourceInfo(filename: filename, line: Int(line), column: Int(column))
	}
	
	private func clangString(source: CXString, dispose: Bool = true) -> String {
		// When you're done, dispose the string.
		defer {
			if dispose {
				clang_disposeString(source)
			}
		}
		
		// If source is not available, return empty string.
		if source.data == nil {
			return ""
		}
		
		// If source cannot be converted, return empty string.
		let cString = clang_getCString(source)
		guard let string = String(UTF8String: cString) else {
			return ""
		}
		
		// Returns string representing the given source string.
		return String(stringLiteral: string)
	}
	
	// MARK: - Properties
	
	/// Filename to parse. This must be assigned prior to using the object!
	var path: PathInfo!
	
	/// Application settings. This must be assigned prior to using the object!
	var settings: Settings!
	
	/// Application objects store. This must be assigned prior to using the object!
	var store: Store!
	
	// MARK: - Internal properties
	
	private var parsePath: String!
	
}
