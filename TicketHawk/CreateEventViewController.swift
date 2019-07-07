//
//  CreateEventViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/6/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    private var dateAndTimePicker: UIDatePicker?
    private var dateAndTimePicker2: UIDatePicker?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateAndTimeField: CustomUITextField!
    @IBOutlet weak var endDateAndTimeField: CustomUITextField!
    
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
