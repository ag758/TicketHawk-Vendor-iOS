//
//  VendorStripeAccountUpdateController.swift
//  TIcketHawkVendor
//
//  Created by Austin Gao on 11/28/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VendorStripeAccountUpdateController: UIViewController {
    
    var ref: DatabaseReference?

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.ref
        
        loadingIndicator.isHidden = true

    }

    @IBAction func stripeConnectPressed(_ sender: Any) {
        guard let url = URL(string: Constants.stripeConnectedAccountAgreementURL) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func openURL(s: String){
        guard let url = URL(string: s) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
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
            
            StripeClient.shared.updateAccount(accountID: accountID, failureURL: Constants.stripe_failure_url, successURL: Constants.stripe_success_url) { result in
                
                
                
                if (result != "Error"){
                    
                    self.openURL(s: result)
                    self.ref?.child("vendors/\(userID)/didFinishAdditionalDetails").setValue(true)
                    //next steps
                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                    let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorStripeBankController") as! VendorStripeBankController
                    self.present(next, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "There was an error processing your request", message: "Please try again, or email support if you encounter additional errors.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                }
            }
        })
    }
}
