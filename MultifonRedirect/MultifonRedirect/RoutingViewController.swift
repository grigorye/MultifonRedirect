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
	
	var routing: Routing? {
		didSet {
			let checkmarkedCell = cell(for: routing)
			for cell in routeCells {
				cell.accessoryType = checkmarkedCell == cell ? .checkmark : .none
			}
		}
	}
	
	var lastUpdateDate: Date? {
		get {
			return date(for: .lastUpdateDate)
		}
		set {
			set(newValue, for: .lastUpdateDate)
			updateAccountStatusView()
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)!
		switch cell {
		case phoneOnlyRouteCell, multifonOnlyRouteCell, phoneAndMultifonRouteCell:
			changeRouting(from: cell)
		default: ()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		updateAccountStatusView()
		let versionString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)! as! String
		versionCell.detailTextLabel!.text = versionString
	}
}

extension RoutingViewController {
	
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

}

extension RoutingViewController {

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
	
	//
	// MARK: -
	//

	func updateAccountStatusView() {
		accountNumberCell.detailTextLabel!.text = phoneNumberFromAccountNumber(accountNumber) ?? L.phoneNumberPlaceholder
		refreshControl!.attributedTitle = NSAttributedString(string: L.updated(at: lastUpdateDate))
	}
	
	func present(_ error: Error, forFailureDescription failureDescription: String) {
		let alert = UIAlertController(title: failureDescription, message: ($(error) as NSError).localizedDescription, preferredStyle: .alert)
		typealias L = RoutingViewErrorAlertLocalized
		alert.addAction(UIAlertAction(title: L.okButtonTitle, style: .cancel))
		present(alert, animated: true)
	}
	
	//
	// MARK: -
	//

	func proceedWithChangeRouting(_ error: Error?, oldRouting: Routing?, newRouting: Routing) {
		guard nil == error else {
			routing = oldRouting
			updateAccountStatusView()
			present(error!, forFailureDescription: L.couldNotChangeRoutingTitle)
			return
		}
		routing = newRouting
		lastUpdateDate = Date()
	}
	
	func changeRouting(from cell: UITableViewCell) {
		let newRouting = routing(for: cell)
		let oldRouting = routing
		routing = nil
		cell.accessoryType = .detailButton
		change(accountNumber: accountNumber!, password: password!, routing: newRouting) { (error) in
			DispatchQueue.main.async {
				self.proceedWithChangeRouting(error, oldRouting: oldRouting, newRouting: newRouting)
			}
		}
	}

	//
	// MARK: -
	//

	func proceedWithRefresh(for refreshControl: UIRefreshControl, _ error: Error?, _ updatedRouting: Routing?) {
		guard let updatedRouting = updatedRouting, nil == error else {
			updateAccountStatusView()
			present(error!, forFailureDescription: L.couldNotUpdateRoutingTitle)
			return
		}
		routing = updatedRouting
		lastUpdateDate = Date()
		refreshControl.endRefreshing()
	}
	
	@IBAction func refresh(_ refreshControl: UIRefreshControl) {
		guard let accountNumber = accountNumber, let password = password else {
			refreshControl.endRefreshing()
			return
		}
		query(accountNumber: accountNumber, password: password) { (error, updatedRouting) in
			DispatchQueue.main.async {
				self.proceedWithRefresh(for: refreshControl, error, updatedRouting)
			}
		}
	}

}
