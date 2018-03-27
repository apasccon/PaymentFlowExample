//
//  Installment.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import Foundation
import ObjectMapper

class Installment: NSObject, Mappable {
    var installments: Int?
    var recommendedMessage: String?
    var installmentAmount: Float?
    var totalAmount: Float?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        installments <- map["installments"]
        recommendedMessage <- map["recommended_message"]
        installmentAmount <- map["installment_amount"]
        totalAmount <- map["total_amount"]
    }
}
