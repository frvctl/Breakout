//
//  SettingsViewController.swift
//  Breakout
//
//  Created by Ben Vest on 2/8/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
  let defaults = NSUserDefaults.standardUserDefaults()
  
  var settings = [
    "bricksPerRow": 10,
    "specialBricks": false,
    "numberOfBalls": 1,
    "ballBounciness": 0.5,
    "settingsChanged": false,
    "username": "",
    "difficulty": 1
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
  
  @IBOutlet weak var usernameField: UITextField! {
    didSet { usernameField.text = defaults.stringForKey("username") }
  }
  @IBOutlet weak var difficultySlider: UISlider! {
    didSet { difficultySlider.value = defaults.floatForKey("difficulty") }
  }
  
  //MARK: Settings Actions
  @IBAction func brickStepper(sender: UIStepper) {
    let val = Int(sender.value)
    defaults.setInteger(val, forKey: "bricksPerRow")
    settingsChanged()
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
    
    settingsChanged()
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
    
    settingsChanged()
  }
  
  @IBAction func ballBouncinessSlider(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "ballBounciness")
    settings["ballBounciness"] = sender.value
    settingsChanged()
  }
  
  @IBAction func difficultySlider(sender: UISlider) {
    defaults.setFloat(sender.value, forKey: "difficulty")
    settings["difficulty"] = sender.value
    settingsChanged()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    usernameField.resignFirstResponder()
    defaults.setObject(usernameField.text!, forKey: "username")
    defaults.setBool(true, forKey: "settingsChanged")
    settings["username"] = usernameField.text!
    return true
  }
  
  func settingsChanged() {
    defaults.setBool(true, forKey: "settingsChanged")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    usernameField.delegate = self
    setDefaults()
  }
}
