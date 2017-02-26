//
//  PhoneNumbers.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

func phoneNumberFromAccountNumber(_ accountNumber: String?) -> String? {
	guard let accountNumber = accountNumber else {
		return nil
	}
	return "+\(accountNumber)"
}

func accountNumberFromPhoneNumber(_ phoneNumber: String?) -> String? {
	guard let phoneNumber = phoneNumber else {
		return nil
	}
	return phoneNumber.substring(from: phoneNumber.index(after: phoneNumber.startIndex))
}
