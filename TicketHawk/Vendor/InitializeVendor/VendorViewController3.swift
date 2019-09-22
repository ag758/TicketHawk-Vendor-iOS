//
//  VendorViewController3.swift
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

class VendorViewController3: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var pictureURLTextField: UITextField!
    @IBOutlet weak var pictureURLImageView: UIImageView!
    
    @IBOutlet weak var communitiesTableView: UITableView!
    
    var ref:DatabaseReference?
    
    var communities:[String] = []
    
    var intendedCommunity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black

        // Do any additional setup after loading the view.
        
        ref = SplitViewController.ref
        
        pictureURLTextField.addTarget(self, action: #selector(VendorViewController3.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        communitiesTableView.delegate = self
        communitiesTableView.dataSource = self
        communitiesTableView.reloadData()
        
        fetchCommunities()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty == false){
            let url = URL(string: pictureURLTextField.text!) ?? URL(string: "www.apple.com")!
            downloadImage(from: url)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.communities.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //variable type is inferred
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CELL")
        }
        
        cell!.textLabel?.text = communities[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        intendedCommunity = communities[indexPath.row]
    }
    
    
    
    func fetchCommunities(){
        let query = ref?.child("communities")
        query?.observe(.childAdded, with: { (snapshot) in
            let community = snapshot.value as? NSDictionary
            let name = community!["name"] as! String
            self.communities.append(name)
            self.communities = self.communities.sorted()
            
            self.communitiesTableView.reloadData()
            
        })
        query?.observe(.childRemoved, with: { (snapshot) in
            let community = snapshot.value as? NSDictionary
            let name = community!["name"] as! String
            for c in self.communities{
                if c == name{
                    self.communities.remove(at: self.communities.lastIndex(of: c)!)
                }
            }
            
            self.communitiesTableView.reloadData()
            
            
        })
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        
        let userID: String = (user?.uid)!
        
        //Check valid inputs
        if (pictureURLTextField.text?.isEmpty == false
            && intendedCommunity != ""){
            
            ref?.child("vendors/\(userID)/organizationProfileImage").setValue(pictureURLTextField.text)
            
            //set flag did finish setting up
            ref?.child("vendors/\(userID)/didFinishSigningUp").setValue(true)
            
            //set banned to false
            ref?.child("vendors/\(userID)/banned").setValue(false)
            
            
            ref?.child("communities/\(intendedCommunity)/vendors/\(userID)/id").setValue(userID)
            
            ref?.child("vendors/\(userID)/primaryCommunity").setValue(intendedCommunity)
            
            //allow, transition to main vendor activity
            
            let next = self.storyboard!.instantiateViewController(withIdentifier: "vendorNavigationController") as! UINavigationController
            self.present(next, animated: true, completion: nil)
            
            
            
        } else {
            
        }
    }
    
    
    
    
    
    
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.pictureURLImageView.image = UIImage(data: data)
            }
        }
    }

}
