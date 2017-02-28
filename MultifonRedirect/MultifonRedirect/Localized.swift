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

	static let phoneNumberPlaceholder = NSLocalizedString(
		"phoneNumber.placeholder",
		tableName: "RoutingView",
		value: "Not Set",
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
