//
//  ScoresViewController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/9/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scoreTable: UITableView!
    var levels : [Int] = []
    var scores : [Int] = []
    var scoresDB : Scores!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoresDB = Scores.getInstance()
        
        for var i=1;i<=GameScene.numOfLevels;i++ {
            levels.append(i)
            scores.append(scoresDB.loadLevelScore(i))
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = scoreTable.dequeueReusableCellWithIdentifier("scoreCell", forIndexPath: indexPath) as! ScoresTableViewCell
        
        cell.levelLabel.text = "\(levels[indexPath.row])"
        cell.scoreLabel.text = "\(scores[indexPath.row])"
        return cell
    }
}