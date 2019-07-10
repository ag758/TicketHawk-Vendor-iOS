//
//  CreateEventViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/6/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var dateAndTimePicker: UIDatePicker?
    private var dateAndTimePicker2: UIDatePicker?

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
    
    var ticketTypes: [TicketType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        
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
        
    }
    
    @IBAction func addTicketTypePressed(_ sender: Any) {
        if (ticketTypeName.text?.isEmpty == false && ticketTypeCost.text?.isEmpty == false){
            
            let str = "$" + ticketTypeCost.text!
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            
            if let number = formatter.number(from: str) {
                let amount = number.decimalValue
                
                //add the type to the tableview
                let newTicketType = TicketType(name: ticketTypeName.text!, price: amount)
                ticketTypes.append(newTicketType)
                
                ticketTypeTableView.reloadData()
                
                
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
        cell!.detailTextLabel?.text = NSDecimalNumber(decimal: ticketTypes[indexPath.row].price).stringValue
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //intendedCommunity = communities[indexPath.row]
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty == false){
            let url = URL(string: imageURLTextField.text!)!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
