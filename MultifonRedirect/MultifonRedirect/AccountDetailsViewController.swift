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
		if _false {
			phoneNumberField.becomeFirstResponder()
		}
		passwordField.delegate = PasswordFieldDelegate().retainedIn(passwordField)
		phoneNumberField.delegate = PhoneNumberFieldDelegate().retainedIn(phoneNumberField)
	}
	
}

class PhoneNumberFieldDelegate: NSObject, UITextFieldDelegate {
	
	var enforcedPrefix = "+7 "
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		// Put the enforced prefix into otherwise empty field on beginning of editing.
		guard let text = textField.text, text != "" else {
			textField.text = enforcedPrefix
			return true
		}
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		// Make field empty on the end of editing, if it contains just the enforced prefix.
		guard let text = textField.text, text != enforcedPrefix else {
			textField.text = nil
			return true
		}
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// Disallow any edits that would affect the enforced prefix, except for the case when the prefix is partially removed (restore the prefix in such a case).
		guard let text = textField.text as NSString? else {
			return false
		}
		let newText = text.replacingCharacters(in: range, with: string)
		if !newText.hasPrefix(enforcedPrefix) {
			if enforcedPrefix.hasPrefix(newText) {
				textField.text = enforcedPrefix
			}
			return false
		}
		return true
	}

}

class PasswordFieldDelegate: NSObject, UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		UIApplication.shared.sendAction(#selector(AccountDetailsViewController.login), to: nil, from: self, for: nil)
		return false
	}
	
}

extension AccountDetailsViewController {

	@IBAction func login() {
		let action = would(.login); let preflight: Preflight?; defer { action.preflight = preflight }
		guard view.endEditing(false) else {
			preflight = .cancelled(due: .endEditing)
			return
		}
		guard let phoneNumber = phoneNumberField.text, phoneNumber != "" else {
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
