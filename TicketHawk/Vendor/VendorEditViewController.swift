//
//  VendorEditViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 9/22/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VendorEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var vendorID: String?
    
    var ref: DatabaseReference?
    
    @IBOutlet weak var orgNameTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var customerSupportPhoneNumber: UITextField!
    @IBOutlet weak var customerSupportEmail: UITextField!
    
    @IBOutlet weak var pictureURLTextField: UITextField!
    @IBOutlet weak var pictureURLImageView: UIImageView!
    
    @IBOutlet weak var communitiesTableView: UITableView!
    

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var communities:[String] = []
    
    var intendedCommunity = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendorID = Auth.auth().currentUser?.uid
        
        ref = SplitViewController.ref

        // Do any additional setup after loading the view.
        
        pictureURLTextField.addTarget(self, action: #selector(VendorEditViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        communitiesTableView.dataSource = self
        communitiesTableView.delegate = self
        
        fetchCommunities()
        
        fetchDefaults()
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 17.5
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        cancelButton.setTitle("Cancel Changes", for: .normal)
        
        confirmButton.backgroundColor = .clear
        confirmButton.layer.cornerRadius = 17.5
        confirmButton.layer.borderWidth = 2
        confirmButton.layer.borderColor = SplitViewController.greenColor.cgColor
        confirmButton.setTitleColor(SplitViewController.greenColor, for: .normal)
        
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        confirmButton.setTitle("Confirm Changes", for: .normal)
       
    }
    
    func fetchDefaults(){
        
        self.ref?.child("vendors").child(self.vendorID ?? "").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary ?? [:]
            
            self.orgNameTextView.text = value["organizationName"] as? String ?? ""
            self.categoryTextView.text = value["ticketCategory"] as? String ?? ""
            self.customerSupportPhoneNumber.text = value["custSuppPhoneNumber"] as? String ?? ""
            self.customerSupportEmail.text = value["custSupportEmail"] as? String ?? ""
            self.pictureURLTextField.text = value["organizationProfileImage"] as? String ?? ""
            self.intendedCommunity = value["primaryCommunity"] as? String ?? ""
            
            if (self.pictureURLTextField.text?.isEmpty == false){
                let url = URL(string: self.pictureURLTextField.text!) ?? URL(string: "www.apple.com")!
                self.downloadImage(from: url)
            }
            
            
        })
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func confirmPressed(_ sender: Any) {
        if (orgNameTextView.text?.isEmpty == false
            && categoryTextView.text?.isEmpty == false
            && customerSupportPhoneNumber.text?.isEmpty == false
            && customerSupportEmail.text?.isEmpty == false
            && pictureURLTextField.text?.isEmpty == false
            && intendedCommunity != ""){
            
            
            let user = Auth.auth().currentUser
            
            let userID: String = (user?.uid) ?? ""
            ref?.child("vendors/\(userID)/organizationName").setValue(orgNameTextView.text)
            ref?.child("vendors/\(userID)/ticketCategory").setValue(categoryTextView.text)
            ref?.child("vendors/\(userID)/custSuppPhoneNumber").setValue(customerSupportPhoneNumber.text)
            ref?.child("vendors/\(userID)/custSupportEmail").setValue(customerSupportEmail.text)
            
            ref?.child("vendors/\(userID)/organizationProfileImage").setValue(pictureURLTextField.text)
            
            
            
                ref?.child("vendors").child(vendorID ?? "").child("primaryCommunity").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let pC = snapshot.value as? String ?? ""
                
                //remove from current community
                self.ref?.child("communities").child(pC).child("vendors").child(self.vendorID ?? "").observeSingleEvent(of: .value, with: {(snapshot) in
                    let value = snapshot.value as? NSDictionary ?? [:]
                    
                    
                    
                    self.ref?.child("communities").child(pC).child("vendors").child(self.vendorID ?? "").removeValue(){ (error, ref) -> Void in
                        self.ref?.child("communities").child(self.intendedCommunity).child("vendors").child(self.vendorID ?? "").setValue(value)
                    }
                    
                    self.ref?.child("vendors").child(self.vendorID ?? "").child("primaryCommunity").setValue(self.intendedCommunity)
                    
                    
                })
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.navigationController?.popViewController(animated: true)
            
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty == false){
            let url = URL(string: pictureURLTextField.text!) ?? URL(string: "www.apple.com")!
            downloadImage(from: url)
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
