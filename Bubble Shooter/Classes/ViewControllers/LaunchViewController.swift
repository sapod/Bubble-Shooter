//
//  LaunchViewController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/11/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import UIKit
import SpriteKit

class LaunchViewController: UIViewController {
    private var icon : UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let iconImage = UIImage(named: "AppIconBig")
        let w = CGFloat(250)
        let h = iconImage!.size.height / iconImage!.size.width * w
        
        icon = UIImageView(frame: CGRect(x: view.frame.width/2-w/2, y: view.frame.height/2-h/2, width: w, height: h))
        icon.image = iconImage
        view.addSubview(icon)
        
        icon.animateFade(fadeIn: true)
        icon.animateZoom(zoomIn: true, duration: 2, completion: { [weak self] (finished) -> Void in
            guard let strongSelf = self else { return }
            
            runBlockAfterDelay(afterDelay: 1.0, block: { () -> Void in
                strongSelf.performSegueWithIdentifier("StartGame", sender: self)
            })
        })    
    }
}