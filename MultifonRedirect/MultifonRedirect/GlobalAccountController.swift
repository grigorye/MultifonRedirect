//
//  GlobalAccountController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 08.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

class GlobalAccountController : AccountController {
	
	var accountParams: AccountParams

	var lastRouting: Routing? {
		get {
			guard let lastRoutingString = defaults.lastRouting else {
				return nil
			}
			return Routing(rawValue: lastRoutingString)
		}
		set {
			defaults.lastRouting = newValue?.rawValue
			globalAccountHolder.accountLastRoutingDidChange()
		}
	}

	var lastUpdateDate: Date? {
		get {
			return defaults.lastUpdateDate
		}
		set {
			defaults.lastUpdateDate = newValue
		}
	}
	
	var nextRouting: Routing? {
		didSet {
			globalAccountHolder.accountNextRoutingDidChange()
		}
	}
	
	func refreshRouting(completionHandler: @escaping (Erring<Void>) -> ()) -> CancellationToken {
		return (self as AccountController).refreshRouting { (erring) in
			guard case .some() = erring else {
				completionHandler(erring)
				return
			}
			completionHandler(erring)
		}
	}

	func setRouting(_ routing: Routing, completionHandler: @escaping (Erring<Void>) -> ()) {
		(self as AccountController).setRouting(routing) { (erring) in
			guard case .some() = erring else {
				completionHandler(erring)
				return
			}
			completionHandler(erring)
		}
	}
	
	init?() {
		guard let accountNumber = defaults.accountNumber, let password = defaults.password else {
			return nil
		}
		accountParams = AccountParams(accountNumber: accountNumber, password: password)
	}
	
}
