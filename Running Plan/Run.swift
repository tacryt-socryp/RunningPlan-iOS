//
//  Run.swift
//  Running Plan
//
//  Created by Logan Allen on 1/2/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//

import Foundation

class Run: NSObject, NSCoding {
    var duration: Double
    var dayNum: Int
    var runType: String
    var numMiles: Double

    var pace: Int {
        return Int(duration / numMiles)
    }

    var showPace: String {
        return convertToTime(pace)
    }

    var showDuration: String {
        return convertToTime(Int(duration))
    }

    struct PropertyKey {
        static let duration = "duration"
        static let dayNum = "dayNum"
        static let runType = "runType"
        static let numMiles = "numMiles"
    }

    func convertToTime(num: Int) -> String {
        let hr = String(num / 3600)
        var mn = String((num % 3600) / 60)
        var sc = String((num % 3600) % 60)
        if NSNumberFormatter().numberFromString(sc)?.doubleValue < 10 {
            sc = "0" + sc
        }
        if num < 3600 {
            return "\(mn):\(sc)"
        } else {
            if NSNumberFormatter().numberFromString(mn)?.doubleValue < 10 {
                mn = "0" + mn
            }
            return "\(hr):\(mn):\(sc)"
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(duration, forKey: PropertyKey.duration)
        aCoder.encodeObject(dayNum, forKey: PropertyKey.dayNum)
        aCoder.encodeObject(runType, forKey: PropertyKey.runType)
        aCoder.encodeDouble(numMiles, forKey: PropertyKey.numMiles)
    }

    // Archives the data.
    required convenience init?(coder aDecoder: NSCoder) {
        guard let duration = aDecoder.decodeDoubleForKey(PropertyKey.duration) as Double?,
            let dayNum = aDecoder.decodeObjectForKey(PropertyKey.dayNum) as? Int,
            let runType = aDecoder.decodeObjectForKey(PropertyKey.runType) as? String,
            let numMiles = aDecoder.decodeDoubleForKey(PropertyKey.numMiles) as Double?
            else { return nil }

        self.init(
            duration: duration,
            numMiles: numMiles,
            runType: runType,
            dayNum: dayNum
        )
    }

    init(duration: Double, numMiles: Double, runType: String = "", dayNum: Int = -1) {
        self.duration = duration
        self.numMiles = numMiles
        self.runType = runType
        self.dayNum = dayNum
        super.init()
    }
}