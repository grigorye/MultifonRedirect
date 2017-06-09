//
//  AccountPossessor.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 03.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import GEFoundation
import Foundation

public class GlobalAccountHolder {

	private final func bindAccountGlobalAccountController() -> Handler {
		let binding = defaults.observe(\.accountParams, options: [.initial, .new]) { (_, change) in
			self.accountController = {
				guard let newValue = change.newValue, let accountParams = newValue else {
					return nil
				}
				return GlobalAccountController(accountParams: accountParams)
			}()
		}
		return { _ = binding }
	}
	
	fileprivate var accountController: GlobalAccountController? {
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
				defaults.accountParams = accountParams
				assert(nil != self.accountController)
				defaults.lastUpdateDate = Date()
				defaults.lastRouting = routing.rawValue
				completionHandler(nil)
			}
		}
	}
	
	func logout() {
		accountController = nil
		let action = would(.logout)
		defaults.accountParams = nil
		assert(nil == self.accountController)
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
	
	var scheduledForDeinit = ScheduledHandlers()
	
	deinit {
		scheduledForDeinit.perform()
	}

	init() {
		scheduledForDeinit.append(bindAccountGlobalAccountController())
	}
	
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
	
	func bindAccountAccessor() -> GEFoundation.Handler {
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
