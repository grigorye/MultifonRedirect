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
}

func string(for key: DefaultsKey) -> String? {
	return UserDefaults.standard.string(forKey: key.rawValue)
}

func set(_ value: String?, for key: DefaultsKey) {
	return UserDefaults.standard.set(value, forKey: key.rawValue)
}
