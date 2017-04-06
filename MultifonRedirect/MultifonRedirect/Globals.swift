//
//  Globals.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 03.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit
import Foundation

var routingControllerImp: RoutingController! = {
	guard let accountNumber = savedAccountNumber, let password = savedPassword else {
		return nil
	}
	return RoutingController(accountNumber: accountNumber, password: password) … {
		$0.lastRouting = savedLastRouting
		$0.lastUpdateDate = savedLastUpdateDate
	}
}()

var routingController: RoutingController! {
	set {
		routingControllerImp = newValue
		if let routingController = newValue {
			savedAccountNumber = routingController.accountNumber
			savedPassword = routingController.password
		} else {
			savedAccountNumber = nil
			savedPassword = nil
		}
		updateRouting(from: routingController)
		routingViewController.updateAccountStatusView()
		shorcutsController.updateShortcuts(from: routingController)
	}
	get {
		return routingControllerImp
	}
}

func logout() {
	let action = would(.logout)
	routingController = nil
	action.succeeded()
}

var routingViewController: RoutingViewController!
var shorcutsController = ShortcutsController()

//
// MARK: -
//

var loggedIn: Bool {
	return nil != routingController
}

var routing: Routing? = routingController?.lastRouting {
	didSet {
		routingViewController?.routingDidChange()
	}
}

func updateRouting(from routingController: RoutingController?) {
	guard let routingController = routingController else {
		routing = nil
		savedLastRouting = nil
		savedLastUpdateDate = nil
		return
	}
	routing = routingController.lastRouting!
	savedLastRouting = routingController.lastRouting!
	savedLastUpdateDate = routingController.lastUpdateDate!
	updateAppIcon(for: routing)
}

func updateAppIcon(for routing: Routing?) {
	guard #available(iOS 10.3, *) else {
		return
	}
	let action = would(.updateAppIcon(for: routing)); let preflight: Preflight?; defer { action.preflight = preflight }
	let application = UIApplication.shared
	guard application.supportsAlternateIcons else {
		preflight = .cancelled(due: .applicationDoesNotSupportAlternateIcons)
		return
	}
	let iconName: String? = {
		switch routing {
		case nil: return nil
		case .phoneOnly?: return "AppIcon-PhoneOnly"
		case .multifonOnly?: return "AppIcon-MultifonOnly"
		case .phoneAndMultifon?: return "AppIcon-PhoneAndMultifon"
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
