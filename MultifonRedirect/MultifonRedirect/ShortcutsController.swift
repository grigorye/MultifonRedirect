//
//  ShortcutsController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 03.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

private let selectedIcon = UIApplicationShortcutIcon(templateImageName: "Shortcut-ActiveRoute")
private let nonselectedIcon = UIApplicationShortcutIcon(templateImageName: "Shortcut-InactiveRoute")

extension Optional where Wrapped == Routing {
	
	func shortcutIcon(forSelected routing: Routing) -> UIApplicationShortcutIcon {
		guard case .some(routing) = self else {
			return nonselectedIcon
		}
		return selectedIcon
	}
	
}

class ShortcutsController : NSObject, AccountPossessor {
	
	typealias L = ShortcutsLocalized
	
	enum Shortcut {
		
		enum Action: String {
			case logout
			case login
		}
		
		case routing(Routing)
		case action(Action)
		
		struct Prefixes {
			static let routing = "routing-"
			static let action = "action-"
		}
		
		init?(type: String) {
			guard let lastTypeComponent = type.components(separatedBy: ".").last else {
				return nil
			}
			if let prefixRange = lastTypeComponent.range(of: Prefixes.routing) {
				let routingValue = lastTypeComponent.replacingCharacters(in: prefixRange, with: "")
				self = .routing(Routing(rawValue: routingValue)!)
				return
			}
			if let prefixRange = lastTypeComponent.range(of: Prefixes.action) {
				let actionValue = lastTypeComponent.replacingCharacters(in: prefixRange, with: "")
				self = .action(Action(rawValue: actionValue)!)
				return
			}
			return nil
		}
		
		var type: String {
			let lastTypeComponent: String = {
				switch self {
				case .routing(let routing):
					return Prefixes.routing + routing.rawValue
				case .action(let action):
					return Prefixes.action + action.rawValue
				}
			}()
			return Bundle.main.bundleIdentifier! + "." + lastTypeComponent
		}
		
	}
	
	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		let shortcut = Shortcut(type: shortcutItem.type)!
		switch shortcut {
		case .routing(let routing):
			let action = would(.setRoutingFromShortcut(routing))
			accountController!.setRouting(routing) { (erring) in
				DispatchQueue.main.async {
					guard case .some(_) = erring else {
						action.failed(due: erring.error!)
						return
					}
					action.succeeded()
				}
			}
			return false
		case .action(.login):
			return false
		case .action(.logout):
			logout()
			return false
		}
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		completionHandler(handleShortcutItem(shortcutItem))
	}
	
	var launchedShortcutItem: UIApplicationShortcutItem?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
			launchedShortcutItem = shortcutItem
		}
		return (nil == launchedShortcutItem)
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		if let launchedShortcutItem = launchedShortcutItem {
			_ = $(handleShortcutItem(launchedShortcutItem))
			self.launchedShortcutItem = nil
		}
	}
	
	static let logoutIcon = UIApplicationShortcutIcon(templateImageName: "Shortcut-Logout")
	static let loginIcon = UIApplicationShortcutIcon(templateImageName: "Shortcut-Login")
	let logoutShortcutItem = UIMutableApplicationShortcutItem(type: Shortcut.action(.logout).type, localizedTitle: L.logoutTitle, localizedSubtitle: nil, icon: logoutIcon)
	let loginShortcutItem = UIApplicationShortcutItem(type: Shortcut.action(.login).type, localizedTitle: L.loginTitle, localizedSubtitle: nil, icon: loginIcon)
	
	let phoneOnlyShortcutItem = UIMutableApplicationShortcutItem(type: Shortcut.routing(.phoneOnly).type, localizedTitle: L.phoneOnlyRoutingTitle)
	let multifonOnlyShortcutItem = UIMutableApplicationShortcutItem(type: Shortcut.routing(.multifonOnly).type, localizedTitle: L.multifonOnlyRoutingTitle)
	let phoneAndMultifonShortcutItem = UIMutableApplicationShortcutItem(type: Shortcut.routing(.phoneAndMultifon).type, localizedTitle: L.phoneAndMultifonRoutingTitle)

	var shortcutsForLoggedIn: [UIApplicationShortcutItem] {
		return [
			multifonOnlyShortcutItem,
			phoneOnlyShortcutItem,
			phoneAndMultifonShortcutItem,
			logoutShortcutItem
		]
	}
	
	func accountLastRoutingDidChange() {
		let lastRouting = accountController!.lastRouting
		phoneOnlyShortcutItem.icon = lastRouting.shortcutIcon(forSelected: .phoneOnly)
		multifonOnlyShortcutItem.icon = lastRouting.shortcutIcon(forSelected: .multifonOnly)
		phoneAndMultifonShortcutItem.icon = lastRouting.shortcutIcon(forSelected: .phoneAndMultifon)
		UIApplication.shared.shortcutItems = shortcutsForLoggedIn
	}
	
	func accountNextRoutingDidChange() {
	}
	
	func accountControllerDidChange() {
		let shortcutItems: [UIApplicationShortcutItem] = {
			switch accountController {
			case .some(let accountController):
				logoutShortcutItem.localizedSubtitle = accountController.accountParams.accountNumber
				return shortcutsForLoggedIn
			case nil:
				return [loginShortcutItem]
			}
		}()
		UIApplication.shared.shortcutItems = shortcutItems
	}
	
	var scheduledForDeinit = ScheduledHandlers()
	
	deinit {
		scheduledForDeinit.perform()
	}
	
	override init() {
		super.init()
		scheduledForDeinit.append(bindAccountAccessor())
	}
	
}
