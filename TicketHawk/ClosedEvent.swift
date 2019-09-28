//
//  ClosedEvent.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/27/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import Foundation

class ClosedEvent: Equatable {
    
    
    static func == (lhs: ClosedEvent, rhs: ClosedEvent) -> Bool {
        return lhs.key == rhs.key
    }
    
    
    var key = ""
    var eventTitle = ""
    var grossSales: Int = 0
    var netSales: Int = 0
    var closedDate: Date = Date()
    
    init (key: String, eventTitle: String, grossSales: Int,
          netSales: Int, closedDate: Date){
        self.key = key
        self.eventTitle = eventTitle
        self.grossSales = grossSales
        self.netSales = netSales
        self.closedDate = closedDate
    }
    
}
