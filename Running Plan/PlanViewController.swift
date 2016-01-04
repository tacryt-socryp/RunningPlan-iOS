//
//  PlanViewController.swift
//  Running Plan
//
//  Created by Logan Allen on 12/28/15.
//  Copyright © 2015 Logan Allen. All rights reserved.
//


import UIKit

class PlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var dataSource: PlanModel? = nil
    var runningDays: [Run] = []

    @IBOutlet weak var tableView: UITableView!

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("runningDayCell") as! DayTableCell
        let run = runningDays[indexPath.row]
        cell.dayNum.text = "Day \(run.dayNum+1)"
        cell.duration.text = run.showDuration
        cell.pace.text = run.showPace
        cell.runType.text = run.runType

        return cell
    }

    @IBAction func showOnboarding(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("editSegue", sender: self)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runningDays.count
    }

    func didChangePlan() {
        dataSource = PlanModel.getData()
        if dataSource != nil {
            runningDays = dataSource!.getPlan()
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        didChangePlan()
    }
}