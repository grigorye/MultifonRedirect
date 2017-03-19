//
//  UIKitExtensions.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 11.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

extension UIViewController {

	func present(_ error: Error, forFailureDescription failureDescription: String) {
		let alert = UIAlertController(title: failureDescription, message: (error as NSError).localizedDescription, preferredStyle: .alert)
		typealias L = RoutingViewErrorAlertLocalized
		alert.addAction(UIAlertAction(title: L.okButtonTitle, style: .cancel))
		present(alert, animated: true)
	}
	
}
