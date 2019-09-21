//
//  VendorEventQRViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/18/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import AVFoundation

class VendorEventQRViewController: UIViewController, QRScannerViewDelegate {
    
    @IBOutlet weak var scanStatusView: UITextView!
    
    @IBOutlet weak var numberScannedView: UITextView!
    
    @IBOutlet weak var qrScanner: QRScannerView!
    
    var vendorID: String?
    
    var eventID: String?
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.qrScanner.context = self
        ref = SplitViewController.ref
        self.qrScanner.startScanning()
        
        qrScanner.delegate = self
        
        listenersForTotal()
        
    }
    
    func listenersForTotal(){
        
        let aT = ref?.child("vendors").child(vendorID ?? "").child("events").child(eventID ?? "").child("activeTickets")
        
        aT?.observe(.childAdded, with: { (snapshot) in
            self.setScannedAndTotal()
        })
        aT?.observe(.childRemoved, with: { (snapshot) in
            self.setScannedAndTotal()
        })
        
        let qT = ref?.child("vendors").child(vendorID ?? "").child("events").child(eventID ?? "").child("scannedTickets")
        
        qT?.observe(.childAdded, with: { (snapshot) in
            self.setScannedAndTotal()
        })
        qT?.observe(.childRemoved, with: { (snapshot) in
            self.setScannedAndTotal()
        })
        
    }
    
    func qrScanningDidFail() {
        return
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        ref?.child("vendors").child(vendorID ?? "").child("events").child(eventID ?? "").child("activeTickets").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            //print (str)
            let value = snapshot.value as? NSDictionary
            let keys = value?.allKeys
            
            //print(keys?.count)
            
            var key: String = ""
            var existsKey: Bool = false
            for k in keys ?? [] {
                if k as? String == str{
                    key = k as? String ?? ""
                    existsKey = true
                }
            }
            
            if existsKey {
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("activeTickets").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let ticket = snapshot.value
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("scannedTickets").child(key).setValue(ticket){ (error, ref) -> Void in
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("activeTickets").child(key).removeValue() { (error, ref) -> Void in
                
                    self.setTextStatus(s: "Valid Ticket", c: SplitViewController.greenColor)
                AudioServicesPlaySystemSound(1054);
                self.setScannedAndTotal()
                    
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                        // Code you want to be delayed
                        
                        self.qrScanner.startScanning()
                    //}
                
                }
                }
                
                })
                
                
                
                
                
            } else {
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("scannedTickets").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    let keys = value?.allKeys
                    
                    //print(keys?.count)
                    
                    var key: String = ""
                    var existsKey2: Bool = false
                    for k in keys ?? [] {
                        if k as? String == str{
                            key = k as? String ?? ""
                            existsKey2 = true
                        }
                    }
                    
                    if (existsKey2){
                        self.setTextStatus(s: "Ticket Scanned Already", c: UIColor.yellow)
                    } else {
                        self.setTextStatus(s: "Not Valid Ticket", c: UIColor.red)
                    }
                    
                    //Check for already scanned
                    AudioServicesPlaySystemSound(1053);
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                        // Code you want to be delayed
                        
                        self.qrScanner.startScanning()
                    //}
                    
                })
                
                
            }
            
        })
    }
    
    func setScannedAndTotal(){
        let goingRef = self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("going")
        let scannedTicketsRef = self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("scannedTickets")
        
        goingRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let going = snapshot.value as? Int ?? 0
            
            scannedTicketsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                let toBeScanned = snapshot.value as? Dictionary ?? [:]
                
                
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    self.numberScannedView.text =  String(toBeScanned.count) + "/" + String(going) + " scanned"
                }
            })
            
         })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qrScanner.stopScanning()
    }
    
    func setTextStatus(s: String, c: UIColor){
        self.scanStatusView.text = s
        self.scanStatusView.textColor = c
    }
    
    func qrScanningDidStop() {
        return
    }
}
