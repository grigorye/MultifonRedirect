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

	@IBAction func login() {
		let action = would(.login); let preflight: Preflight?; defer { action.preflight = preflight }
		guard view.endEditing(false) else {
			preflight = .cancelled(due: .endEditing)
			return
		}
		guard let phoneNumber = phoneNumberField.text else {
			preflight = .cancelled(due: .noPhoneNumberProvided)
			return
		}
		guard let accountNumber = accountNumberFromPhoneNumber(phoneNumber) else {
			preflight = .cancelled(due: .convertToAccountNumber(phoneNumber: phoneNumber))
			return
		}
		guard let password = passwordField.text, password != "" else {
			preflight = .cancelled(due: .noPasswordProvided)
			return
		}
		preflight = nil
		let routingController = RoutingController(accountNumber: accountNumber, password: password)
		view.isUserInteractionEnabled = false
		routingController.query { (error) in
			DispatchQueue.main.async {
				self.view.isUserInteractionEnabled = true
				if let error = error {
					action.failed(due: error)
					self.present(error, forFailureDescription: L.couldNotLoginToAccountRoutingTitle)
					return
				}
				self.routingController = routingController
				self.performSegue(withIdentifier: "loggedIn", sender: self)
				action.succeeded()
			}
		}
	}
	
	@IBAction func cancel() {
		let action = would(.cancelLogin)
		performSegue(withIdentifier: "cancel", sender: self)
		action.succeeded()
	}

}
