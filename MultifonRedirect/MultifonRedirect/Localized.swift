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
		"unexpectedServerResponse",
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

struct RoutingViewAccountAlertLocalized {

	static let title = NSLocalizedString(
		"title",
		tableName: "RoutingViewAccountAlert",
		value: "Account",
		comment: ""
	)
	
	static let logOutTitle = NSLocalizedString(
		"logout.title",
		tableName: "RoutingViewAccountAlert",
		value: "Sign Out",
		comment: ""
	)
	
	static let cancelTitle = NSLocalizedString(
		"cancel.title",
		tableName: "RoutingViewAccountAlert",
		value: "Cancel",
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

struct AccountDetailsViewLocalized {

	static let couldNotLoginToAccountRoutingTitle = NSLocalizedString(
		"couldNotConnectToAccount.title",
		tableName: "AccountDetails",
		value: "Could not sign in to account",
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

	static let logInTitle = NSLocalizedString(
		"login.title",
		tableName: "RoutingView",
		value: "Sign In",
		comment: ""
	)
	
	static func accountTitle(for phoneNumber: String) -> String {
		let format = NSLocalizedString(
			"accountTitle.for",
			tableName: "RoutingView",
			value: "%@",
			comment: ""
		)
		return String.localizedStringWithFormat(format, phoneNumber)
	}
	
	static let refreshNotPossibleTitle = NSLocalizedString(
		"refreshNotPossible.title",
		tableName: "RoutingView",
		value: "Please sign in",
		comment: ""
	)
	
	private static let dateAgoComponentsFormatter: DateComponentsFormatter = {
		$0.unitsStyle = .full
		$0.allowsFractionalUnits = true
		$0.maximumUnitCount = 1
		$0.allowedUnits = [.minute, .year, .month, .weekOfMonth, .day, .hour]
		return $0
	} (DateComponentsFormatter())

	static func updated(at date: Date?) -> String {
		guard let date = date else {
			return NSLocalizedString(
				"never.updated.placeholder",
				tableName: "RoutingView",
				value: "Update Routing",
				comment: ""
			)
		}
		let format = NSLocalizedString(
			"updated.ago",
			tableName: "RoutingView",
			value: "Updated %@ ago",
			comment: ""
		)
		let ago = dateAgoComponentsFormatter.string(from: date, to: Date())!
		return String.localizedStringWithFormat(format, ago)
	}
	
}

struct ShortcutsLocalized {
	
	static let phoneOnlyRoutingTitle = NSLocalizedString(
		"phoneOnlyRouting.title",
		tableName: "Shortcuts",
		value: "Phone",
		comment: ""
	)
	
	static let multifonOnlyRoutingTitle = NSLocalizedString(
		"multifonOnlyRouting.title",
		tableName: "Shortcuts",
		value: "MultiFon",
		comment: ""
	)
	
	static let phoneAndMultifonRoutingTitle = NSLocalizedString(
		"phoneAndMultifonRouting.title",
		tableName: "Shortcuts",
		value: "MultiFon and Phone",
		comment: ""
	)
	
	static let logoutTitle = NSLocalizedString(
		"logout.title",
		tableName: "Shortcuts",
		value: "Sign Out",
		comment: ""
	)

	static let loginTitle = NSLocalizedString(
		"login.title",
		tableName: "Shortcuts",
		value: "Sign In",
		comment: ""
	)
	
}
