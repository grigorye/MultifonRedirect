//
//  Localized.swift
//  MultifonRedirectToday
//
//  Created by Grigory Entin on 11.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

struct TodayLocalized {
	
	static let phoneOnlyRoutingTitle = NSLocalizedString(
		"phoneOnlyRouting.title",
		tableName: "Today",
		value: "Phone",
		comment: ""
	)
	
	static let multifonOnlyRoutingTitle = NSLocalizedString(
		"multifonOnlyRouting.title",
		tableName: "Today",
		value: "MultiFon",
		comment: ""
	)
	
	static let phoneAndMultifonRoutingTitle = NSLocalizedString(
		"phoneAndMultifonRouting.title",
		tableName: "Today",
		value: "MultiFon and Phone",
		comment: ""
	)
	
	static let unknownRoutingTitle = NSLocalizedString(
		"unknownRouting.title",
		tableName: "Today",
		value: "Unknown",
		comment: ""
	)

}
