//
//  VendorEventViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/18/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase

class VendorEventViewController: UIViewController {
    
    var vendorID: String?
    var eventID: String?
    
    var ref: DatabaseReference?
    
    var eventTitle: String?
    
    var pictureURL: String?

    @IBOutlet weak var eventView: UITextView!
    
    @IBOutlet weak var scanButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var closeOutButton: UIButton!
    
    @IBOutlet weak var eventPicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Constants.ref
        
        self.eventView.text = eventTitle ?? ""
        self.eventPicture.layer.cornerRadius = 12
        
        let cosmeticButtons: [UIButton] = [self.scanButton, self.editButton, self.closeOutButton]
        
        for c in cosmeticButtons{
            c.backgroundColor = .clear
            c.layer.cornerRadius = 30
            c.layer.borderWidth = 2
            c.layer.borderColor = UIColor.white.cgColor
            
            c.setTitleColor(UIColor.white, for: .normal)
            
            c.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        }
        
        self.scanButton.layer.borderColor = Constants.greenColor.cgColor
        self.scanButton.setTitleColor(Constants.greenColor, for: .normal)
        
        let url = URL(string: self.pictureURL ?? "www.apple.com") ?? URL(string: "www.apple.com")!
        downloadImage(from: url)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func scanPressed(_ sender: Any) {
        
        
        DispatchQueue.main.async {
            let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorEventQRViewController") as! VendorEventQRViewController
            
            next.vendorID = self.vendorID
            next.eventID = self.eventID
           self.navigationController!.pushViewController(next, animated: true)
        }
        
    }
    @IBAction func editPressed(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorEventEditViewController") as! VendorEventEditViewController
        
        next.eventID = self.eventID
        self.navigationController!.pushViewController(next, animated: true)
    }
    
    @IBAction func closeOutPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Close " + (self.eventTitle ?? "") + "?", message: "You will no longer be able to sell tickets, nor scan tickets, on this event. Please re-enter the event title to confirm your event has ended.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Event Title"
            textField.isSecureTextEntry = false
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            print("entered \(String(describing: textField.text))")
            
            if (textField.text == self.eventTitle){
                //
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let event = snapshot.value
                
                    
                    self.ref?.child("vendors").child(self.vendorID ?? "").child("closedEvents").child(self.eventID ?? "").setValue(event){ (error, ref) -> Void in
                        
                         self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").removeValue()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
                //
            } else {
                
                
                let alertController = UIAlertController(title: "Wrong Event Title", message: "", preferredStyle: .alert)
                 let confirmAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(confirmAction)
                self.present(alertController, animated:true, completion: nil)
                
                
            }
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.eventPicture.image = UIImage(data: data)
            }
        }
    }
}
