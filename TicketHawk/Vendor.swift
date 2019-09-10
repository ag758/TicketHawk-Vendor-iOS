//
//  Vendor.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/30/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation

class Vendor: NSObject {
    
    var id: String?
    var name: String?
    var pictureURL: String?
    var ticketCategory: String?
    
    init (id: String, name: String, pictureURL: String, ticketCategory: String){
        self.id = id
        self.name = name
        self.pictureURL = pictureURL
        self.ticketCategory = ticketCategory
    }
    
    
    static func ==(lhs: Vendor, rhs: Vendor) -> Bool {
        return lhs.id == rhs.id
    }
}
