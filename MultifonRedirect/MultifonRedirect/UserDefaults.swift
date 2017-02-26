//
//  UserDefaults.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

enum DefaultsKey: String {
	case accountNumber
	case password
	case lastUpdateDate
}

private let defaults = UserDefaults.standard

func string(for key: DefaultsKey) -> String? {
	return defaults.string(forKey: key.rawValue)
}

func set(_ value: String?, for key: DefaultsKey) {
	defaults.set(value, forKey: key.rawValue)
}

func date(for key: DefaultsKey) -> Date? {
	return defaults.object(forKey: key.rawValue) as! Date?
}

func set(_ date: Date?, for key: DefaultsKey) {
	defaults.set(date, forKey: key.rawValue)
}
