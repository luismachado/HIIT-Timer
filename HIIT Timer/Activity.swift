//
//  Activity.swift
//  HIIT Timer
//
//  Created by Luís Machado on 18/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import Foundation
import UIKit

class Activity: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String
    var exerciseDistance: Int
    var exerciseSeconds: Int
    var restDistance: Int
    var restSeconds: Int
    var exerciseModeIsDistance:Bool
    var restModeIsDistance:Bool
    var numOfRepeats:Int
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("activities")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let exerciseDistanceKey = "exerciseDistance"
        static let exerciseSecondsKey = "exerciseSeconds"
        static let restDistanceKey = "restDistance"
        static let restSecondsKey = "restSeconds"
        static let exerciseModeIsDistanceKey = "exerciseModeIsDistance"
        static let restModeIsDistanceKey = "restModeIsDistance"
        static let numOfRepeatsKey = "numOfRepeats"
    }
    
    // MARK: Initialization
    init?(name: String, exerciseDistance: Int, exerciseSeconds: Int, restDistance: Int, restSeconds: Int, exerciseModeIsDistance: Bool, restModeIsDistance: Bool, numOfRepeats: Int) {
        // Initialize stored properties.
        self.name = name
        self.exerciseDistance = exerciseDistance
        self.exerciseSeconds = exerciseSeconds
        self.restDistance = restDistance
        self.restSeconds = restSeconds
        self.exerciseModeIsDistance = exerciseModeIsDistance
        self.restModeIsDistance = restModeIsDistance
        self.numOfRepeats = numOfRepeats
        
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        /*if name.isEmpty || weight < 0 {
            return nil
        }*/
    }
    
    
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(exerciseDistance, forKey: PropertyKey.exerciseDistanceKey)
        aCoder.encode(exerciseSeconds, forKey: PropertyKey.exerciseSecondsKey)
        aCoder.encode(restDistance, forKey: PropertyKey.restDistanceKey)
        aCoder.encode(restSeconds, forKey: PropertyKey.restSecondsKey)
        aCoder.encode(exerciseModeIsDistance, forKey: PropertyKey.exerciseModeIsDistanceKey)
        aCoder.encode(restModeIsDistance, forKey: PropertyKey.restModeIsDistanceKey)
        aCoder.encode(numOfRepeats, forKey: PropertyKey.numOfRepeatsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let exerciseDistance = aDecoder.decodeInteger(forKey: PropertyKey.exerciseDistanceKey)
        let exerciseSeconds = aDecoder.decodeInteger(forKey: PropertyKey.exerciseSecondsKey)
        let restDistance = aDecoder.decodeInteger(forKey: PropertyKey.restDistanceKey)
        let restSeconds = aDecoder.decodeInteger(forKey: PropertyKey.restSecondsKey)
        let exerciseModeIsDistance = aDecoder.decodeBool(forKey: PropertyKey.exerciseModeIsDistanceKey)
        let restModeIsDistance = aDecoder.decodeBool(forKey: PropertyKey.restModeIsDistanceKey)
        let numOfRepeats = aDecoder.decodeInteger(forKey: PropertyKey.numOfRepeatsKey)
        
        // Must call designated initializer.
        self.init(name: name, exerciseDistance: exerciseDistance, exerciseSeconds: exerciseSeconds, restDistance: restDistance, restSeconds: restSeconds, exerciseModeIsDistance: exerciseModeIsDistance, restModeIsDistance: restModeIsDistance, numOfRepeats: numOfRepeats)
    }
    
}
