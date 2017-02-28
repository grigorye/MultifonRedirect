//
//  AccountDetailsViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit.UITableViewController

class AccountDetailsViewController: UITableViewController, AccountDetailsEditor {

	var accountNumber: String?
	var password: String?

	@IBOutlet var phoneNumberField: UITextField!
	@IBOutlet var passwordField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		phoneNumberField.becomeFirstResponder()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		phoneNumberField.text = phoneNumberFromAccountNumber(accountNumber)!
		passwordField.text = password
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "save" {
			accountNumber = accountNumberFromPhoneNumber(phoneNumberField.text)
			password = passwordField.text
		}
	}
}
