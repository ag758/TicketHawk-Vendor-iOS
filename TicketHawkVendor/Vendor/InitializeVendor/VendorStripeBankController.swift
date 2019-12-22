//
//  VendorStripeBankController.swift
//  TIcketHawkVendor
//
//  Created by Austin Gao on 11/28/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VendorStripeBankController: UIViewController {

    @IBOutlet weak var firstLastField: UITextField!
    
    @IBOutlet weak var accountNumberField: UITextField!
    
    @IBOutlet weak var routingNumberField: UITextField!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Constants.ref
        // Do any additional setup after loading the view.
        
        loadingIndicator.isHidden = true
    }
    
    func checkConditions()->Bool{
        if firstLastField.text?.isEmpty == false
            && accountNumberField.text?.isEmpty == false
            && routingNumberField.text?.isEmpty == false
        {
            //print("A")
            return true
        } else {
            //print("B")
            return false
        }
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        
        let userID: String = (user?.uid)!
        
        let vendorRef = ref?.child("vendors").child(userID)
        
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
        
        // Attach a listener to read the data at our posts reference
        vendorRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            ///If no value exists -- means false
            let accountID = value?["stripeAcctID"] as? String ?? ""
            
            print(self.routingNumberField.text)
            if self.checkConditions(){
                StripeClient.shared.setBankToken(accountName: self.firstLastField.text ?? "", accountNumber: self.accountNumberField.text ?? "", routingNumber: self.routingNumberField.text ?? "", accountID: accountID) { result in
                    
                    
                    if (result != "Error"){
                        
                        self.ref?.child("vendors/\(userID)/didFinishStripeBank").setValue(true)
                        self.ref?.child("vendors/\(userID)/didFinishSigningUp").setValue(true)
                        
                        let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorNavigationController") as! UINavigationController
                        
                        
                        //self.navigationController?.present(next, animated: true, completion: nil)
                        self.present(next, animated: true, completion: nil)
                        
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        
                        
                        
                    } else {
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                    }
                }
                
            } else {
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
            
        })
        
       
    }

}
