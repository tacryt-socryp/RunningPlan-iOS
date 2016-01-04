//
//  OnboardViewController.swift
//  Running Plan
//
//  Created by Logan Allen on 12/30/15.
//  Copyright © 2015 Logan Allen. All rights reserved.
//


import UIKit

class OnboardViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    enum pickerTypes {
        case None
        case Mileage(UITextField)
        case DaysWeek(UITextField)
        case LastRace(UITextField)
        case FinishTime(UITextField)

        func value() -> UITextField? {
            switch self {
            case .None:
                return nil
            case .Mileage(let v):
                return v
            case .DaysWeek(let v):
                return v
            case .LastRace(let v):
                return v
            case .FinishTime(let v):
                return v
            }
        }
    }
    var currentPickerType: pickerTypes = .None { didSet {
        changePickerOptions(currentPickerType)
    } }
    var pickerOptions: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }

    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet weak var currMilesWeek: UITextField!
    var dataMileage: Double? {
        if let text = currMilesWeek?.text {
            return Double(text)
        }
        return nil
    }
    
    @IBOutlet weak var numDays: UITextField!
    var dataNumDays: Int32? {
        if let text = numDays?.text {
            return Int32(text)
        }
        return nil
    }

    @IBOutlet weak var lastRaceType: UITextField!
    @IBOutlet weak var raceFinishTime: UITextField!

    @IBAction func nextButton() {
        if dataMileage != nil && dataNumDays != nil && raceFinishTime?.text != nil && lastRaceType?.text != nil {
            let totalTimeString = raceFinishTime.text!.componentsSeparatedByString(":")
            let totalTime = 60 * Int(totalTimeString[0])! + Int(totalTimeString[1])!
            var numMiles: Double
            switch lastRaceType.text! {
            case "5K":
                numMiles = 3.14
            case "10K":
                numMiles = 6.28
            case "Half Marathon":
                numMiles = 13.1
            case "Marathon":
                numMiles = 26.2
            default:
                numMiles = 0
            }
            let goalRace = Run(duration: Double(totalTime), numMiles: numMiles, runType: lastRaceType.text!)

            let model = PlanModel(numberOfDays: dataNumDays!, mileage: dataMileage!, goalRace: goalRace)
            PlanModel.setData(model) { (success: Bool) in
                self.updatePlan()
            } // closure to dismiss view controller once data has been saved
        } else {
            let alert = UIAlertController(title: "", message: "Please complete all of the fields.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func updatePlan() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let planVC = appDelegate.window?.rootViewController?.childViewControllers[0] as? PlanViewController
        if planVC != nil {
            planVC!.didChangePlan()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func openPicker() {
        pickerView.hidden = false
        pickerView.setNeedsDisplay()
    }

    func changePickerOptions(newPickerType: pickerTypes) {
        var newOptions: [String] = []
        switch newPickerType {
        case .None:
            break
        case .Mileage:
            for i in 0...100 {
                newOptions.append(String(i))
            }
        case .DaysWeek:
            newOptions = [
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7"
            ]
        case .LastRace:
            newOptions = [
                "5K",
                "10K",
                "Half Marathon",
                "Marathon"
            ]
        case .FinishTime:
            var iString: String
            var jString: String
            for i in 13...59 {
                for j in 0...59 {
                    if i < 10 {
                        iString = "0" + String(i)
                    } else {
                        iString = String(i)
                    }
                    if j < 10 {
                        jString = "0" + String(j)
                    } else {
                        jString = String(j)
                    }
                    newOptions.append(iString + ":" + jString)
                }
            }
        }
        pickerOptions = newOptions
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField {
        case currMilesWeek: currentPickerType = .Mileage(textField)
        case numDays: currentPickerType = .DaysWeek(textField)
        case lastRaceType: currentPickerType = .LastRace(textField)
        case raceFinishTime: currentPickerType = .FinishTime(textField)
        default: break
        }
        openPicker()
        return false // do not show keyboard nor cursor
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let textField = currentPickerType.value() {
            textField.text = pickerOptions[row]
        }
        // put a done button
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        currMilesWeek.delegate = self
        numDays.delegate = self
        lastRaceType.delegate = self
        raceFinishTime.delegate = self

        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.hidden = true
    }
    
}
