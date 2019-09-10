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
UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    
    
    
    @IBOutlet weak var vendorsSearchBar: UISearchBar!
    
    var communityKey: String?
    
    var ref: DatabaseReference?
    
    var vendors: [Vendor] = []
    
    var loadedEvents: [Event] = []
    
    var loadedEventsStringIDs: [String] = []
    
    var filteredVendors: [Vendor] = []
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    
    @IBOutlet weak var vendorsTableView: UITableView!
    
    @IBOutlet weak var communityTitle: UIButton!
    //
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SplitViewController.customerMainVC = self

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
        
        vendorsTableView.layer.cornerRadius = 5
        
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.reloadData()
        
        vendorsSearchBar.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        loadCommunity()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.vendorsSearchBar.endEditing(true)
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredVendors = searchText.isEmpty ? vendors : vendors.filter({(v: Vendor) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return ((v.name ?? "").range(of: searchText, options: .caseInsensitive) != nil || (v.ticketCategory ?? "").range(of: searchText, options: .caseInsensitive) != nil )
        })
        
        vendorsTableView.reloadData()
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        self.vendorsSearchBar.endEditing(true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row < filteredVendors.count){
            let cell = self.vendorsTableView
                .dequeueReusableCell(withIdentifier: "vendorCell") as! VendorTableViewCell
            
            cell.backgroundColor = SplitViewController.almostBlack
            //cell.layer.cornerRadius = 5
            cell.vendorProfileImageView.layer.cornerRadius = 5
            
            cell.vendorTitleView.text = filteredVendors[indexPath.row].name
            cell.vendorCategoryView.text = filteredVendors[indexPath.row].ticketCategory
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let url = URL(string: filteredVendors[indexPath.row].pictureURL!) ?? URL(string: "www.apple.com")!
            
            cell.vendorProfileImageView.image = UIImage()
            downloadImage(from: url, iv: cell.vendorProfileImageView)
            
            for view in cell.subviews {
                view.isUserInteractionEnabled = false
            }
            return cell
        }
        else {
            return UITableViewCell()
        }
        
       
        
        
        
        
        
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
        
        if (indexPath.row < loadedEvents.count){
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
            
            let url = URL(string: loadedEvents[indexPath.row].imageURL ?? "www.apple.com") ?? URL(string: "www.apple.com")!
            
            cell.eventImageView.image = UIImage()
            downloadImage(from: url, iv: cell.eventImageView)
            
            for view in cell.subviews {
                view.isUserInteractionEnabled = false
            }
            
            
            return cell
        } else {
            return UICollectionViewCell()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "eventViewController") as! EventViewController
        
        next.vendorID = self.loadedEvents[indexPath.row].creatorId
        next.eventID = self.loadedEvents[indexPath.row].id
        self.navigationController!.pushViewController(next, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Transition to Ticket Generation
        let next = self.storyboard!.instantiateViewController(withIdentifier: "customerVendorListViewController") as! CustomerVendorListViewController
        
        next.vendorID = self.filteredVendors[indexPath.row].id
        self.navigationController!.pushViewController(next, animated: true)
    }
    
    func loadCommunity(){
        
        print("communityloaded")
        
        
        //Reset State
        self.vendors = []
        self.loadedEvents = []
        self.loadedEventsStringIDs = []
        self.filteredVendors = []
        
        let userID = Auth.auth().currentUser?.uid
        ref?.child("customers").child(userID ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let cKey = value!["primaryCommunity"] as? String ?? ""
            self.communityKey = cKey
            
            self.communityTitle.setTitle(self.communityKey ?? "", for: UIControl.State.normal)
            
            
            //Load Events and vendors things using Community Key
            //print(self.communityKey!)
            self.loadCommunityEvents()
            self.loadCommunityVendorIDS()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func loadCommunityEvents(){
        
        ref?.child("communities").child(communityKey ?? "").child("vendors").observeSingleEvent(of: .value, with: { (snapshot) in
            
                let value = snapshot.value as? NSDictionary
                let keys = value?.allKeys
            
            
                    for k in keys ?? [] {
                        
                        let vendorId = k as? String ?? ""
                        
                        self.ref?.child("vendors").child(vendorId).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            let value = snapshot.value as? NSDictionary
                            let keys = value?.allKeys
                            
                            let range = (0..<(keys?.count ?? 0))
                            if !range.isEmpty{
                                let eventIndex = Int.random(in: range)
                                
                                let eventId = keys?[eventIndex] as? String ?? ""
                                
                                var isAlreadyAdded = false
                                
                                for e in self.loadedEventsStringIDs {
                                    if e == eventId{
                                        isAlreadyAdded = true
                                    }
                                }
                                
                                self.ref?.child("vendors").child(vendorId).child("events").child(eventId).observeSingleEvent(of: .value, with: {(snapshot) in
                                    
                                        let value = snapshot.value as? NSDictionary
                                    
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    
                                    let endDate = dateFormatter.date(from: value?["endDateAndTime"] as? String ?? "")
                                    
                                    if !isAlreadyAdded && endDate ?? Date() >= Date(){
                                        self.loadedEventsStringIDs.append(eventId)
                                        self.loadEvent(vendorID: vendorId, eventID: eventId)
                                    }
                                    
                                    })
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
                
                let title = event!["eventTitle"] as? String ?? ""
                var startDateAndTime = event!["startDateAndTime"] as? String ?? "No Date Found"
                let pictureURL = event!["pictureURL"] as? String ?? ""
                let tickets = event!["ticketTypes"] as? Dictionary ?? [:]
                let id = event!["key"] as? String ?? ""
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                let d1: Date = dateFormatter.date(from: startDateAndTime) ?? Date()
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.amSymbol = "AM"
                dateFormatter2.pmSymbol = "PM"
                dateFormatter2.dateFormat = "MMM d, h:mm a"
                
                startDateAndTime = dateFormatter2.string(from: d1)
                
                var minimumprice: Double = Double.greatestFiniteMagnitude
                for (_, ticketprice) in tickets {
                    if ((ticketprice as? Double ?? 0) < minimumprice){
                        minimumprice = ticketprice as? Double ?? 0
                    }
                }
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                
                if let number = formatter.string(from: NSNumber(value: minimumprice)) {
                    print(number)
                    
                    let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id, creatorId: vendorID, creatorName: vendorName)
                    
                    //self.loadedEvents.append(eventInstance)
                    self.loadedEvents = self.randomAppend(array: self.loadedEvents, object: eventInstance) as! [Event]
                    
                    DispatchQueue.global(qos: .background).async {
                        print("This is run on the background queue")
                        
                        //self.loadedEvents.shuffle()
                        print(self.loadedEvents.count)
                        
                        DispatchQueue.main.async {
                            print("This is run on the main queue, after the previous code in outer block")
                            self.eventsCollectionView.reloadData()
                        }
                        
                        
                    }
                    
                    
                    
                    
                    
                    
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
            
            
            print("pURL " + pictureURL)
            
            let ticketCategory = value?["ticketCategory"] as? String ?? ""
            
            
            let vendorToBeAdded = Vendor(id: vendorid, name: orgName, pictureURL: pictureURL, ticketCategory: ticketCategory)
            //self.vendors.append(vendorToBeAdded)
            self.vendors = self.randomAppend(array: self.vendors, object: vendorToBeAdded) as! [Vendor]
            
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                //self.vendors.shuffle()
                
                
                
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    
                    self.filteredVendors = self.vendors
                    
                    self.vendorsTableView.reloadData()
                }
            }
            
            
            
            
            //print(self.vendors.count)
            })
            // ...
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func randomAppend(array: [NSObject], object: NSObject) -> [NSObject]{
        var returnedArray = array
        returnedArray.insert(object, at: Int.random(in: 0 ... returnedArray.count))
        return returnedArray
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
