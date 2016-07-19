//
//  MenuViewController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/11/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: false)
    }
}