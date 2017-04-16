//
//  AlternateAppIconController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 08.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import MultifonRedirectSupport
import UIKit

extension TypedUserDefaults {
	
	@NSManaged var alternateAppIconsEnabled: Bool
	
}

struct AppIconNames {
	
	static let phoneOnly = "AppIcon-PhoneOnly"
	static let multifonOnly = "AppIcon-MultifonOnly"
	static let phoneAndMultifon = "AppIcon-PhoneAndMultifon"
	
}

class AlternateAppIconController : NSObject, AccountPossessor {
	
	let application = UIApplication.shared

	func clearAppIconAsUserDisabled() {
		guard #available(iOS 10.3, *) else {
			return
		}
		let action = would(.clearAppIconAsUserDisabled); let preflight: Preflight?; defer { action.preflight = preflight }
		guard application.supportsAlternateIcons else {
			preflight = .cancelled(due: .applicationDoesNotSupportAlternateIcons)
			return
		}
		guard application.alternateIconName != nil else {
			preflight = .cancelled(due: .applicationIconIsAlreadyPrimary)
			return
		}
		preflight = nil
		application.setAlternateIconName(nil) { error in
			if let error = error {
				action.failed(due: $(error))
				return
			}
			action.succeeded()
		}
	}
	
	func accountControllerDidChange() {
		guard defaults.alternateAppIconsEnabled, #available(iOS 10.3, *) else {
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
		guard defaults.alternateAppIconsEnabled, #available(iOS 10.3, *) else {
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
	
	func invalidateApplicationIconForDefaults() {
		guard .active == application.applicationState else {
			let notificationCenter = NotificationCenter.default
			var observer: NSObjectProtocol! = nil
			observer = notificationCenter.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
				self.invalidateApplicationIconForDefaults()
				notificationCenter.removeObserver(observer)
			}
			return
		}
		if !defaults.alternateAppIconsEnabled {
			clearAppIconAsUserDisabled()
		}
		else {
			accountLastRoutingDidChange()
		}
	}
	
	private final func bindAlternateAppIconsEnabledDefault() -> Handler {
		let binding = KVOBinding(defaults•#keyPath(TypedUserDefaults.alternateAppIconsEnabled), options: [.initial]) { (_) in
			self.invalidateApplicationIconForDefaults()
		}
		return { _ = binding }
	}
	
	override init() {
		super.init()
		scheduledForDeinit.append(bindAlternateAppIconsEnabledDefault())
		scheduledForDeinit.append(bindAccountAccessor())
	}

}
