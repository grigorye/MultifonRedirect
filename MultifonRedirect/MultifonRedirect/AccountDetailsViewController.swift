//
//  AccountDetailsViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import MultifonRedirectSupport
import UIKit.UITableViewController

let loginIndicatorBarButtonItemEnabled = false
let loginIndicatorViewEnabled = !loginIndicatorBarButtonItemEnabled

class AccountDetailsViewController: UITableViewController {

	typealias L = AccountDetailsViewLocalized

	var cancelLoginInProgress: (() -> ())?
	
	@IBOutlet var phoneNumberField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var loginIndicatorView: UIActivityIndicatorView!
	@IBOutlet var loginBarButtonItem: UIBarButtonItem!
	@IBOutlet var loginIndicatorBarButtonItem: UIBarButtonItem?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let loginIndicatorBarButtonItem = loginIndicatorBarButtonItem {
			let itemIndex = navigationItem.rightBarButtonItems!.index(of: loginIndicatorBarButtonItem)!
			navigationItem.rightBarButtonItems!.remove(at: itemIndex)
		}
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
		var undoable = Undoable()
		if let loginIndicatorView = loginIndicatorView, loginIndicatorViewEnabled {
			undoable.perform { forward in
				if forward {
					loginIndicatorView.startAnimating()
				} else {
					loginIndicatorView.stopAnimating()
				}
			}
		}
		if let loginIndicatorBarButtonItem = loginIndicatorBarButtonItem {
			let navigationItem = self.navigationItem
			var items = navigationItem.rightBarButtonItems!
			let loginBarButtonItem = self.loginBarButtonItem!
			if loginIndicatorBarButtonItemEnabled {
				let itemIndex = items.index(of: loginBarButtonItem)!
				undoable.perform { forward in
					navigationItem.rightBarButtonItems = items … {
						if forward {
							$0.remove(at: itemIndex)
							$0.insert(loginIndicatorBarButtonItem, at: itemIndex)
						}
					}
				}
			}
		}
		if !loginIndicatorBarButtonItemEnabled {
			let loginBarButtonItem = self.loginBarButtonItem!
			undoable.perform { forward in
				loginBarButtonItem.isEnabled = !forward
			}
		}
		let accountParams = AccountParams(accountNumber: accountNumber, password: password)
		cancelLoginInProgress = globalAccountHolder.login(with: accountParams) { (error) in
			DispatchQueue.main.async {
				defer { undoable.undo() }
				if let error = error {
					action.failed(due: error)
					if let requestError = error as? RequestError, case .urlSessionFailure(let underlyingError as NSError) = requestError, underlyingError.domain == NSURLErrorDomain, underlyingError.code == NSURLErrorCancelled {
						return
					}
					self.present(error, forFailureDescription: L.couldNotLoginToAccountRoutingTitle)
					return
				}
				assert(nil != self.cancelLoginInProgress)
				action.succeeded()
				self.performSegue(withIdentifier: "loggedIn", sender: self)
			}
		}
	}
	
	@IBAction func cancel() {
		let action = would(.cancelLogin)
		cancelLoginInProgress?()
		cancelLoginInProgress = nil
		performSegue(withIdentifier: "cancel", sender: self)
		action.succeeded()
	}

}
