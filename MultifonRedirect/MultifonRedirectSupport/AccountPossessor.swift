//
//  AccountPossessor.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 03.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

public class GlobalAccountHolder {

	fileprivate var accountController = GlobalAccountController() {
		didSet {
			accountControllerDidChange()
			if nil != accountController {
				accountLastRoutingDidChange()
			}
		}
	}
	
	public func login(with accountParams: AccountParams, completionHandler: @escaping (Error?) -> ()) -> CancellationToken {
		return queryRouting(for: accountParams) { (erring) in
			DispatchQueue.main.async {
				guard case .some(let routing) = erring else {
					completionHandler(erring.error!)
					return
				}
				defaults.accountNumber = accountParams.accountNumber
				defaults.password = accountParams.password
				defaults.lastUpdateDate = Date()
				defaults.lastRouting = routing.rawValue
				self.accountController = GlobalAccountController()
				completionHandler(nil)
			}
		}
	}
	
	func logout() {
		let action = would(.logout)
		accountController = nil
		defaults.accountNumber = nil
		defaults.password = nil
		action.succeeded()
	}
	
	func accountLastRoutingDidChange() {
		precondition(nil != accountController)
		for i in accountPossessors {
			i.accountLastRoutingDidChange()
		}
	}
	
	func accountNextRoutingDidChange() {
		precondition(nil != accountController)
		for i in accountPossessors {
			i.accountNextRoutingDidChange()
		}
	}
	
	func accountControllerDidChange() {
		for i in accountPossessors {
			i.accountControllerDidChange()
		}
	}

	var accountPossessors = [AccountPossessor]()
	
}


public let globalAccountHolder = GlobalAccountHolder()

public protocol AccountPossessor : NSObjectProtocol {
	
	func accountControllerDidChange()
	func accountLastRoutingDidChange()
	func accountNextRoutingDidChange()
	
}

public extension AccountPossessor {
	
	private var registeredPossessors: [AccountPossessor] {
		get {
			return globalAccountHolder.accountPossessors
		}
		set {
			globalAccountHolder.accountPossessors = newValue
		}
	}
	
	private func registerAccountPossesor() {
		registeredPossessors.append(self)
		accountControllerDidChange()
		if nil != accountController {
			accountLastRoutingDidChange()
		}
	}
	
	private func unrergisterAccountPossesor() {
		let i = (registeredPossessors.index {$0.isEqual(self)})!
		registeredPossessors.remove(at: i)
	}
	
	func bindAccountAccessor() -> Handler {
		registerAccountPossesor()
		return { self.unrergisterAccountPossesor() }
	}
	
	var accountController: AccountController? {
		return globalAccountHolder.accountController
	}
	
	func logout() {
		return globalAccountHolder.logout()
	}
	
}
