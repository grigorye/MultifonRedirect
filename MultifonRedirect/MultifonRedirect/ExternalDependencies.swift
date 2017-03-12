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
	print("• \(function).\(line).\(column):\n\(description)", terminator: "")
	return value
}


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
