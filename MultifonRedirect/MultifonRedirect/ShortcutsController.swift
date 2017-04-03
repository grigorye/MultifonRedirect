//
//  ShortcutsController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 03.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

class ShortcutsController {
	
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
			routingController.set(routing) { (requestError) in
				_ = $(requestError)
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

	func updateShortcuts(from routingController: RoutingController?) {
		let shortcutItems: [UIApplicationShortcutItem] = {
			if let _ = routingController {
				let phoneOnly = UIMutableApplicationShortcutItem(type: Shortcut.routing(.phoneOnly).type, localizedTitle: "Phone Only")
				let multifonOnly = UIMutableApplicationShortcutItem(type: Shortcut.routing(.multifonOnly).type, localizedTitle: "Multifon Only")
				let phoneAndMultifon = UIMutableApplicationShortcutItem(type: Shortcut.routing(.phoneAndMultifon).type, localizedTitle: "Phone and Multifon")
				let logout = UIMutableApplicationShortcutItem(type: Shortcut.action(.logout).type, localizedTitle: "Logout")
				return [phoneOnly, multifonOnly, phoneAndMultifon, logout]
			} else {
				let login = UIMutableApplicationShortcutItem(type: Shortcut.action(.login).type, localizedTitle: "Sign In")
				return [login]
			}
		}()
		UIApplication.shared.shortcutItems = shortcutItems
	}
}
