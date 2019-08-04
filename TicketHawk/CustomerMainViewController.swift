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

internal class VendorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vendorProfileImageView: UIImageView!
    @IBOutlet weak var vendorTitleView: UITextView!
    @IBOutlet weak var vendorCategoryView: UITextView!
}

internal class FeaturedEventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleView: UITextView!
    @IBOutlet weak var sellerView: UITextView!
    @IBOutlet weak var dateView: UITextView!
    @IBOutlet weak var priceView: UITextView!
    
}

class CustomerMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    
    
    
    
    var communityKey: String?
    
    var ref: DatabaseReference?
    
    var vendors: [Vendor] = []
    
    var loadedEvents: [Event] = []
    
    var loadedEventsStringIDs: [String] = []
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    @IBOutlet weak var vendorsTableView: UITableView!
    
    @IBOutlet weak var communityTitle: UIButton!
    
    //
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        self.navigationItem.title = ""
        
        // Do any additional setup after loading the view.
        ref = SplitViewController.ref
        
        vendorsTableView.delegate = self
        vendorsTableView.dataSource = self
        vendorsTableView.reloadData()
        vendorsTableView.rowHeight = 70
        
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.reloadData()
        
        
        
        loadCommunity()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.vendorsTableView
            .dequeueReusableCell(withIdentifier: "vendorCell") as! VendorTableViewCell
        
        cell.backgroundColor = SplitViewController.almostBlack
        cell.layer.cornerRadius = 5
        cell.vendorProfileImageView.layer.cornerRadius = 5
        
        cell.vendorTitleView.text = vendors[indexPath.row].name
        cell.vendorCategoryView.text = vendors[indexPath.row].ticketCategory
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let url = URL(string: vendors[indexPath.row].pictureURL!)!
        
        downloadImage(from: url, iv: cell.vendorProfileImageView)
        
        for view in cell.subviews {
            view.isUserInteractionEnabled = false
        }
        
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
    // In this function is the code you must implement to your code project if you want to change size of Collection view
        
        return CGSize(width: eventsCollectionView.bounds.width * 5/6, height: eventsCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCollectionCell", for: indexPath) as! FeaturedEventCollectionViewCell
        
        cell.backgroundColor = SplitViewController.almostBlack
        cell.layer.cornerRadius = 5
        cell.eventImageView.layer.cornerRadius = 5
        
        cell.eventTitleView.text = loadedEvents[indexPath.row].title
        cell.dateView.text = loadedEvents[indexPath.row].dateAndTime
        cell.priceView.text = loadedEvents[indexPath.row].lowestPrice
        cell.sellerView.text = loadedEvents[indexPath.row].creatorName
        
        cell.eventTitleView.textContainer.maximumNumberOfLines = 1
        cell.eventTitleView.textContainer.lineBreakMode = .byTruncatingTail
        
        cell.dateView.textContainer.maximumNumberOfLines = 1
        cell.dateView.textContainer.lineBreakMode = .byTruncatingTail
        
        cell.priceView.textContainer.maximumNumberOfLines = 1
        cell.priceView.textContainer.lineBreakMode = .byTruncatingTail
        
        cell.sellerView.textContainer.maximumNumberOfLines = 1
        cell.sellerView.textContainer.lineBreakMode = .byTruncatingTail
        
        let url = URL(string: loadedEvents[indexPath.row].imageURL!)!
        
        downloadImage(from: url, iv: cell.eventImageView)
        
        for view in cell.subviews {
            view.isUserInteractionEnabled = false
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //var cell : UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "eventViewController") as! EventViewController
        
       next.eventID = loadedEvents[indexPath.row].id
       next.vendorID = loadedEvents[indexPath.row].creatorId
        
    self.navigationController!.pushViewController(next, animated: true)
        
        //self.present(next, animated: true, completion: nil)
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
            
            for _ in 1..<10 {
                let vendorIndex = Int.random(in: 0..<(keys?.count ?? 0))
                
                let vendorId = keys?[vendorIndex] as? String ?? ""
                
                self.ref?.child("vendors").child(vendorId).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    let keys = value?.allKeys
                    
                    let eventIndex = Int.random(in: 0..<(keys?.count ?? 0))
                    
                    let eventId = keys?[eventIndex] as? String ?? ""
                    
                    var isAlreadyAdded = false
                    
                    for e in self.loadedEventsStringIDs {
                        if e == eventId{
                            isAlreadyAdded = true
                        }
                    }
                    
                    if !isAlreadyAdded{
                        self.loadedEventsStringIDs.append(eventId)
                        self.loadEvent(vendorID: vendorId, eventID: eventId)
                    }
                    
                    
                    
                    
                })
            }
            
            
            
        })

        
    }
    
    func loadEvent(vendorID: String, eventID: String){
        
        ref?.child("vendors").child(vendorID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let vendorName = value!["organizationName"] as? String ?? ""
            self.ref?.child("vendors").child(vendorID).child("events").child(eventID).observeSingleEvent(of: .value, with: {(snapshot) in
                
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
                dateFormatter2.dateFormat = "MMM d h:mm a"
                
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
                    
                    let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id, creatorId: Auth.auth().currentUser!.uid, creatorName: vendorName)
                    
                    self.loadedEvents.append(eventInstance)
                    print(self.loadedEvents.count)
                    
                    self.eventsCollectionView.reloadData()
                }
                
            })
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
                    self.vendorsTableView.reloadData()
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
            
            self.vendorsTableView.reloadData()
            //print(self.vendors.count)
            })
            // ...
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, iv: UIImageView) {
        print("Download Started")
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                
                
                DispatchQueue.main.async() {
                    iv.image = UIImage(data: data)
                }
            }
        }
        
    }
    
    @IBAction func communityButtonIsPressed(_ sender: Any) {
    }
    
    

}
