//
//  PaymentInfo.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit

class PaymentInfo: NSObject {
    var selectedAmount: Float?
    var selectedPaymentMethod: PaymentMethod?
    var selectedIssuer: Issuer?
    var selectedInstallment: Installment?
}
