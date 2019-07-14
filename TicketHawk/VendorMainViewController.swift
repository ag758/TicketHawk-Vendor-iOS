//
//  VendorMainViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/4/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI

internal class EventCustomClass: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    @IBOutlet weak var titleView: UITextField!
    
    @IBOutlet weak var dateView: UITextField!
    @IBOutlet weak var costView: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
}
class VendorMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBOutlet weak var createEventButton: UIButton!
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    var ref: DatabaseReference?
    
    var events: [Event] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = SplitViewController.ref

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.black
        setCosmetics()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.rowHeight = 200
        eventsTableView.reloadData()
        eventsTableView.backgroundColor = UIColor.black
        
        loadEvents()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.eventsTableView
            .dequeueReusableCell(withIdentifier: "eventCell") as! EventCustomClass
        
        cell.titleView.text = events[indexPath.row].title
        cell.dateView.text = events[indexPath.row].dateAndTime
        cell.costView.text = events[indexPath.row].lowestPrice
        
        cell.backgroundImageView.layer.cornerRadius = 5
        
         cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let url = URL(string: events[indexPath.row].imageURL!)!
        
        downloadImage(from: url, iv: cell.backgroundImageView)
        
        cell.titleView.backgroundColor = UIColor.clear
        cell.titleView.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)
        
        cell.dateView.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        cell.costView.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        
        cell.backgroundColor = UIColor.black
      
        
        
        
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func loadEvents(){
        let query = ref?.child("vendors").child(Auth.auth().currentUser!.uid).child("events")
        
        query?.observe(.childAdded, with: { (snapshot) in
            
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
                
                let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id)
                
                self.events.append(eventInstance)
                //self.markers? = self.sortTableViewByTime(markers: (self.markers!))
                
                self.eventsTableView.reloadData()
            }
            
        })
        
        query?.observe(.childChanged, with: { (snapshot) in
            
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
                
                let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id)
                var index = 0
                for e in self.events{
                    if (e.id == id){
                        index = self.events.index(of: e) ?? 0
                    }
                }
                self.events[index] = eventInstance
                //self.markers? = self.sortTableViewByTime(markers: (self.markers!))
                
                self.eventsTableView.reloadData()
            }
        })
        query?.observe(.childRemoved, with: { (snapshot) in
            let event = snapshot.value as? NSDictionary
            let id = event!["key"] as? String ?? "key not found"
            
            var index = 0
            for e in self.events{
                if e.id == id{
                    index = self.events.index(of: e) ?? 0
                    self.events.remove(at: index)
                }
            }
            
            self.eventsTableView.reloadData()
        })
 
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "splitViewController") as! SplitViewController
                self.present(vc, animated: true, completion: nil)
            }
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func createPressed(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "createEventViewController") as! CreateEventViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    

    func setCosmetics(){
        logOutButton.backgroundColor = .clear
        logOutButton.layer.cornerRadius = 17.5
        logOutButton.layer.borderWidth = 2
        logOutButton.layer.borderColor = UIColor.white.cgColor
            
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        logOutButton.setTitle("Log Out", for: .normal)
        
        editProfileButton.backgroundColor = .clear
        editProfileButton.layer.cornerRadius = 17.5
        editProfileButton.layer.borderWidth = 2
        editProfileButton.layer.borderColor = UIColor.white.cgColor
        
        editProfileButton.setTitleColor(UIColor.white, for: .normal)
        
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        editProfileButton.setTitle("Edit Profile", for: .normal)
        
        createEventButton.backgroundColor = .clear
        createEventButton.layer.cornerRadius = 20
        createEventButton.layer.borderWidth = 2
        createEventButton.layer.borderColor = SplitViewController.greenColor.cgColor
    createEventButton.setTitleColor(SplitViewController.greenColor, for: .normal)
        
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        createEventButton.setTitle("Create Event", for: .normal)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, iv: UIImageView) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            
            
            DispatchQueue.main.async() {
                iv.image = UIImage(data: data)
            }
        }
    }
}
