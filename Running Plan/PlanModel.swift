//
//  PlanModel.swift
//  Running Plan
//
//  Created by Logan Allen on 12/23/15.
//  Copyright © 2015 Logan Allen. All rights reserved.
//

import Foundation

class PlanModel: NSObject, NSCoding {
    
    var numberOfDays: Int32
    var mileage: Double
    var goalRace: Run

    struct PropertyKey {
        static let numberOfDays = "numberOfDays"
        static let mileage = "mileage"
        static let goalRace = "goalRace"
    }

    // Archives the data.
    required convenience init?(coder aDecoder: NSCoder) {
        guard let numberOfDays = aDecoder.decodeIntForKey(PropertyKey.numberOfDays) as Int32?,
            let mileage = aDecoder.decodeDoubleForKey(PropertyKey.mileage) as Double?,
            let goalRace = aDecoder.decodeObjectForKey(PropertyKey.goalRace) as? Run
        else { return nil }

        self.init(
            numberOfDays: numberOfDays,
            mileage: mileage,
            goalRace: goalRace
        )
    }

    init(numberOfDays: Int32, mileage: Double, goalRace: Run) {
        self.numberOfDays = numberOfDays
        self.mileage = mileage
        self.goalRace = goalRace
        super.init()
    }

    // Prepares information to be archived.
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(numberOfDays, forKey: PropertyKey.numberOfDays)
        aCoder.encodeDouble(mileage, forKey: PropertyKey.mileage)
        aCoder.encodeObject(goalRace, forKey: PropertyKey.goalRace)
    }

    func getVOTwoMax(run: Run) -> Double {
        let numM: Double = run.numMiles * 1609 // convert to kilometers
        let duration: Double = run.duration / 60
        let velocity = numM / duration // convert to m/s

        let pMax = 0.8 + (0.1894393 * pow(M_E, -0.012778 * duration)) + (0.2989558 * pow(M_E, -0.1932605 * duration))
        let vo2 = -4.60 + (0.182258 * velocity) + (0.000104 * velocity * velocity)
        return (vo2 / pMax)
    }

    // returned in miles / min
    func getVelFromVOTwo(vo2Max: Double) -> Double {
        return (29.54 + 5.000663 * vo2Max - 0.007546 * vo2Max * vo2Max)
    }

    func getPaceFromVOTwo(vo2Max: Double) -> Double {
        let pace = getVelFromVOTwo(vo2Max)
        return 1 / ((1 / pace) * 1609 * 60) // conversion to miles / min
    }

    func getTrainingPaces(vo2Max: Double) -> [String:Double] {
        let velEasy = getPaceFromVOTwo(vo2Max * 0.7)
        let velTempo = getPaceFromVOTwo(vo2Max * 0.88)
        let velxlong = getPaceFromVOTwo(vo2Max * 0.6)
        // let velMaximum = getPaceFromVOTwo(vo2Max)
        // let velSpeed = getPaceFromVOTwo(vo2Max * 1.1)
        // let velYasso = velMaximum * 1.95
        return [
            "Easy Run": velEasy,
            "Tempo Run": velTempo,
            "Long Run": velxlong
        ]
    }

    func getPlan() -> [Run] {
        var plan: [Run] = []
        let vo2Max = getVOTwoMax(goalRace)
        let trainingPaces = getTrainingPaces(vo2Max)

        var avgDist = mileage / Double(numberOfDays)
        let longDist = 1.15 * avgDist
        avgDist = (mileage - longDist) / Double(numberOfDays - 1)
        let tempoDist = 1.25 * avgDist
        let easyDist = 0.75 * avgDist

        for i in 0..<numberOfDays {
            if i == 0 {
                let duration = longDist / trainingPaces["Long Run"]!
                plan.append(Run(duration: duration, numMiles: longDist, runType: "Long Run", dayNum: Int(i)))
            } else if i % 2 == 0 {
                let duration = tempoDist / trainingPaces["Tempo Run"]!
                plan.append(Run(duration: duration, numMiles: tempoDist, runType: "Tempo Run", dayNum: Int(i)))
            } else {
                let duration = easyDist / trainingPaces["Easy Run"]!
                plan.append(Run(duration: duration, numMiles: easyDist, runType: "Easy Run", dayNum: Int(i)))
            }
        }
        return plan
    }

    static func setData(plan: PlanModel, completionHandler: ((success: Bool) -> Void)) {
        let dataObject = NSKeyedArchiver.archivedDataWithRootObject(plan)
        NSUserDefaults.standardUserDefaults().setObject(dataObject, forKey: "runningPlan")
        completionHandler(success: true)
    }

    static func getData() -> PlanModel? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("runningPlan") {
            let plan = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? PlanModel
            return plan
        }
        return nil
    }
}
