//
//  ActionTags.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 19.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

enum ActionTag {
	
	case login
	case cancelLogin
	case refreshRouting
	case changeRouting(from: Routing, to: Routing)
	case setRoutingFromShortcut(Routing)
	case logout
	
}

enum ActionCancellationTag {
	
	case endEditing
	case convertToAccountNumber(phoneNumber: String)
	case noPhoneNumberProvided
	case noPasswordProvided
	case noAccountConnected
	
}
