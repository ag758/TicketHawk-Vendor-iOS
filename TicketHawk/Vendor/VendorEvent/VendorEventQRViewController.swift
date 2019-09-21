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
    
    

    @IBOutlet weak var qrScanner: QRScannerView!
    
    var vendorID: String?
    
    var eventID: String?
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.qrScanner.context = self
        ref = SplitViewController.ref
        
        qrScanner.delegate = self
        
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
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("scannedTickets").setValue(ticket){ (error, ref) -> Void in
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("activeTickets").child(key).removeValue() { (error, ref) -> Void in
                
                AudioServicesPlaySystemSound(1054);
                self.setScannedAndTotal()
                self.qrScanner.startScanning()
                }
                }
                
                })
                
                
                
                
                
            } else {
                
                self.ref?.child("vendors").child(self.vendorID ?? "").child("events").child(self.eventID ?? "").child("activeTickets").observeSingleEvent(of: .value, with: { (snapshot) in
                    
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
                    
                    if (existsKey){
                        self.setTextStatus(s: "Ticket Scanned Already")
                    } else {
                        self.setTextStatus(s: "Not Valid Ticket")
                    }
                    
                    //Check for already scanned
                    AudioServicesPlaySystemSound(1053);
                    self.qrScanner.startScanning()
                    
                })
                
                
            }
            
        })
    }
    
    func setScannedAndTotal(){
        
        
    }
    
    func setTextStatus(s: String){
        
    }
    
    func qrScanningDidStop() {
        return
    }
}
