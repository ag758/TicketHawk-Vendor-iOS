//
//  VendorEventQRViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/18/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class VendorEventQRViewController: UIViewController {

    @IBOutlet weak var qrScanner: QRScannerView!
    
    var vendorID: String?
    
    var eventID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.qrScanner.context = self
        
        
    }
}
