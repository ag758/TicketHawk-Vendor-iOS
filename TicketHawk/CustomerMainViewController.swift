//
//  CustomerMainViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/6/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI

class CustomerMainViewController: UIViewController {
    
    var communityKey: String?
    
    var ref: DatabaseReference?
    
    var vendors: [Vendor] = []
    
    var loadedEvents: [Event] = []
    
    @IBOutlet weak var communityTitle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        // Do any additional setup after loading the view.
        ref = SplitViewController.ref
        loadCommunity()
    }
    
    func loadCommunity(){
        
        let userID = Auth.auth().currentUser?.uid
        ref!.child("customers").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let cKey = value!["primaryCommunity"] as? String ?? ""
            self.communityKey = cKey
            
            self.communityTitle.setTitle(self.communityKey!, for: UIControl.State.normal)
            
            
            //Load Events and vendors things using Community Key
            //print(self.communityKey!)
            self.loadCommunityEvents()
            self.loadCommunityVendorIDS()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func loadCommunityEvents(){
        
        ref?.child("communities").child(communityKey!).child("vendors").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let keys = value?.allKeys
            
            let vendorIndex = Int.random(in: 0..<(keys?.count ?? 0))
            
            let vendorId = keys?[vendorIndex] as? String ?? ""
            
            self.ref?.child("vendors").child(vendorId).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let keys = value?.allKeys
                
                let eventIndex = Int.random(in: 0..<(keys?.count ?? 0))
                
                let eventId = keys?[eventIndex] as? String ?? ""
                
                var isAlreadyAdded = false
                
                for e in self.loadedEvents {
                    if e.id == eventId{
                        isAlreadyAdded = true
                    }
                }
                
                if !isAlreadyAdded{
                    self.loadEvent(vendorID: vendorId, eventID: eventId)
                }
                
                
                
                
                })
            
        })

        
    }
    
    func loadEvent(vendorID: String, eventID: String){
        ref?.child("vendors").child(vendorID).child("events").child(eventID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let event = snapshot.value as? NSDictionary
            
            let title = event!["eventTitle"] as! String
            var startDateAndTime = event!["startDateAndTime"] as? String ?? "No Date Found"
            let pictureURL = event!["pictureURL"] as? String ?? ""
            let tickets = event!["ticketTypes"] as? Dictionary ?? [:]
            let id = event!["key"] as? String ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let d1: Date = dateFormatter.date(from: startDateAndTime)!
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.amSymbol = "AM"
            dateFormatter2.pmSymbol = "PM"
            dateFormatter2.dateFormat = "MMMM dd h:mm a"
            
            startDateAndTime = dateFormatter2.string(from: d1)
            
            var minimumprice: Double = Double.greatestFiniteMagnitude
            for (_, ticketprice) in tickets {
                if ((ticketprice as! Double) < minimumprice){
                    minimumprice = ticketprice as! Double
                }
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            if let number = formatter.string(from: NSNumber(value: minimumprice)) {
                print(number)
                
                let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id, creatorId: Auth.auth().currentUser!.uid)
                
                self.loadedEvents.append(eventInstance)
                print(self.loadedEvents.count)
            }
            
            })
    }
    
    
    
    
    func loadCommunityVendorIDS(){
        let query = ref?.child("communities").child(communityKey!).child("vendors")
        
        query?.observe(.childAdded, with: { (snapshot) in
            
            let vendor = snapshot.value as? NSDictionary
            let i = vendor!["id"] as? String ?? ""
            
            self.loadCommunityVendorDetails(vendorid: i)
            
        })
        query?.observe(.childRemoved, with: { (snapshot) in
            let vendor = snapshot.value as? NSDictionary
            let i = vendor!["id"] as? String ?? ""
            
            for v in self.vendors {
                if v.id == i {
                    self.vendors.remove(at: self.vendors.index(of: v)!)
                }
            }
            
        })
    }
    
    func loadCommunityVendorDetails(vendorid: String){
        
        ref?.child("vendors").child(vendorid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            ///If no value exists -- means false
            let orgName = value?["organizationName"] as? String ?? ""
            let pictureURL = value?["organizationProfileImage"] as? String ?? ""
            let ticketCategory = value?["ticketCategory"] as? String ?? ""
            
            
            let vendorToBeAdded = Vendor(id: vendorid, name: orgName, pictureURL: pictureURL, ticketCategory: ticketCategory)
            self.vendors.append(vendorToBeAdded)
            //print(self.vendors.count)
            })
            // ...
        
    }
    
    @IBAction func communityButtonIsPressed(_ sender: Any) {
    }
    
    

}
