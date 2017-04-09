//
//  RoutingViewController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 22.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import UIKit

class RoutingViewController: UITableViewController, AccountPossessor {

	typealias L = RoutingViewLocalized

	@IBOutlet var accountNumberCell: UITableViewCell!
	@IBOutlet var accountNumberCellLabel: UILabel!

	@IBOutlet var phoneOnlyRouteCell: RouteTableViewCell!
	@IBOutlet var multifonOnlyRouteCell: RouteTableViewCell!
	@IBOutlet var phoneAndMultifonRouteCell: RouteTableViewCell!

	func accountLastRoutingDidChange() {
		let lastRouting = accountController?.lastRouting
		let cellForActiveRouting: RouteTableViewCell? = {
			switch lastRouting {
			case nil:
				return nil
			case .some(let routing):
				return cell(for: routing)
			}
		}()
		for cell in routeCells {
			cell.setRouteActivationState((cellForActiveRouting == cell) ? .active : .inactive)
		}
	}
	
	var nextRouteCell: RouteTableViewCell? {
		didSet {
			oldValue?.setRouteActivationState(.inactive)
			$(nextRouteCell)?.setRouteActivationState(.activating)
		}
	}
	
	func accountNextRoutingDidChange() {
		nextRouteCell = cell(for: accountController?.nextRouting)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)!
		switch cell {
		case phoneOnlyRouteCell, multifonOnlyRouteCell, phoneAndMultifonRouteCell:
			setRouting(from: cell)
		case accountNumberCell:
			tableView.deselectRow(at: indexPath, animated: true)
			switch accountController {
			case .some(let accountController):
				typealias L = RoutingViewAccountAlertLocalized
				let alert = UIAlertController(title: L.title, message: phoneNumberFromAccountNumber(accountController.accountParams.accountNumber), preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: L.logOutTitle, style: .default) { _ in
					self.logout()
				})
				alert.addAction(UIAlertAction(title: L.cancelTitle, style: .cancel))
				present(alert, animated: true)
			case nil:
				performSegue(withIdentifier: "showAccountDetails", sender: self)
			}
		default: ()
		}
	}

	//
	// MARK: -
	//
	
	var didUpdateRefreshControlForCurrentDrag = false
	
	func updateRefreshControl() {
		refreshControl!.attributedTitle = {
			switch accountController {
			case .some(let accountController):
				return NSAttributedString(string: L.updated(at: accountController.lastUpdateDate))
			case nil:
				return NSAttributedString(string: L.refreshNotPossibleTitle)
			}
		}()
	}
	
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		updateRefreshControl()
		didUpdateRefreshControlForCurrentDrag = true
	}
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		didUpdateRefreshControlForCurrentDrag = false
	}
	
	//
	// MARK: -
	//
	
	var scheduledForViewDidAppear = [() -> ()]()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		for i in scheduledForViewDidAppear { i() }
		scheduledForViewDidAppear = []
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.registerAccountPossesor()
		scheduledForDeinit.append {
			self.unrergisterAccountPossesor()
		}
		accountNumberCellLabel.textColor = view.tintColor
		scheduledForViewDidAppear.append {
			if nil != self.accountController {
				self.triggerRefersh()
			}
		}
	}
	
	var scheduledForDeinit = [() -> ()]()
	deinit {
		for i in scheduledForDeinit { i() }
		scheduledForDeinit = []
	}
}

extension RoutingViewController {
	
	@IBAction func unwindFromAccountDetails(_ segue: UIStoryboardSegue) {
		switch segue.identifier! {
		case "cancel": ()
		case "loggedIn": ()
		default: fatalError()
		}
	}

}

extension RoutingViewController {

	func cell(for routing: Routing?) -> RouteTableViewCell? {
		guard let routing = routing else {
			return nil
		}
		switch routing {
		case .phoneOnly: return phoneOnlyRouteCell
		case .multifonOnly: return multifonOnlyRouteCell
		case .phoneAndMultifon: return phoneAndMultifonRouteCell
		}
	}
	
	func routingFor(_ cell: UITableViewCell) -> Routing {
		switch cell {
		case phoneOnlyRouteCell: return .phoneOnly
		case multifonOnlyRouteCell: return .multifonOnly
		case phoneAndMultifonRouteCell: return .phoneAndMultifon
		default: fatalError()
		}
	}
	
	var routeCells: [RouteTableViewCell] {
		return [
			phoneOnlyRouteCell,
			multifonOnlyRouteCell,
			phoneAndMultifonRouteCell
		]
	}
	
	//
	// MARK: -
	//

	func accountControllerDidChange() {
		accountNumberCellLabel.text = {
			switch accountController {
			case nil:
				return L.logInTitle
			case .some(let accountController):
				return L.accountTitle(for: phoneNumberFromAccountNumber(accountController.accountParams.accountNumber)!)
			}
		}()
		let loggedIn = nil != accountController
		for cell in routeCells {
			cell.enabled = loggedIn
		}
		if !loggedIn {
			accountLastRoutingDidChange()
		}
	}
	
	func triggerRefersh() {
		self.refreshControl?.sendActions(for: .valueChanged)
	}

	//
	// MARK: -
	//
	
	func setRouting(from cell: UITableViewCell) {
		let newRouting = routingFor(cell)
		let action = would(.setRoutingFromPicker(newRouting))
		accountController!.setRouting(newRouting) { (erring) in
			DispatchQueue.main.async {
				if let error = erring.error {
					self.present(error, forFailureDescription: L.couldNotChangeRoutingTitle)
					action.failed(due: error)
					return
				}
				action.succeeded()
			}
		}
	}
	
	//
	// MARK: -
	//
	
	@IBAction func refresh(_ refreshControl: UIRefreshControl) {
		let action = would(.refreshRoutingFromRefrseshControl); let preflight: Preflight?; defer { action.preflight = preflight }
		guard let accountController = accountController else {
			refreshControl.endRefreshing()
			preflight = .cancelled(due: .noAccountConnected)
			return
		}
		preflight = nil
		_ = accountController.refreshRouting { (erring) in
			DispatchQueue.main.async {
				refreshControl.endRefreshing()
				if let error = erring.error {
					action.failed(due: error)
					self.present(error, forFailureDescription: L.couldNotUpdateRoutingTitle)
					return
				}
				action.succeeded()
			}
		}
	}

}
