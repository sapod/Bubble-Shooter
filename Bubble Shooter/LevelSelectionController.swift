//
//  LevelSelectionController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 5/24/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import Foundation
import UIKit

class LevelSelectionController: UIViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let svc = segue.destinationViewController as! GameViewController
        let str = ((sender as! UIButton).titleLabel?.text)! as String
        switch(str) {
        case "1":
            print("level 1 selected")
            svc.levelNum = 1
            break
        case "2":
            print("level 2 selected")
            svc.levelNum = 2
            break
        case "3":
            print("level 3 selected")
            svc.levelNum = 3
            break
        case "4":
            print("level 4 selected")
            svc.levelNum = 4
            break
        default:
            print("segue error: \(str)")
        }
    }
}