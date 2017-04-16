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
	@NSManaged var lastUpdateDate: Date?
	@NSManaged var lastRouting: String?
	
}
