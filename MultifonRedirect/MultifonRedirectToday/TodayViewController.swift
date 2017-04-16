//
//  TodayViewController.swift
//  MultifonRedirectToday
//
//  Created by Grigory Entin on 10.04.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import MultifonRedirectSupport
import GEFoundation
import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	
	@IBOutlet var routingLabel: UILabel!
	@IBOutlet var notLoggedInLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		scheduledForDeinit.append(bindAccountAccessor())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		_ = $(activeDisplayMode)
	}
	
	var scheduledForDeinit = ScheduledHandlers()
	deinit {
		scheduledForDeinit.perform()
	}
	
}

extension TodayViewController: AccountPossessor {
	
	typealias L = TodayLocalized
	
	func accountLastRoutingDidChange() {
		routingLabel.text = {
			switch accountController?.lastRouting {
			case .phoneOnly?:
				return L.phoneOnlyRoutingTitle
			case .multifonOnly?:
				return L.multifonOnlyRoutingTitle
			case .phoneAndMultifon?:
				return L.multifonOnlyRoutingTitle
			case nil:
				return L.unknownRoutingTitle
			}
		}()
	}

	func accountControllerDidChange() {
		let isLoggedIn = nil != accountController
		_ = $(isLoggedIn)
		routingLabel.isHidden = !isLoggedIn
		notLoggedInLabel.isHidden = isLoggedIn
	}

	func accountNextRoutingDidChange() {
	}
	
}
