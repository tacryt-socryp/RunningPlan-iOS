//
//  MainNavViewController.swift
//  Running Plan
//
//  Created by Logan Allen on 12/30/15.
//  Copyright © 2015 Logan Allen. All rights reserved.
//

import UIKit

class MainNavViewController: UINavigationController {

    var model: PlanModel? = nil
    // we want model to be used as a data source for PlanView

    override func viewDidLoad() {
        let m = PlanModel.getData()
        if m != nil && model == nil {
            model = m
        }
    }

    override func viewDidAppear(animated: Bool) {
        if model == nil {
            self.performSegueWithIdentifier("onboardSegue", sender: self)
        }
    }
}