//
//  UserDefaults.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

extension TypedUserDefaults {
	
	@NSManaged var accountNumber: String?
	@NSManaged var password: String?
	
	dynamic class var keyPathsForValuesAffectingAccountParams: Set<String> {
		return [
			#keyPath(accountNumber),
			#keyPath(password)
		]
	}
	
	dynamic var accountParams: AccountParams? {
		get {
			guard let accountNumber = accountNumber, let password = password else {
				return nil
			}
			return AccountParams(accountNumber: accountNumber, password: password)
		}
		set {
			accountNumber = newValue?.accountNumber
			password = newValue?.password
		}
	}
	
	@NSManaged var lastUpdateDate: Date?
	@NSManaged var lastRouting: String?
	
}
