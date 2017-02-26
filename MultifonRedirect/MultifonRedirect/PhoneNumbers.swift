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

func configurePhoneNumberTextField(_ textField: UITextField) {
	let phoneNumberTextField = textField as! PhoneNumberTextField
	phoneNumberTextField.defaultRegion = defaultRegion
}


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
	guard let nationalNumber = try? phoneNumberKit.parse(phoneNumber).nationalNumber else {
		return nil
	}
	return "7\(nationalNumber)"
}
