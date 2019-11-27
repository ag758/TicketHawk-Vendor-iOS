//
//  VendorStripeAccountCreationController.swift
//  TIcketHawkVendor
//
//  Created by Austin Gao on 11/26/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VendorStripeAccountCreationController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    
    @IBOutlet weak var nextPressed: UIButton!
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.ref

        loadingIndicator.isHidden = true
        
    }
    
    func checkConditions()->Bool{
        if firstNameField.text?.isEmpty == false
            && lastNameField.text?.isEmpty == false
        {
            //print("A")
            return true
        } else {
            //print("B")
            return false
        }
    }

    @IBAction func nextPressed(_ sender: Any) {
        
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
        if(checkConditions()){
            
            StripeClient.shared.createAccount(with: firstNameField.text ?? "", lastName: lastNameField.text ?? "") { result in
                
                
                
                if (result != "Error"){
                    //Success
                    
                    let user = Auth.auth().currentUser
                    
                    let userID: String = (user?.uid)!
                    
                    self.ref?.child("vendors").child(userID).child("stripeAcctID").setValue(result)
                    
                    //set flag did finish setting up
                    self.ref?.child("vendors/\(userID)/didFinishStripeAccount").setValue(true)
                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                    //next steps
                    
                } else {
                    let alert = UIAlertController(title: "Verification did not succeed.", message: "Please verify your information and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                }
            }
        
            
            
        } else {
            
        }
        
        
        
        
    }
    @IBAction func stripeConnectedPressed(_ sender: Any) {
        guard let url = URL(string: Constants.stripeConnectedAccountAgreementURL) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        
        
    
    }
    
}
