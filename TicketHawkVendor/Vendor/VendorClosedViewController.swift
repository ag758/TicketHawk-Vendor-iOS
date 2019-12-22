//
//  VendorClosedViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/27/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ClosedEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var going: UITextView!
    @IBOutlet weak var grossRevenue: UITextView!
    @IBOutlet weak var netRevenue: UITextView!
    
}

class VendorClosedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    
    var ref: DatabaseReference?
    
    var closedEvents: [ClosedEvent] = []

    @IBOutlet weak var closedEventsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Constants.ref
        
        loadClosedEvents()
        
        self.closedEventsTableView.delegate = self
        self.closedEventsTableView.dataSource = self
        
        self.closedEventsTableView.rowHeight = 120
        

        // Do any additional setup after loading the view.
    }
    
    func loadClosedEvents(){
        let query = ref?.child("vendors").child(Auth.auth().currentUser!.uid).child("closedEvents")
        
        query?.observe(.childAdded, with: { (snapshot) in
            
            let event = snapshot.value as? NSDictionary ?? [:]
            
            let title = event["eventTitle"] as! String
            let endDateAndTime = event["endDateAndTime"] as? String ?? "No Date Found"
            let pictureURL = event["pictureURL"] as? String ?? ""
            let tickets = event["ticketTypes"] as? Dictionary ?? [:]
            let id = event["key"] as? String ?? ""
            
            let grossSales = event["grossSales"] as? Int ?? 0
            let netSales = event["netSales"] as? Int ?? 0
            
            let going = event["going"] as? Int ?? 0
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let d1: Date = dateFormatter.date(from: endDateAndTime)!
            
            let closedEventInstance = ClosedEvent(key: id, eventTitle: title, grossSales: grossSales, netSales: netSales, closedDate: d1, going: going)
            
            self.closedEvents.append(closedEventInstance)
            self.closedEvents = self.sortTableViewByTime(events: self.closedEvents)
            self.closedEventsTableView.reloadData()
            
            print(self.closedEvents.count)
        })
    }
    
    func sortTableViewByTime(events: [ClosedEvent]) -> [ClosedEvent] {
        var eventsMut = events
        var x = 0
        while (x < events.count-1) {
            var closestInt = x
            for y in x+1...events.count-1 {
                if compareDates(date1: events[x].closedDate, date2: events[y].closedDate) == true{
                    closestInt = y
                }
            }
            //swap shortest and x
            eventsMut.swapAt(x, closestInt)
            x = x+1
        }
        
        return eventsMut
    }
    
    func compareDates (date1: Date, date2: Date) -> Bool {
        
        if (date1 < date2){
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.closedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        let cell = self.closedEventsTableView
            .dequeueReusableCell(withIdentifier: "closedCell") as! ClosedEventTableViewCell
        
        cell.title.text = self.closedEvents[indexPath.row].eventTitle
            + " | " + dateFormatter.string(from: self.closedEvents[indexPath.row].closedDate)
        cell.going.text = "Went: " + String(self.closedEvents[indexPath.row].going)
        
        
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let n1 = formatter.string(from:  NSNumber(value: Float(self.closedEvents[indexPath.row].grossSales) / 100)) {
            
            if let n2 = formatter.string(from:  NSNumber(value: Float(self.closedEvents[indexPath.row].netSales) / 100)) {
                
                cell.netRevenue.text = "Net: " + n2
                cell.grossRevenue.text = "Gross: " + n1
            }
        }
        
        
        cell.selectionStyle = .none
        return cell
    }
    
}
