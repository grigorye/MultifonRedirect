//
//  RoutingViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 22.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

@objc protocol AccountDetailsEditor {
	
	var accountNumber: String? { get set }
	var password: String? { get set }

}

class RoutingViewController: UITableViewController {

	typealias L = RoutingViewLocalized
	
	@IBOutlet var versionCell: UITableViewCell!
	@IBOutlet var editAccountCell: UITableViewCell!
	@IBOutlet var accountNumberCell: UITableViewCell!
	@IBOutlet var phoneOnlyRouteCell: UITableViewCell!
	@IBOutlet var multifonOnlyRouteCell: UITableViewCell!
	@IBOutlet var phoneAndMultifonRouteCell: UITableViewCell!
	
	var accountNumber: String? {
		get {
			return string(for: .accountNumber)
		}
		set {
			set(newValue, for: .accountNumber)
		}
	}
	var password: String? {
		get {
			return string(for: .password)
		}
		set {
			set(newValue, for: .password)
		}
	}
	
	func cell(for routing: Routing?) -> UITableViewCell? {
		guard let routing = routing else {
			return nil
		}
		switch routing {
		case .phoneOnly: return phoneOnlyRouteCell
		case .multifonOnly: return multifonOnlyRouteCell
		case .phoneAndMultifon: return phoneAndMultifonRouteCell
		}
	}
	
	func routing(for cell: UITableViewCell) -> Routing {
		switch cell {
		case phoneOnlyRouteCell: return .phoneOnly
		case multifonOnlyRouteCell: return .multifonOnly
		case phoneAndMultifonRouteCell: return .phoneAndMultifon
		default: abort()
		}
	}
	var routeCells: [UITableViewCell] {
		return [
			phoneOnlyRouteCell,
			multifonOnlyRouteCell,
			phoneAndMultifonRouteCell
		]
	}
	var routing: Routing? {
		didSet {
			let checkmarkedCell = cell(for: self.routing)
			for cell in routeCells {
				cell.accessoryType = checkmarkedCell == cell ? .checkmark : .none
			}
		}
	}
	
	func present(_ error: Error, forFailureDescription failureDescription: String) {
		let alert = UIAlertController(title: failureDescription, message: ($(error) as NSError).localizedDescription, preferredStyle: .alert)
		typealias L = RoutingViewErrorAlertLocalized
		alert.addAction(UIAlertAction(title: L.okButtonTitle, style: .cancel))
		self.present(alert, animated: true)
	}
	
	func changeRouting(from cell: UITableViewCell) {
		let newRouting = routing(for: cell)
		let oldRouting = routing
		self.routing = nil
		cell.accessoryType = .detailButton
		change(accountNumber: accountNumber!, password: password!, routing: newRouting) { (error) in
			DispatchQueue.main.async {
				guard nil == error else {
					self.routing = oldRouting
					self.present(error!, forFailureDescription: L.couldNotChangeRoutingTitle)
					return
				}
				self.routing = newRouting
			}
		}
	}
	
	func proceedWithQuery(accountNumber: String, password: String) {
		query(accountNumber: accountNumber, password: password) { (error, routing) in
			DispatchQueue.main.async {
				guard let routing = routing, nil == error else {
					self.present(error!, forFailureDescription: L.couldNotUpdateRoutingTitle)
					return
				}
				self.routing = routing
			}
		}
	}
	
	//
	// MARK: -
	//

	@IBAction func refresh(_ refreshControl: UIRefreshControl) {
		guard let accountNumber = accountNumber, let password = password else {
			refreshControl.endRefreshing()
			return
		}
		query(accountNumber: accountNumber, password: password) { (error, routing) in
			DispatchQueue.main.async {
				refreshControl.endRefreshing()
				guard let routing = routing, nil == error else {
					self.present(error!, forFailureDescription: L.couldNotUpdateRoutingTitle)
					return
				}
				self.routing = routing
			}
		}
	}
	
	@IBAction func unwindFromAccountDetails(_ segue: UIStoryboardSegue) {
		switch segue.identifier! {
		case "cancel": ()
		case "save":
			let accountDetailsEditor = segue.source as! AccountDetailsEditor
			password = accountDetailsEditor.password
			accountNumber = accountDetailsEditor.accountNumber
			refreshControl?.sendActions(for: .valueChanged)
		default: fatalError()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "showAccountDetails"?:
			let accountDetailsEditor = segue.destination as! AccountDetailsEditor
			accountDetailsEditor.accountNumber = accountNumber
			accountDetailsEditor.password = password
		default: ()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		accountNumberCell.detailTextLabel!.text = phoneNumberFromAccountNumber(accountNumber)
		let versionString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)! as! String
		versionCell.detailTextLabel!.text = versionString
	}
}

extension RoutingViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)!
		switch cell {
		case phoneOnlyRouteCell, multifonOnlyRouteCell, phoneAndMultifonRouteCell:
			changeRouting(from: cell)
		default: ()
		}
	}

}
