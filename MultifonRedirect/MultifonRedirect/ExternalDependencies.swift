//
//  ExternalDependencies.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 25.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

func $<T>(_ value: T, line: Int = #line, function: String = #function, column: Int = #column) -> T {
	let description: String = {
		var s = ""
		dump(value, to: &s)
		return s
	}()
	print("• \(function).\(line).\(column): \(description)", terminator: "")
	return value
}

// https://support.apple.com/kb/TA45403?locale=en_US&viewlocale=en_US

typealias LogCStringF = @convention(c) (_ message: UnsafeMutableRawPointer, _ length: CUnsignedInt, _ banner: CBool) -> Void

#if GE_NSLOG_REDIRECTION_ENABLED
@available(iOS 9.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
@_silgen_name("_NSSetLogCStringFunction") private func NSSetLogCStringFunction(_ f: LogCStringF)

let logCString: LogCStringF = { messageBytes, length, banner in
	let message = String(bytesNoCopy: messageBytes, length: Int(length), encoding: .utf8, freeWhenDone: false)!
	print(message)
}

public let nslogRedirectorInitializer: Void = {
	NSSetLogCStringFunction(logCString)
}()
#else
public let nslogRedirectorInitializer: Void = ()
#endif

//
// The idea is borrowed from https://github.com/devxoul/Then
//

infix operator …

//

@discardableResult
public func with<T: AnyObject>(_ obj: T, _ initialize: (T) throws -> Void) rethrows -> T {
	try initialize(obj)
	return obj
}

@discardableResult
public func …<T: AnyObject>(obj: T, initialize: (T) throws -> Void) rethrows -> T {
	return try with(obj, initialize)
}

//

public func with<T: Any>(_ value: T, _ initialize: (inout T) throws -> Void) rethrows -> T {
	var valueCopy = value
	try initialize(&valueCopy)
	return valueCopy
}

@discardableResult
public func …<T: Any>(value: T, initialize: (inout T) throws -> Void) rethrows -> T {
	return try with(value, initialize)
}
