//
//  TicketType.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/9/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation


class TicketType {
    var name = ""
    var price: NSNumber = 0.00
    
    init (name: String, price: NSNumber){
        self.name = name
        self.price = price
    }
}
