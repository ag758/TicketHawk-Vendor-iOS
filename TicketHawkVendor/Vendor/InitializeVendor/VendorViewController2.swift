//
//  VendorViewController2.swift
//  TicketHawk
//
//  Created by Austin Gao on 6/29/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI

class VendorViewController2: UIViewController {
    
    
    @IBOutlet weak var orgNameTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var customerSupportPhoneNumber: UITextField!
    @IBOutlet weak var customerSupportEmail: UITextField!
    
    var ref: DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.ref

        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        
        
        
        
    }
    
    @IBAction func nextTouched(_ sender: Any) {
        
        if (orgNameTextView.text?.isEmpty == false
            && categoryTextView.text?.isEmpty == false
            && customerSupportPhoneNumber.text?.isEmpty == false
            && customerSupportEmail.text?.isEmpty == false){
            
            //Set values
            
            let user = Auth.auth().currentUser
            
            let userID: String = (user?.uid) ?? ""
            
            ref?.child("vendors/\(userID)/organizationName").setValue(orgNameTextView.text)
            ref?.child("vendors/\(userID)/ticketCategory").setValue(categoryTextView.text)
            ref?.child("vendors/\(userID)/custSuppPhoneNumber").setValue(customerSupportPhoneNumber.text)
            ref?.child("vendors/\(userID)/custSupportEmail").setValue(customerSupportEmail.text)
            
            
            //progress to next view
            
            let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorViewController3") as! VendorViewController3
            self.present(next, animated: true, completion: nil)
            
            
            
        }
    }
    

}
