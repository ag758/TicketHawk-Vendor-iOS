//
//  CreateEventViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/6/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseUI


class CreateEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var dateAndTimePicker: UIDatePicker?
    private var dateAndTimePicker2: UIDatePicker?
    
    var ref: DatabaseReference?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateAndTimeField: CustomUITextField!
    @IBOutlet weak var endDateAndTimeField: CustomUITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var imageURLTextField: UITextField!
    @IBOutlet weak var imageURLImageView: UIImageView!
    @IBOutlet weak var maxTickets: CustomUITextField!
    @IBOutlet weak var dressCodeTextField: UITextField!
    @IBOutlet weak var maxVenueCapacity: CustomUITextField!
    @IBOutlet weak var eventDescription: UITextField!
    
    
    @IBOutlet weak var ticketTypeName: UITextField!
    @IBOutlet weak var ticketTypeCost: CustomUITextField!
    
    @IBOutlet weak var ticketTypeTableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: LoadingButton!
    
    
    var ticketTypes: [TicketType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        ref = Constants.ref
        
        dateAndTimePicker = UIDatePicker()
        dateAndTimePicker?.datePickerMode = .dateAndTime
        dateAndTimePicker?.addTarget(self, action: #selector(dateChanged(dateAndTimePicker:)), for: .valueChanged)
        startDateAndTimeField.inputView = dateAndTimePicker
        
        dateAndTimePicker2 = UIDatePicker()
        dateAndTimePicker2?.datePickerMode = .dateAndTime
        dateAndTimePicker2?.addTarget(self, action: #selector(dateChanged2(dateAndTimePicker2:)), for: .valueChanged)
        endDateAndTimeField.inputView = dateAndTimePicker2
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        imageURLTextField.addTarget(self, action: #selector(CreateEventViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        ticketTypeTableView.delegate = self
        ticketTypeTableView.dataSource = self
        ticketTypeTableView.reloadData()
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 17.5
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.white.cgColor
        
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        cancelButton.setTitle("Cancel Event", for: .normal)
        
        confirmButton.backgroundColor = .clear
        confirmButton.layer.cornerRadius = 17.5
        confirmButton.layer.borderWidth = 2
        confirmButton.layer.borderColor = Constants.greenColor.cgColor
        confirmButton.setTitleColor(Constants.greenColor, for: .normal)
        
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        confirmButton.setTitle("Confirm Event", for: .normal)
        
        /**
        
        let alert = UIAlertController(title: "Ensure Verification.", message: "Ticket purchases will not succeed if both your identity and business profile are not verified (two green check marks).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
            */
        
    }
    
    @IBAction func addTicketTypePressed(_ sender: Any) {
        
        if (ticketTypeName.text?.isEmpty == false && ticketTypeCost.text?.isEmpty == false){
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            // localize to your grouping and decimal separator
            currencyFormatter.locale = Locale.current
            //currencyFormatter.maximumFractionDigits = 2
            
            // We'll force unwrap with the !, if you've got defined data you may need more error checking
            
            if let double = Double(ticketTypeCost.text!) {
                print("double" + String(double))
                if (double >= 1){
                    ticketTypeCost.layer.borderWidth = 0
                    let priceString = currencyFormatter.string(from: double as NSNumber)!
                    
                    print("priceString" + priceString)
                    
                    if let number = currencyFormatter.number(from: priceString) {
                        //add the type to the tableview
                        
                        
                        
                        let f = Double(truncating: number) * 100
                        
                        let newTicketType = TicketType(name: ticketTypeName.text!, price: Int(exactly: f.rounded()) ?? 0)
                        ticketTypes.append(newTicketType)
                        
                        ticketTypeName.text = ""
                        ticketTypeCost.text = ""
                        
                        ticketTypeTableView.reloadData()
                    }
                } else {
                    ticketTypeCost.layer.borderWidth = 1
                    ticketTypeCost.layer.borderColor = UIColor.red.cgColor
                    
                    let alert = UIAlertController(title: "Does not meet minimum price requirement.", message: "TicketHawk requires a minimum ticket price of $1.00", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ticketTypes.remove(at: indexPath.row)
            ticketTypeTableView.deleteRows(at: [indexPath], with: .fade)
            ticketTypeTableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.ticketTypes.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //variable type is inferred
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CELL")
        }
        
        cell!.textLabel?.text = ticketTypes[indexPath.row].name
        
        let i = ticketTypes[indexPath.row].price
        let d = Double(i) / 100
        
        print("d_value" + String(d))
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let number = formatter.string(from:  NSNumber(value: d)) {
            cell!.detailTextLabel?.text = number
        }
        
        
        
        
        return cell!
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty == false){
            let url = URL(string: imageURLTextField.text!) ?? URL(string: "www.apple.com")!
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
                self.imageURLImageView.image = UIImage(data: data)
            }
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(dateAndTimePicker: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        startDateAndTimeField.text = dateFormatter.string(from: dateAndTimePicker.date)
        //view.endEditing(true)
    
    }
    
    @objc func dateChanged2(dateAndTimePicker2: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        endDateAndTimeField.text = dateFormatter.string(from: dateAndTimePicker2.date)
        //view.endEditing(true)
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkCorrectNess() -> Bool {
        
        var shouldUpload: Bool = true
        
        if (titleTextField.text!.isEmpty){
            shouldUpload = false
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            titleTextField.layer.borderWidth = 0
        }
        
        if (startDateAndTimeField.text!.isEmpty){
            shouldUpload = false
            startDateAndTimeField.layer.borderWidth = 1
            startDateAndTimeField.layer.borderColor = UIColor.red.cgColor
        } else {
            endDateAndTimeField.layer.borderWidth = 0
        }
        
        if (endDateAndTimeField.text!.isEmpty){
            shouldUpload = false
            endDateAndTimeField.layer.borderWidth = 1
            endDateAndTimeField.layer.borderColor = UIColor.red.cgColor
        } else {
            endDateAndTimeField.layer.borderWidth = 0
        }
        
        if (Float(maxVenueCapacity.text!) ?? 1000 <= 0){
            shouldUpload = false
            maxVenueCapacity.layer.borderWidth = 1
            maxVenueCapacity.layer.borderColor = UIColor.red.cgColor
        } else {
            maxVenueCapacity.layer.borderWidth = 0
        }
        
        if (Float(maxTickets.text!) ?? 1000 <= 0){
            shouldUpload = false
            maxTickets.layer.borderWidth = 1
            maxTickets.layer.borderColor = UIColor.red.cgColor
        } else {
            maxTickets.layer.borderWidth = 0
        }
        
        if (addressField.text!.isEmpty){
            shouldUpload = false
            addressField.layer.borderWidth = 1
            addressField.layer.borderColor = UIColor.red.cgColor
        } else {
            addressField.layer.borderWidth = 0
        }
        
        if (imageURLTextField.text!.isEmpty){
            shouldUpload = false
            imageURLTextField.layer.borderWidth = 1
            imageURLTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            imageURLTextField.layer.borderWidth = 0
        }
        
        if (ticketTypes.count == 0){
            shouldUpload = false
            ticketTypeTableView.layer.borderWidth = 1
            ticketTypeTableView.layer.borderColor = UIColor.red.cgColor
        } else {
            ticketTypeTableView.layer.borderWidth = 0
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        endDateAndTimeField.layer.borderWidth = 0
        startDateAndTimeField.layer.borderWidth = 0
        
        if let d1 = dateFormatter.date(from: startDateAndTimeField.text!){
            if let d2 = dateFormatter.date(from: endDateAndTimeField.text!){
                
                
                
                if (d1 < Date()) {shouldUpload = false
                    startDateAndTimeField.layer.borderWidth = 1
                    startDateAndTimeField.layer.borderColor = UIColor.red.cgColor
                }
                if (d2 < Date()) {shouldUpload = false
                    endDateAndTimeField.layer.borderWidth = 1
                    endDateAndTimeField.layer.borderColor = UIColor.red.cgColor
                }
                
                if (d1 > d2) {shouldUpload = false
                    startDateAndTimeField.layer.borderWidth = 1
                    startDateAndTimeField.layer.borderColor = UIColor.red.cgColor
                    endDateAndTimeField.layer.borderWidth = 1
                    endDateAndTimeField.layer.borderColor = UIColor.red.cgColor
                }
                
            }else {
                shouldUpload = false
                endDateAndTimeField.layer.borderWidth = 1
                endDateAndTimeField.layer.borderColor = UIColor.red.cgColor
            }
        } else {
            shouldUpload = false
            startDateAndTimeField.layer.borderWidth = 1
            startDateAndTimeField.layer.borderColor = UIColor.red.cgColor
        }
        
        return shouldUpload
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
        confirmButton.showLoading()
        confirmButton.isEnabled = false
        
        //Write to Firebase Database
        
        //Check for correctness constraints
        
        let shouldUpload: Bool = checkCorrectNess()
        
        if (shouldUpload){
            //Upload the event using required and optional fields
            
            let key = ref?.child("vendors").child(Auth.auth().currentUser!.uid).child("events").childByAutoId().key
            
            
            
            let post = ["eventTitle": titleTextField.text!,
                "startDateAndTime": startDateAndTimeField.text!,
                "endDateAndTime": endDateAndTimeField.text!,
                "location": addressField.text!,
                "pictureURL": imageURLTextField.text!,
            
                "maxTickets": Int(maxTickets.text!) ?? nil,
                "dressCode": String(dressCodeTextField.text!) ?? nil,
                "totalVenueCapacity": Int(maxVenueCapacity.text!) ?? nil,
                "description" : String(eventDescription.text!) ?? nil,
                
                "going" : 0,
                "netSales" : 0,
                "grossSales" : 0,
                
                "key" : key!
                
                ] as [String : Any]
            
                        
                let update1 = ["/vendors/\(Auth.auth().currentUser!.uid)/events/\(key!)/": post]
                self.ref?.updateChildValues(update1)
                    
                    var ticketDictionary: Dictionary = [:] as [String: Any]
                
                for t in self.ticketTypes {
                        ticketDictionary[t.name] = t.price
                    }
                    
                    let update2 =  ["/vendors/\(Auth.auth().currentUser!.uid)/events/\(key!)/ticketTypes/": ticketDictionary]
                self.ref?.updateChildValues(update2)
                    
                    self.navigationController?.popViewController(animated: true)
        }
        
        
        
        
    }
    
    
}
