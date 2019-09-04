//
//  CustomerTicketViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/28/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

internal class TicketCustomClass: UITableViewCell {
    
    @IBOutlet weak var qrCodeView: UIImageView!
    @IBOutlet weak var eventTitle: UITextView!
    @IBOutlet weak var ticketType: UITextView!
    @IBOutlet weak var userName: UITextView!
    @IBOutlet weak var dateAndTime: UITextView!
    @IBOutlet weak var location: UITextView!
    
    @IBOutlet weak var bottomRounded: UIImageView!
}

class CustomerTicketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  

    @IBOutlet weak var ticketsMasterTableView: UITableView!
    
    var tickets: [Ticket] = []
    
    var ref: DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        ref = SplitViewController.ref
        
        self.ticketsMasterTableView.rowHeight = ticketsMasterTableView.bounds.height
        self.ticketsMasterTableView.backgroundColor = UIColor.clear
        
        self.ticketsMasterTableView.dataSource = self
        self.ticketsMasterTableView.delegate = self
        
        loadTickets()
    }
    
    func loadTickets(){
        let query = ref?.child("customers").child(Auth.auth().currentUser!.uid).child("activeTickets")
        
        query?.observe(.childAdded, with: { (snapshot) in
            
            let ticket = snapshot.value as? NSDictionary
            
            let key = ticket!["key"] as! String
            let eventTitle = ticket!["title"] as? String ?? ""
            let dateAndTime = ticket!["dateAndTime"] as? String ?? "No Date Found"
            let ticketType = ticket!["ticketType"] as? String ?? ""
            let userName = ticket!["userName"] as? String ?? ""
            let location = ticket!["location"] as? String ?? ""
            
            
            let ticketInstance = Ticket(key: key, eventTitle: eventTitle, ticketType: ticketType, userName: userName, dateAndTime: dateAndTime, location: location)
            self.tickets.append(ticketInstance)
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                self.tickets = self.sortTableViewByTime(tickets: self.tickets)
                
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    
                    self.ticketsMasterTableView.reloadData()
                }
            }
                 
            
        })
        query?.observe(.childRemoved, with: { (snapshot) in
            let ticket = snapshot.value as? NSDictionary
            let key = ticket!["key"] as! String
            
            var index = 0
            for t in self.tickets{
                if t.key == key{
                    index = self.tickets.index(of: t) ?? 0
                    self.tickets.remove(at: index)
                }
            }
            
            self.ticketsMasterTableView.reloadData()
        })
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCustomClass", for: indexPath) as! TicketCustomClass
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.cornerRadius = 20
        
        cell.bottomRounded.layer.cornerRadius = 20
        
        encodeKeyAsQRCode(imageView: cell.qrCodeView, key: tickets[indexPath.row].key)
        
        cell.dateAndTime.text = tickets[indexPath.row].dateAndTime
        cell.eventTitle.text = tickets[indexPath.row].eventTitle
        cell.location.text = tickets[indexPath.row].location
        cell.ticketType.text = tickets[indexPath.row].ticketType
        cell.userName.text = tickets[indexPath.row].userName
        
    
        return cell
    }
    
    func encodeKeyAsQRCode(imageView: UIImageView, key: String){
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            // import UIKit
            // Get define string to encode
            let myString = key
            // Get data from the string
            let data = myString.data(using: String.Encoding.ascii)
            // Get a QR CIFilter
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
            // Input the data
            qrFilter.setValue(data, forKey: "inputMessage")
            // Get the output image
            guard let qrImage = qrFilter.outputImage else { return }
            // Scale the image
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQrImage = qrImage.transformed(by: transform)
            // Do some processing to get the UIImage
            let context = CIContext()
            guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return }
            let processedImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                imageView.image = processedImage
            }
            
            
        }
    
       
        
     
    }
    
    func sortTableViewByTime(tickets: [Ticket]) -> [Ticket] {
        var ticketsMut = tickets
        var x = 0
        while (x < ticketsMut.count-1) {
            var closestInt = x
            for y in x+1...ticketsMut.count-1 {
                if compareDates(date1: tickets[x].dateAndTime, date2: tickets[y].dateAndTime) == true{
                    closestInt = y
                }
            }
            //swap shortest and x
            ticketsMut.swapAt(x, closestInt)
            x = x+1
        }
        
        return ticketsMut
    }
    
    func compareDates (date1: String, date2: String) -> Bool {
        
        print("d1" + date1)
        print("d2" + date2)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        let d1: Date = dateFormatter.date(from: date1)!
        let d2: Date = dateFormatter.date(from: date2)!
        
        if (d1 > d2){
            return true
        }
        return false
    }
    

}
