//
//  Event.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/14/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation

class Event: Equatable {
    var title: String?
    var dateAndTime: String?
    var lowestPrice: String?
    var imageURL: String?
    var id: String?
    
    init (title: String, dateAndTime: String, lowestPrice: String, imageURL: String, id: String){
        self.title = title
        self.dateAndTime = dateAndTime
        self.lowestPrice = lowestPrice
        self.imageURL = imageURL
        self.id = id
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
}
