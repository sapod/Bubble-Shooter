//
//  GameViewController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 3/15/16.
//  Copyright (c) 2016 sapir oded. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var scene: GameScene!
    var levelNum : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.levelNum = levelNum
        scene.navHeight = navigationController?.navigationBar.frame.height
        scene.viewController = self
        
        // Present the scene
        skView.presentScene(scene)
    }
    
    override func viewDidDisappear(animated: Bool) {
        scene.cancelLevelThread()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
