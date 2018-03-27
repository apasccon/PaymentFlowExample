//
//  Issuer.swift
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import Foundation
import ObjectMapper

class Issuer: NSObject, Mappable {
    var issuerId: String?
    var name: String?
    var thumbnailUrl: String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        issuerId <- map["id"]
        name <- map["name"]
        thumbnailUrl <- map["secure_thumbnail"]
    }
    
}

