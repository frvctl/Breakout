//
//  SettingsViewController.swift
//  Breakout
//
//  Created by Ben Vest on 2/8/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
  let defaults = NSUserDefaults.standardUserDefaults()
  
  var settings = [
    "bricksPerRow": 10,
    "difficulty": 1,
    "specialBricks": false,
    "numberOfBalls": 1,
    "ballBounciness": 0.5,
    "settingsChanged": false,
    "username": ""
  ]
  
  func setDefaults() {
    defaults.registerDefaults(settings)
  }
  
  //MARK: Outlet States
  @IBOutlet weak var brickLabel: UILabel! {
    didSet { brickLabel.text = "\(defaults.integerForKey("bricksPerRow"))" }
  }
  
  @IBOutlet weak var brickStepper: UIStepper! {
    didSet { brickStepper.value = Double(defaults.integerForKey("bricksPerRow")) }
  }

  @IBOutlet weak var bouncinessSlider: UISlider! {
    didSet { bouncinessSlider.value = defaults.floatForKey("ballBounciness") }
  }
  
  @IBOutlet weak var specialSwitch: UISwitch! {
    didSet { specialSwitch.on = defaults.boolForKey("specialBricks") }
  }
  
  @IBOutlet weak var ballSegmentedControl: UISegmentedControl! {
    didSet { ballSegmentedControl.selectedSegmentIndex = defaults.integerForKey("numberOfBalls") - 1 }
  }
    
  //MARK: Settings Actions
  @IBAction func brickStepper(sender: UIStepper) {
    let val = Int(sender.value)
    defaults.setInteger(val, forKey: "bricksPerRow")
    defaults.setBool(true, forKey: "settingsChanged")
    settings["bricksPerRow"] = val
    brickLabel.text = String(val)
  }
  
  @IBAction func specialBricksSwitch(sender: UISwitch) {
    let val = sender.on
    if val {
      defaults.setBool(true, forKey: "specialBricks")
      settings["specialBricks"] = true
    } else {
      defaults.setBool(false, forKey: "specialBricks")
      settings["specialBricks"] = false
    }
    
    defaults.setBool(true, forKey: "settingsChanged")
  }
  
  @IBAction func numberOfBalls(sender: UISegmentedControl) {
    let numBalls = sender.selectedSegmentIndex

    switch numBalls {
    case 0:
      defaults.setInteger(1, forKey: "numberOfBalls")
      settings["numberOfBalls"] = 1
    case 1:
      defaults.setInteger(2, forKey: "numberOfBalls")
      settings["numberOfBalls"] = 2
    case 2:
      defaults.setInteger(3, forKey: "numberOfBalls")
      settings["numberOfBalls"] = 3
    default: break
    }
    
    defaults.setBool(true, forKey: "settingsChanged")
  }
  
  @IBAction func ballBouncinessSlider(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "ballBounciness")
    defaults.setBool(true, forKey: "settingsChanged")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    setDefaults()
  }
}
