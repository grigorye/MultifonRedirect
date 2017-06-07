//
//  RoutingController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 11.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

public protocol AccountController : class {
	
	var lastRouting: Routing? { get set }
	var lastUpdateDate: Date? { get set }
	var nextRouting: Routing? { get set }
	var accountParams: AccountParams { get }

}

extension AccountController {
	
	public func refreshRouting(completionHandler: @escaping (Erring<Void>) -> ()) -> CancellationToken {
		return queryRouting(for: accountParams) { (erringRouting) in
			DispatchQueue.main.async {
				guard case .some(let routing) = erringRouting else {
					completionHandler(.error(erringRouting.error!))
					return
				}
				self.lastRouting = routing
				self.lastUpdateDate = Date()
				completionHandler(.some(()))
			}
		}
	}
	
	public func setRouting(_ routing: Routing, completionHandler: @escaping (Erring<Void>) -> ()) {
		nextRouting = routing
		MultifonRedirectSupport.setRouting(routing, for: accountParams) { (erring) in
			DispatchQueue.main.async {
				self.nextRouting = nil
				guard case .some() = erring else {
					completionHandler(erring)
					return
				}
				self.lastRouting = routing
				self.lastUpdateDate = Date()
				completionHandler(.some(()))
			}
		}
	}
	
}
