//
//  VendorEventViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/18/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class VendorEventViewController: UIViewController {
    
    var vendorID: String?
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorEventQRViewController") as! VendorEventQRViewController
        
        next.vendorID = self.vendorID
        next.eventID = self.eventID
        self.navigationController!.pushViewController(next, animated: true)
    }
    @IBAction func editPressed(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorEventEditViewController") as! VendorEventEditViewController
        
        next.eventID = self.eventID
        self.navigationController!.pushViewController(next, animated: true)
    }
    
}
