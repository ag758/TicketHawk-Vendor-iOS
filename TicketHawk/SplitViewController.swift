//
//  ViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 6/23/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import Firebase

class SplitViewController: UIViewController {
    
    static var ref: DatabaseReference?

    @IBOutlet weak var vendorButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        SplitViewController.ref = Database.database().reference()
        
        setCosmetics()
    }
    
    func setCosmetics(){
        view.backgroundColor = UIColor.black
        
        customerButton.backgroundColor = .clear
        customerButton.layer.cornerRadius = 30
        customerButton.layer.borderWidth = 3
        customerButton.layer.borderColor = UIColor.white.cgColor
        
        customerButton.setTitleColor(UIColor.white, for: .normal)
        
        customerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        customerButton.setTitle("I'm Buying Tickets", for: .normal)
        
        vendorButton.backgroundColor = .clear
        vendorButton.layer.cornerRadius = 20
        vendorButton.layer.borderWidth = 3
        vendorButton.layer.borderColor = UIColor.white.cgColor
        
        vendorButton.setTitleColor(UIColor.white, for: .normal)
        
        vendorButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        vendorButton.setTitle("I'm Selling Tickets", for: .normal)
    }
    @IBAction func vendorPressed(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorViewController1") as! VendorViewController1
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func customerPressed(_ sender: Any) {
        
    }
    
}

