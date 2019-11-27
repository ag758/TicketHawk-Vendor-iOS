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
    
    @IBOutlet weak var dobMonthField: UITextField!
    
    @IBOutlet weak var dobDayField: UITextField!
    
    @IBOutlet weak var dobYearField: UITextField!
    
    @IBOutlet weak var ssnField: UITextField!
    
    @IBOutlet weak var nextPressed: UIButton!
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.ref

        
    }
    
    func checkConditions()->Bool{
        if firstNameField.text?.isEmpty == false
            && lastNameField.text?.isEmpty == false
            && dobMonthField.text?.count ?? 0 > 0
            && dobDayField.text?.count ?? 0 > 0
            && dobYearField.text?.count == 4
            && ssnField.text?.count == 4
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
        
        if(checkConditions()){
            
            StripeClient.shared.createAccount(with: firstNameField.text ?? "", lastName: lastNameField.text ?? "", dobDay: Int(dobDayField.text ?? "") ?? 0, dobMonth: Int(dobMonthField.text ?? "") ?? 0, dobYear: Int(dobYearField.text ?? "") ?? 0, lastFourSSN: Int(ssnField.text ?? "") ?? 0) { result in
                
                print(self.firstNameField.text)
                print(self.lastNameField.text)
                print(Int(self.dobDayField.text ?? "") ?? 0)
                print(Int(self.dobMonthField.text ?? "") ?? 0)
                print(Int(self.dobYearField.text ?? "") ?? 0)
                print(Int(self.ssnField.text ?? "") ?? 0)
                
                
                if (result != "Error"){
                    //Success
                    
                    let user = Auth.auth().currentUser
                    
                    let userID: String = (user?.uid)!
                    
                    self.ref?.child("vendors").child(userID).child("stripeAcctID").setValue(result)
                    
                    //set flag did finish setting up
                    self.ref?.child("vendors/\(userID)/didFinishStripeAccount").setValue(true)
                    
                    //next steps
                    
                } else {
                    let alert = UIAlertController(title: "Verification did not succeed.", message: "Please verify your information and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        
            
            
        } else {
            
        }
        
        loadingIndicator.stopAnimating()
        
        
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
