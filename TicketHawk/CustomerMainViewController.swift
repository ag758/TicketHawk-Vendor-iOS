//
//  CustomerMainViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 7/6/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class CustomerMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        // Do any additional setup after loading the view.
        
        
        
    }
    


}
