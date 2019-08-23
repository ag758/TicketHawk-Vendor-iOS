//
//  CustomerAccountViewController.swift
//  TicketHawk
//
//  Created by Austin Gao on 8/3/19.
//  Copyright © 2019 Austin Gao. All rights reserved.
//

import UIKit

class CustomerAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        
        self.navigationController!.navigationBar.barTintColor = UIColor.black
        
        let logo = UIImage(named: "thawk_transparent.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
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
