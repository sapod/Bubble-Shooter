//
//  ScoresViewController.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/9/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import UIKit
import CoreData

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scoreTable: UITableView!
    private var levels : [Int] = []
    private var scores : [Int] = []
    private var scoresDB : Scores!
    
    private let colorTable = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    private let colorOdd = UIColor(red: 0.65, green: 0.88, blue: 0.74, alpha: 1)
    private let colorEven = UIColor(red: 0.65, green: 0.88, blue: 0.85, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreTable.backgroundColor = colorTable
        scoreTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        scoreTable.separatorColor = UIColor.blackColor()
        scoreTable.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 8)
        scoreTable.allowsSelection = false
        
        scoresDB = Scores.getInstance()
        scoresDB.checkDB()
        
        for i in 1 ..< GameScene.numOfLevels+1 {
            levels.append(i)
            scores.append(scoresDB.loadLevelScore(i))
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = scoreTable.dequeueReusableCellWithIdentifier("scoreCell", forIndexPath: indexPath) as! ScoresTableViewCell
        
        cell.backgroundColor = colorTable
        
        if indexPath.row != 0 {
            cell.levelLabel.text = "\(levels[indexPath.row-1])"
            cell.levelLabel.backgroundColor = colorEven
            cell.scoreLabel.text = "\(scores[indexPath.row-1])"
            cell.scoreLabel.backgroundColor = colorOdd
        } else {
            cell.levelLabel.textColor = UIColor.darkGrayColor()
            cell.scoreLabel.textColor = UIColor.darkGrayColor()
        }
        
        return cell
    }
}