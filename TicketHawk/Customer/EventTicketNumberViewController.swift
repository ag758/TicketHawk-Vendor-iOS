//
//  EventTicketNumberViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 8/21/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI

internal class TicketTypeTableViewCell: UITableViewCell{
    
    @IBOutlet weak var ticketTitle: UITextView!
    @IBOutlet weak var ticketPrice: UITextView!
    @IBOutlet weak var quantity: CustomUITextField!
}

class EventTicketNumberViewController: UIViewController
, UITableViewDelegate, UITableViewDataSource{
    
   
    
    
    var eventID: String?
    var vendorID: String?
    
    var ref: DatabaseReference?
    
    var ticketTypes: [TicketType] = []

    @IBOutlet weak var quantityTableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var subtotalTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = SplitViewController.ref
        
        self.quantityTableView.delegate = self
        self.quantityTableView.dataSource = self
        
        self.quantityTableView.rowHeight = 100
        
        confirmButton.backgroundColor = .clear
        confirmButton.layer.cornerRadius = 25
        confirmButton.layer.borderWidth = 2
        confirmButton.layer.borderColor = UIColor.white.cgColor
        
        confirmButton.setTitleColor(UIColor.white, for: .normal)
        
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        confirmButton.setTitle("Confirm Purchase", for: .normal)

        // Do any additional setup after loading the view.
        
        loadTicketTypes()
    }
    
    func loadTicketTypes(){
        self.ref?.child("vendors").child(vendorID ?? "").child("events").child(eventID ?? "").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let event = snapshot.value as? NSDictionary
            
            let tickets = event!["ticketTypes"] as? Dictionary ?? [:]
            
            for (ticketname, ticketprice) in tickets {
                self.ticketTypes.append(TicketType(name: ticketname as! String, price: ticketprice as! NSNumber))
                self.quantityTableView.reloadData()
            }
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketTypeTableViewCell", for: indexPath) as! TicketTypeTableViewCell
        
        
        cell.ticketTitle.text = ticketTypes[indexPath.row].name
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let number = formatter.string(from:  ticketTypes[indexPath.row].price) {
            cell.ticketPrice.text = number
        }
        
        cell.quantity.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateTotalPrice()
    }
    
    func updateTotalPrice(){
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        var total = 0.00
        for cell in self.quantityTableView.visibleCells {
            let c = cell as! TicketTypeTableViewCell
            let q = Int(c.quantity.text ?? "0")
            
            
            
            let p = formatter.number(from: c.ticketPrice.text)
            
            let priceDouble = Double(exactly: p!)
            
            total = total + Double(q ?? 0) * (priceDouble ?? 0)
        }
        
        self.subtotalTextView.text = "Subtotal: " + (formatter.string(from: NSNumber(value: total)) ?? "$0.00")
        
        
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
        //check if quantity is below max indiv
        //purchase quantity
        
        //check if quantity + going < totalVenueCapacity
        
        //check if event exists
        
        //Send price to square
        
        //Upon success:
            //add quantity to going
            //add total sales price to total sales
            //add tickets to customer's tickets
            //copy tickets to vendor's tickets
    }
    

}
