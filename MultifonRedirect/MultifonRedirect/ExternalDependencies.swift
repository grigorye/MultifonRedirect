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
