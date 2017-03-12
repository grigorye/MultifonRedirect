//
//  RouteTableViewCell.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 12.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

enum ActivationState {
	case active
	case inactive
	case activating
}

protocol RouteActivationAwareCell {
	
	func setRouteActivationState(_ activationState: ActivationState)
	
}

class RouteTableViewCell : UITableViewCell, RouteActivationAwareCell {

	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!

	func setRouteActivationState(_ activationState: ActivationState) {
		switch activationState {
		case .active:
			activityIndicatorView.isHidden = true
			accessoryType = .checkmark
		case .inactive:
			activityIndicatorView.isHidden = true
			accessoryType = .none
		case .activating:
			activityIndicatorView.isHidden = false
			accessoryType = .none
		}
	}
}

class SimpleRouteTableViewCell : UITableViewCell, RouteActivationAwareCell {
	
	func setRouteActivationState(_ activationState: ActivationState) {
		switch activationState {
		case .active:
			accessoryType = .checkmark
		case .inactive:
			accessoryType = .none
		case .activating:
			accessoryType = .detailButton
		}
	}
	
}
