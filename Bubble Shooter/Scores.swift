//
//  Scores.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/7/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Scores: NSManagedObject {
    let key = "Scores"
    let levelKey = "level"
    let scoreKey = "score"
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
        let request = NSFetchRequest(entityName: key)
        request.returnsObjectsAsFaults = false
        
        let results : NSArray
        do {
            results = try (self.managedObjectContext?.executeFetchRequest(request))!
            print("loaded \(results)")
        }
        catch {
            results = NSArray()
        }
        
        for var i=0;i<results.count;i++ {
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

        for var i=0;i<results.count;i++ {
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
            print("loaded \(results)")
        }
        catch {
            results = NSArray()
        }
        
        return results
    }
    
   /* func reset() {
        let results = load()
        for var i=0;i<results.count;i++ {
            self.managedObjectContext?.deleteObject(results[i] as! NSManagedObject)
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            print("reset failed")
        }
    }*/
}
