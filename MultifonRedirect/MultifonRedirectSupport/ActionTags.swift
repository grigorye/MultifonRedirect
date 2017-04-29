//
//  ActionTags.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 19.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

public enum ActionTag {
	
	case login
	case cancelLogin
	case refreshRoutingFromRefrseshControl
	case refreshRouting
	case changeRouting(from: Routing?, to: Routing)
	case setRoutingFromPicker(Routing)
	case setRoutingFromShortcut(Routing)
	case logout
	case logoutFromRoutingView
	case logoutFromShortcut
	case updateAppIcon(for: Routing?)
	case clearAppIconDueLogout
	case clearAppIconAsUserDisabled
	
}

public enum ActionCancellationTag {
	
	case interactionNotReady
	case endEditing
	case convertToAccountNumber(phoneNumber: String)
	case noPhoneNumberProvided
	case noPasswordProvided
	case invalidCharactersInPassword
	case noAccountConnected
	case applicationDoesNotSupportAlternateIcons
	case applicationIconWouldNotBeChanged
	case applicationIconIsAlreadyPrimary
	
}
