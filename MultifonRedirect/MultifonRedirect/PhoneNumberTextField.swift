//
//  PhoneNumberTextField.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 01/06/2020.
//  Copyright © 2020 Grigory Entin. All rights reserved.
//

import Foundation
import class PhoneNumberKit.PhoneNumberTextField

class PhoneNumberTextField: PhoneNumberKit.PhoneNumberTextField {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        withPrefix = true
    }
}
