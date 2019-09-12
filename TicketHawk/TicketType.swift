//
//  TicketType.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/9/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation


class TicketType: Hashable{
    static func == (lhs: TicketType, rhs: TicketType) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name = ""
    var price: Int = 0
    
    init (name: String, price: Int){
        self.name = name
        self.price = price
    }
}
