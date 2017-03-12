//
//  AccountDetailsViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit.UITableViewController

class AccountDetailsViewController: UITableViewController, AccountDetailsEditor {

	typealias L = AccountDetailsViewLocalized

	var routingController: RoutingController?
	
	@IBOutlet var phoneNumberField: UITextField!
	@IBOutlet var passwordField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		phoneNumberField.becomeFirstResponder()
	}
	
}

extension AccountDetailsViewController {

	@IBAction func save() {
		guard view.endEditing(false) else {
			return
		}
		let accountNumber = accountNumberFromPhoneNumber(phoneNumberField.text)!
		let password = passwordField.text!
		let routingController = RoutingController(accountNumber: accountNumber, password: password)
		view.isUserInteractionEnabled = false
		routingController.query { (error) in
			DispatchQueue.main.async {
				self.view.isUserInteractionEnabled = true
				guard nil == error else {
					self.present(error!, forFailureDescription: L.couldNotLoginToAccountRoutingTitle)
					return
				}
				self.routingController = routingController
				self.performSegue(withIdentifier: "loggedIn", sender: self)
			}
		}
	}
	
	@IBAction func cancel() {
		performSegue(withIdentifier: "cancel", sender: self)
	}

}
