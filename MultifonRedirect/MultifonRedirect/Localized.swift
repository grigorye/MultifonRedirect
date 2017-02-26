//
//  Localized.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 25.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

struct RequestErrorLocalized {

	static let unexpectedServerResponse = NSLocalizedString(
		"accountNotFound",
		tableName: "RequestError",
		value: "Unexpected server response.",
		comment: ""
	)

	static let accountNotFound = NSLocalizedString(
		"accountNotFound",
		tableName: "RequestError",
		value: "Phone not found.",
		comment: ""
	)
	
	static let wrongPassword = NSLocalizedString(
		"wrongPassword",
		tableName: "RequestError",
		value: "Wrong password.",
		comment: ""
	)
	
	static let routeChangeIsNotAllowed = NSLocalizedString(
		"routeChangeIsNotAllowed",
		tableName: "RequestError",
		value: "Route change is not allowed.",
		comment: ""
	)

}

struct RoutingViewErrorAlertLocalized {

	static let okButtonTitle = NSLocalizedString(
		"okButton.title",
		tableName: "RoutingViewErrorAlert",
		value: "OK",
		comment: ""
	)

}

struct RoutingViewLocalized {

	static let couldNotChangeRoutingTitle = NSLocalizedString(
		"couldNotChangeRouting.title",
		tableName: "RoutingView",
		value: "Could not change routing",
		comment: ""
	)
	
	static let couldNotUpdateRoutingTitle = NSLocalizedString(
		"couldNotUpdateRouting.title",
		tableName: "RoutingView",
		value: "Could not update routing",
		comment: ""
	)

}
