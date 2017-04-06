//
//  Undoable.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 06.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

struct Undoable {
	var undoStack: [() -> ()] = []
	mutating func perform(f: @escaping (Bool) -> ()) {
		f(true)
		undoStack.insert({
			f(false)
		}, at: 0)
	}
	mutating func undo() {
		for i in undoStack {
			i()
		}
		undoStack.removeAll()
	}
}
