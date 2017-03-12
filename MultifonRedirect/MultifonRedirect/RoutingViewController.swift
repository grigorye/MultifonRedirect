//
//  RoutingViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 22.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

protocol AccountDetailsEditor {
	
	var routingController: RoutingController? { get set }

}

class RoutingViewController: UITableViewController {

	typealias L = RoutingViewLocalized

	@IBOutlet var accountNumberCell: UITableViewCell!
	@IBOutlet var accountNumberCellLabel: UILabel!

	@IBOutlet var phoneOnlyRouteCell: UITableViewCell!
	@IBOutlet var multifonOnlyRouteCell: UITableViewCell!
	@IBOutlet var phoneAndMultifonRouteCell: UITableViewCell!
	
	var loggedIn: Bool {
		return nil != routingController
	}
	
	lazy var routingControllerImp: RoutingController! = {
		guard let accountNumber = savedAccountNumber, let password = savedPassword else {
			return nil
		}
		return RoutingController(accountNumber: accountNumber, password: password) … {
			$0.lastRouting = savedLastRouting
			$0.lastUpdateDate = savedLastUpdateDate
		}
	}()

	var routingController: RoutingController! {
		set {
			routingControllerImp = newValue
			if let routingController = newValue {
				savedAccountNumber = routingController.accountNumber
				savedPassword = routingController.password
			} else {
				savedAccountNumber = nil
				savedPassword = nil
			}
			updateRouting(from: routingController)
			updateAccountStatusView()
		}
		get {
			return routingControllerImp
		}
	}

	var routing: Routing? {
		didSet {
			let cellForActiveRouting = cell(for: routing)
			for cell in routeCells {
				(cell as! RouteActivationAwareCell).setRouteActivationState(cellForActiveRouting == cell ? .active : .inactive)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)!
		switch cell {
		case phoneOnlyRouteCell, multifonOnlyRouteCell, phoneAndMultifonRouteCell:
			changeRouting(from: cell)
		case accountNumberCell:
			tableView.deselectRow(at: indexPath, animated: true)
			if loggedIn {
				typealias L = RoutingViewAccountAlertLocalized
				let alert = UIAlertController(title: L.title, message: phoneNumberFromAccountNumber(routingController.accountNumber), preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: L.logOutTitle, style: .default) { _ in
					self.logout()
				})
				alert.addAction(UIAlertAction(title: L.cancelTitle, style: .cancel))
				present(alert, animated: true)
			} else {
				performSegue(withIdentifier: "showAccountDetails", sender: self)
			}
		default: ()
		}
	}

	var scheduledForViewDidAppear = [() -> ()]()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		for i in scheduledForViewDidAppear { i() }
		scheduledForViewDidAppear = []
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		accountNumberCellLabel.textColor = view.tintColor
		scheduledForViewDidAppear += [{
			self.triggerRefersh()
		}]
		do {
			let notificationCenter = NotificationCenter.default
			let observer = notificationCenter.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { [unowned self] (_) in
				self.triggerRefersh()
			}
			scheduledForDeinit += [{
				notificationCenter.removeObserver(observer)
				()
			}]
		}
		routing = routingController?.lastRouting
		updateAccountStatusView()
	}
	
	var scheduledForDeinit = [() -> ()]()
	deinit {
		for i in scheduledForViewDidAppear { i() }
		scheduledForDeinit = []
	}
}

extension RoutingViewController {
	
	@IBAction func unwindFromAccountDetails(_ segue: UIStoryboardSegue) {
		switch segue.identifier! {
		case "cancel": ()
		case "loggedIn":
			let accountDetailsEditor = segue.source as! AccountDetailsEditor
			routingController = accountDetailsEditor.routingController!
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
		default: fatalError()
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
		accountNumberCellLabel.text = loggedIn ? L.accountTitle(for: phoneNumberFromAccountNumber(routingController.accountNumber)!) : L.logInTitle
		refreshControl!.attributedTitle = !loggedIn ? nil : NSAttributedString(string: L.updated(at: routingController.lastUpdateDate))
		for cell in routeCells {
			cell.textLabel!.isEnabled = loggedIn
		}
	}
	
	//
	// MARK: -
	//

	func logout() {
		self.routingController = nil
	}
	
	func updateRouting(from routingController: RoutingController?) {
		guard let routingController = routingController else {
			routing = nil
			savedLastRouting = nil
			savedLastUpdateDate = nil
			return
		}
		routing = routingController.lastRouting!
		savedLastRouting = routingController.lastRouting!
		savedLastUpdateDate = routingController.lastUpdateDate!
	}
	
	func proceedWithChangeRouting(_ error: Error?, through routingController: RoutingController, from oldRouting: Routing?) {
		guard nil == error else {
			routing = oldRouting
			updateAccountStatusView()
			present(error!, forFailureDescription: L.couldNotChangeRoutingTitle)
			return
		}
		updateRouting(from: routingController)
	}
	
	func changeRouting(from cell: UITableViewCell) {
		let newRouting = routing(for: cell)
		let oldRouting = routing
		routing = nil
		(cell as! RouteActivationAwareCell).setRouteActivationState(.activating)
		let routingController = self.routingController!
		routingController.change(routing: newRouting) { (error) in
			DispatchQueue.main.async {
				self.proceedWithChangeRouting(error, through: routingController, from: oldRouting)
			}
		}
	}
	
	func triggerRefersh() {
		self.refreshControl?.sendActions(for: .valueChanged)
	}

	//
	// MARK: -
	//

	func proceedWithRefresh(_ error: Error?, through routingController: RoutingController) {
		guard nil == error else {
			updateAccountStatusView()
			present(error!, forFailureDescription: L.couldNotUpdateRoutingTitle)
			return
		}
		updateRouting(from: routingController)
	}
	
	@IBAction func refresh(_ refreshControl: UIRefreshControl) {
		guard let routingController = routingController else {
			refreshControl.endRefreshing()
			return
		}
		routingController.query { (error) in
			DispatchQueue.main.async {
				self.proceedWithRefresh(error, through: routingController)
				refreshControl.endRefreshing()
			}
		}
	}

}

