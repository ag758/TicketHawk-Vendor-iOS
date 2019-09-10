//
//  Event.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/14/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation

class Event: NSObject {
    var title: String?
    var dateAndTime: String?
    var lowestPrice: String?
    var imageURL: String?
    var id: String?
    var creatorId: String?
    var creatorName: String?
    
    init (title: String, dateAndTime: String, lowestPrice: String, imageURL: String, id: String, creatorId: String, creatorName: String){
        self.title = title
        self.dateAndTime = dateAndTime
        self.lowestPrice = lowestPrice
        self.imageURL = imageURL
        self.id = id
        self.creatorId = creatorId
        self.creatorName = creatorName
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
}
