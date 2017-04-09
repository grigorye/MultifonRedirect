//
//  AppDelegate.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 22.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

let versionIsClean: Bool = {
	let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
	return nil == version.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted)
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	private let shortcutsController = ShortcutsController()
	private let alternateAppIconController = AlternateAppIconController()

	func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
		return shortcutsController.handleShortcutItem(shortcutItem)
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		shortcutsController.application(application, performActionFor: shortcutItem, completionHandler: completionHandler)
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		RequestError.setUserInfoValueProvider()
		_ = alternateAppIconController
		let shortcutsApplicationDidFinishLaunching = shortcutsController.application(application, didFinishLaunchingWithOptions: launchOptions)
		return shortcutsApplicationDidFinishLaunching
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		shortcutsController.applicationDidBecomeActive(application)
	}

	override init() {
		super.init()
		_ = nslogRedirectorInitializer
		if versionIsClean {
			_ = fabricInitializer
		}
	}

}
