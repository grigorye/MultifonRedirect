//
//  PhoneNumbers.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import PhoneNumberKit
import Foundation

let defaultRegion = "RU"
let partialFormatter = PartialFormatter(defaultRegion: defaultRegion)
let phoneNumberKit = PhoneNumberKit()


func phoneNumberFromAccountNumber(_ accountNumber: String?) -> String? {
	guard let accountNumber = accountNumber else {
		return nil
	}
	return partialFormatter.formatPartial("+\(accountNumber)")
}

func accountNumberFromPhoneNumber(_ phoneNumber: String?) -> String? {
	guard let phoneNumber = phoneNumber else {
		return nil
	}
	guard let nationalNumber = try? phoneNumberKit.parse(phoneNumber, withRegion: defaultRegion).nationalNumber else {
		return nil
	}
	return "7\(nationalNumber)"
}
