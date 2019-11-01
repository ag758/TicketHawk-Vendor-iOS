//
//  Ticket.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/2/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation

class Ticket: Equatable {
    
    
    static func == (lhs: Ticket, rhs: Ticket) -> Bool {
        return lhs.key == rhs.key
    }
    
    
    var key = ""
    var eventTitle = ""
    var ticketType = ""
    var userName = ""
    var dateAndTime = ""
    var location = ""
    
    init (key: String, eventTitle: String, ticketType: String,
          userName: String, dateAndTime: String, location: String){
        self.key = key
        self.eventTitle = eventTitle
        self.ticketType = ticketType
        self.userName = userName
        self.dateAndTime = dateAndTime
        self.location = location
    }
    
}
