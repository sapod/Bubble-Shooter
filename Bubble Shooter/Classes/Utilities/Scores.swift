//
//  Scores.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/7/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import CoreData
import UIKit

class Scores: NSManagedObject {
    private let key = "Scores"
    private let levelKey = "level"
    private let scoreKey = "score"
    @NSManaged var level: NSNumber?
    @NSManaged var score: NSNumber?
 
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext c: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: c)  
    }
    
    static func getInstance() -> Scores {
        let instance : Scores!
        let appDelegate: AppDelegate = ((UIApplication.sharedApplication()).delegate as? AppDelegate)!
        let moc = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Scores", inManagedObjectContext: moc)
        
        instance = Scores.init(entity: entity!, insertIntoManagedObjectContext: moc)
        return instance
    }
    
    func remove() -> Bool {
        self.managedObjectContext?.deleteObject(self)
        return true
    }
    
    func checkDB() {
        if load().count < GameScene.numOfLevels {
            for i in 1 ..< GameScene.numOfLevels+1 {
                insert(i, score: 0)
            }
        }
    }
    
    func insert(level: NSNumber, score: NSNumber) -> Bool {
        let item = NSEntityDescription.insertNewObjectForEntityForName(key, inManagedObjectContext: self.managedObjectContext!) as NSManagedObject
        item.setValue(level, forKey: levelKey)
        item.setValue(score, forKey: scoreKey)
        
        do {
            try self.managedObjectContext?.save()
            print("saved \(item)")
            return true
        }
        catch {
            return false
        }
    }
    
    func update(l: Int, s: Int) {
        let results = load()
        
        for i in 0 ..< results.count {
            if results[i].valueForKey(levelKey)! as! Int == l {
                results[i].setValue(s, forKey: scoreKey)
                do {
                    try self.managedObjectContext?.save()
                } catch {
                    print("Updating level \(l) score failed")
                }
                return
            }
        }
    }
    
    func loadLevelScore(l: Int) -> Int {
        let results = load()

        for i in 0 ..< results.count {
            if results[i].valueForKey(levelKey)! as! Int == l {
                return results[i].valueForKey(scoreKey)! as! Int
            }
        }
        return -1
    }
    
    func load() -> NSArray {
        let request = NSFetchRequest(entityName: key)
        request.returnsObjectsAsFaults = false
        
        let results : NSArray
        do {
            results = try (self.managedObjectContext?.executeFetchRequest(request))!
        }
        catch {
            results = NSArray()
        }
        
        return results
    }
    
    func reset() {
        let results = load()
        for i in 0 ..< results.count {
            results[i].setValue(0, forKey: scoreKey)
        }
        do {
            try self.managedObjectContext?.save()
        } catch {
            print("reset failed")
        }
    }
}
