//
//  AlternateAppIconController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 08.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

struct AppIconNames {
	
	static let phoneOnly = "AppIcon-PhoneOnly"
	static let multifonOnly = "AppIcon-MultifonOnly"
	static let phoneAndMultifon = "AppIcon-PhoneAndMultifon"
	
}

class AlternateAppIconController : NSObject, AccountPossessor {
	
	let application = UIApplication.shared

	func accountControllerDidChange() {
		guard #available(iOS 10.3, *) else {
			return
		}
		if nil == accountController {
			let action = would(.clearAppIconDueLogout)
			application.setAlternateIconName(nil) { error in
				if let error = error {
					action.failed(due: $(error))
					return
				}
				action.succeeded()
			}
		}
	}
	
	func accountNextRoutingDidChange() {
	}
	
	func accountLastRoutingDidChange() {
		guard #available(iOS 10.3, *) else {
			return
		}
		let lastRouting = accountController?.lastRouting
		let action = would(.updateAppIcon(for: lastRouting)); let preflight: Preflight?; defer { action.preflight = preflight }
		guard application.supportsAlternateIcons else {
			preflight = .cancelled(due: .applicationDoesNotSupportAlternateIcons)
			return
		}
		let iconName: String? = {
			switch lastRouting {
			case nil:
				return nil
			case .phoneOnly?:
				return AppIconNames.phoneOnly
			case .multifonOnly?:
				return AppIconNames.multifonOnly
			case .phoneAndMultifon?:
				return AppIconNames.phoneAndMultifon
			}
		}()
		guard application.alternateIconName != iconName else {
			preflight = .cancelled(due: .applicationIconWouldNotBeChanged)
			return
		}
		preflight = nil
		application.setAlternateIconName(iconName) { error in
			if let error = error {
				action.failed(due: $(error))
				return
			}
			action.succeeded()
		}
	}
	
	var scheduledForDeinit = ScheduledHandlers()
	
	deinit {
		scheduledForDeinit.perform()
	}
	
	override init() {
		super.init()
		self.registerAccountPossesor()
		scheduledForDeinit.append {
			self.unrergisterAccountPossesor()
		}
	}

}
