//
//  PersistentData.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 12.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

var savedAccountNumber: String? {
	get {
		return string(for: .accountNumber)
	}
	set {
		set(newValue, for: .accountNumber)
	}
}

var savedPassword: String? {
	get {
		return string(for: .password)
	}
	set {
		set(newValue, for: .password)
	}
}

var savedLastUpdateDate: Date? {
	get {
		return date(for: .lastUpdateDate)
	}
	set {
		set(newValue, for: .lastUpdateDate)
	}
}

var savedLastRouting: Routing? {
	get {
		guard let routingString = string(for: .lastRouting) else {
			return nil
		}
		return Routing(rawValue: routingString)
	}
	set {
		set(newValue?.rawValue, for: .lastRouting)
	}
}
