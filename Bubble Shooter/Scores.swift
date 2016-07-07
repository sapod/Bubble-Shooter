//
//  Scores.swift
//  Bubble Shooter
//
//  Created by sapir oded on 7/7/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import Foundation
import CoreData


class Scores: NSManagedObject {
    @NSManaged var level: NSNumber?
    @NSManaged var score: NSNumber?
    
    
}
