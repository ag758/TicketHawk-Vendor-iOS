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
   
    @IBOutlet weak var earningsView: UITextField!
    @IBOutlet weak var goingView: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
}
class VendorMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBOutlet weak var createEventButton: LoadingButton!
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    @IBOutlet weak var pastEvents: UIButton!
    
    
    @IBOutlet weak var verificationButton: LoadingButton!
    
    @IBOutlet weak var BankEditButton: UIButton!
    
    
    var ref: DatabaseReference?
    
    var events: [Event] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.ref
        
        let currentUser = Auth.auth().currentUser
        
        if currentUser == nil{
            let next = self.storyboard!.instantiateViewController(withIdentifier: "splitViewController") as! SplitViewController
            self.present(next, animated: false, completion: nil)
            return
        }
        
         print("b")
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        
         print("c")
        
        let vendorRef : DatabaseReference? = ref?.child("vendors").child(userID)
        
        self.onCreateRegardless()
        
        print("d")
        
        
        // Attach a listener to read the data at our posts reference
        vendorRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            ///If no value exists -- means false
            let didFinishProfile = value?["didFinishSigningUp"] as? Bool ?? false
            
            
            if didFinishProfile == false {
                do {try Auth.auth().signOut()}
                catch {
                
                }
                let next = self.storyboard!.instantiateViewController(withIdentifier: "splitViewController") as! SplitViewController
                
                self.navigationController?.present(next, animated: true, completion: nil)
                //self.present(next, animated: true, completion: nil)
                return
            } else {
                self.onCreateContinue()
            }
        })
    }
    
    func onCreateRegardless(){
        // Do any additional setup after loading the view.
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        view.backgroundColor = UIColor.black
        setCosmetics()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.rowHeight = 200
        eventsTableView.reloadData()
        eventsTableView.backgroundColor = UIColor.black
    }
    
    func onCreateContinue(){
      
        
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
        
        print("id" + (events[indexPath.row].id ?? ""))
        
        
        
        self.ref?.child("vendors").child(Auth.auth().currentUser!.uid).child("events").child(events[indexPath.row].id ?? "").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            let value = snapshot.value as? NSDictionary
            if let number = formatter.string(from:  NSNumber(value: Float(value?["netSales"] as? Int ?? 0) / 100)) {
                cell.earningsView.text = "Earnings: " + number
            }
            
            let going = value?["going"] as? Int ?? 0
            let s = "Going: " + String(going)
            
            cell.goingView.text = s
            
        })
        
        cell.backgroundImageView.layer.cornerRadius = 5
        
         cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let url = URL(string: events[indexPath.row].imageURL!) ??
            URL(string: "www.apple.com")!
        
        downloadImage(from: url, iv: cell.backgroundImageView)
        
        cell.titleView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.black
        
        
        
        
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorEventViewController") as! VendorEventViewController
        
        next.eventTitle = self.events[indexPath.row].title
        next.pictureURL  = self.events[indexPath.row].imageURL
        
        next.vendorID = self.events[indexPath.row].creatorId
        next.eventID = self.events[indexPath.row].id
        self.navigationController!.pushViewController(next, animated: true)
        
    }
    
    func loadEvents(){
        
        
        
            
        let query = ref?.child("vendors").child(Auth.auth().currentUser!.uid).child("events")
        
        query?.observe(.childAdded, with: { (snapshot) in
            
            let event = snapshot.value as? NSDictionary ?? [:]
            
            let title = event["eventTitle"] as? String ?? ""
            var startDateAndTime = event["startDateAndTime"] as? String ?? "No Date Found"
            let pictureURL = event["pictureURL"] as? String ?? ""
            let tickets = event["ticketTypes"] as? Dictionary ?? [:]
            let id = event["key"] as? String ?? ""
            
            let unformatted = startDateAndTime
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let d1: Date = dateFormatter.date(from: startDateAndTime) ?? Date()
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.amSymbol = "AM"
            dateFormatter2.pmSymbol = "PM"
            dateFormatter2.dateFormat = "MMMM dd h:mm a"
            
            startDateAndTime = dateFormatter2.string(from: d1)
            
            print(1)
            
            var minimumprice: Double = Double.greatestFiniteMagnitude
            for (_, ticketprice) in tickets {
                if ((ticketprice as! Double) / 100 < minimumprice){
                    minimumprice = ticketprice as! Double / 100
                }
            }
            
            print(2)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            if let number = formatter.string(from: NSNumber(value: minimumprice)) {
                print(number)
                
                self.ref?.child("vendors").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    
                    print(3)
                    
                    
                    let value = snapshot.value as? NSDictionary ?? [:]
                    let ownName = value["organizationName"] as? String ?? ""
                    
                    let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id, creatorId: Auth.auth().currentUser!.uid,
                                              creatorName: ownName, unformatted: unformatted
                                              )
                    
                    //Check if well-formed
                    
                    if (title != ""){
                        self.events.append(eventInstance)
                                           self.events = self.sortTableViewByTime(events: self.events)
                                           
                                           self.eventsTableView.reloadData()
                    }
                   
                    
                })
                
                
            }
            
        })
        
        query?.observe(.childChanged, with: { (snapshot) in
            
            let event = snapshot.value as? NSDictionary ?? [:]
            
            let title = event["eventTitle"] as? String ?? ""
            var startDateAndTime = event["startDateAndTime"] as? String ?? "No Date Found"
            let pictureURL = event["pictureURL"] as? String ?? ""
            let tickets = event["ticketTypes"] as? Dictionary ?? [:]
            let id = event["key"] as? String ?? ""
            
            let unformatted = startDateAndTime
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let d1: Date = dateFormatter.date(from: startDateAndTime) ?? Date()
            
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
                
                self.ref?.child("vendors").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    let ownName = value!["organizationName"] as? String ?? ""
                    
                    let eventInstance = Event(title: title, dateAndTime: startDateAndTime, lowestPrice: number, imageURL: pictureURL, id: id, creatorId: Auth.auth().currentUser!.uid, creatorName: ownName, unformatted: unformatted)
                    var index = 0
                    for e in self.events{
                        if (e.id == id){
                            index = self.events.index(of: e) ?? 0
                        }
                    }
                    self.events[index] = eventInstance
                    self.events = self.sortTableViewByTime(events: self.events)
                    
                    self.eventsTableView.reloadData()
                    
                })
                
                
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
    
    
    @IBAction func editPressed(_ sender: Any) {
        
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "vendorEditViewController") as! VendorEditViewController
            self.navigationController!.pushViewController(vc, animated: true)
        }
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
        
        createEventButton.showLoading()
        createEventButton.isEnabled = false
        
        ref?.child("vendors").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
        
        ///If no value exists -- means false
        let accountID = value?["stripeAcctID"] as? String ?? ""
        
            StripeClient.shared.checkVerificationStatus(accountID: accountID) { result in
            
            print("result:" + result)
            
            if (result == "verified"){
                
                self.createEventButton.isEnabled = true
                self.createEventButton.hideLoading()
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "createEventViewController") as! CreateEventViewController
                self.navigationController!.pushViewController(vc, animated: true)
                
                }
            else {
                let alert = UIAlertController(title: "Not Verified.", message: "Please ensure you are fully verified through the portal -- this is a requirement to create events.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.createEventButton.isEnabled = true
                self.createEventButton.hideLoading()
                
                }
            }
            
        })
        
        
        
        
        
    }
    
    func sortTableViewByTime(events: [Event]) -> [Event] {
        var eventsMut = events
        var x = 0
        while (x < events.count-1) {
            var closestInt = x
            for y in x+1...events.count-1 {
                if compareDates(date1: events[x].unformattedDateAndTime!, date2: events[y].unformattedDateAndTime!) == true{
                    closestInt = y
                }
            }
            //swap shortest and x
            eventsMut.swapAt(x, closestInt)
            x = x+1
        }
        
        return eventsMut
    }
    
    func compareDates (date1: String, date2: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let d1: Date = dateFormatter.date(from: date1)!
        let d2: Date = dateFormatter.date(from: date2)!
        
        if (d1 > d2){
            return true
        }
        return false
    }
    
    
    

    func setCosmetics(){
        logOutButton.backgroundColor = .clear
        logOutButton.layer.cornerRadius = 20
        logOutButton.layer.borderWidth = 2
        logOutButton.layer.borderColor = UIColor.white.cgColor
            
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        logOutButton.setTitle("Log Out", for: .normal)
        
        editProfileButton.backgroundColor = .clear
        editProfileButton.layer.cornerRadius = 20
        editProfileButton.layer.borderWidth = 2
        editProfileButton.layer.borderColor = UIColor.white.cgColor
        
        editProfileButton.setTitleColor(UIColor.white, for: .normal)
        
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        editProfileButton.setTitle("Edit Profile", for: .normal)
        
        createEventButton.backgroundColor = .clear
        createEventButton.layer.cornerRadius = 20
        createEventButton.layer.borderWidth = 2
        createEventButton.layer.borderColor = Constants.greenColor.cgColor
    createEventButton.setTitleColor(Constants.greenColor, for: .normal)
        
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        createEventButton.setTitle("Create Event", for: .normal)
        
        pastEvents.backgroundColor = .clear
        pastEvents.layer.cornerRadius = 20
        pastEvents.layer.borderWidth = 2
        pastEvents.layer.borderColor = UIColor.white.cgColor
        pastEvents.setTitleColor(UIColor.white, for: .normal)
        
        pastEvents.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        pastEvents.setTitle("Past Events", for: .normal)
        
        verificationButton.backgroundColor = .clear
        verificationButton.layer.cornerRadius = 20
        verificationButton.layer.borderWidth = 2
        verificationButton.layer.borderColor = UIColor.white.cgColor
        
        verificationButton.setTitleColor(UIColor.white, for: .normal)
        
        verificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        verificationButton.setTitle("Verification", for: .normal)
        
        BankEditButton.backgroundColor = .clear
        BankEditButton.layer.cornerRadius = 20
        BankEditButton.layer.borderWidth = 2
        BankEditButton.layer.borderColor = UIColor.white.cgColor
        
        BankEditButton.setTitleColor(UIColor.white, for: .normal)
        
        BankEditButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        BankEditButton.setTitle("Edit Bank", for: .normal)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    @IBAction func pastEventsPressed(_ sender: Any) {
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "vendorClosedViewController") as! VendorClosedViewController
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func verificationPressed(_ sender: Any) {
        
        verificationButton.showLoading()
        
        let user = Auth.auth().currentUser
        
        let userID: String = (user?.uid)!
        
        let vendorRef = ref?.child("vendors").child(userID)
        
        vendorRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            ///If no value exists -- means false
            let accountID = value?["stripeAcctID"] as? String ?? ""
            
            StripeClient.shared.accountLinkOnly(accountID: accountID, failureURL: Constants.stripe_failure_url, successURL: Constants.stripe_success_url) { result in
                
                
                
                if (result != "Error"){
                    
                    self.openURL(s: result)
                }
                self.verificationButton.hideLoading()
            }
        })
        
    }
    
    
    @IBAction func bankUpdatePressed(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "vendorStripeBankController") as! VendorStripeBankController
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    
    func downloadImage(from url: URL, iv: UIImageView) {
        print("Download Started")
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                //sleep(3)
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                
                
                DispatchQueue.main.async() {
                    iv.image = UIImage(data: data)
                }
            }
        }
        
    }
    
    func openURL(s: String){
        guard let url = URL(string: s) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
