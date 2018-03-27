//
//  PaymentMethod.swift
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import Foundation
import ObjectMapper

class PaymentMethod: NSObject, Mappable {
    var paymentMethodId: String?
    var name: String?
    var typeId: String?
    var status: String?
    var thumbnailUrl: String?
    var minAllowedAmount: Float?
    var maxAllowedAmount: Float?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        paymentMethodId <- map["id"]
        name <- map["name"]
        typeId <- map["payment_type_id"]
        status <- map["status"]
        thumbnailUrl <- map["secure_thumbnail"]
        minAllowedAmount <- map["min_allowed_amount"]
        maxAllowedAmount <- map["max_allowed_amount"]
    }
    
}
