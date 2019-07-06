//
//  VendorMainViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/4/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI
class VendorMainViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var editProfileButton: UIButton!
    
    @IBOutlet weak var createEventButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.black
        setCosmetics()
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "splitViewController") as! SplitViewController
                self.present(vc, animated: true, completion: nil)
            }
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

    func setCosmetics(){
        logOutButton.backgroundColor = .clear
        logOutButton.layer.cornerRadius = 17.5
        logOutButton.layer.borderWidth = 2
        logOutButton.layer.borderColor = UIColor.white.cgColor
            
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        logOutButton.setTitle("Log Out", for: .normal)
        
        editProfileButton.backgroundColor = .clear
        editProfileButton.layer.cornerRadius = 17.5
        editProfileButton.layer.borderWidth = 2
        editProfileButton.layer.borderColor = UIColor.white.cgColor
        
        editProfileButton.setTitleColor(UIColor.white, for: .normal)
        
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        editProfileButton.setTitle("Edit Profile", for: .normal)
        
        createEventButton.backgroundColor = .clear
        createEventButton.layer.cornerRadius = 20
        createEventButton.layer.borderWidth = 2
        createEventButton.layer.borderColor = SplitViewController.greenColor.cgColor
    createEventButton.setTitleColor(SplitViewController.greenColor, for: .normal)
        
        createEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        createEventButton.setTitle("Create Event", for: .normal)
    }

}
