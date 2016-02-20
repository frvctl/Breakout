//
//  MenuViewController.swift
//  Breakout
//
//  Created by Ben Vest on 2/11/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITextFieldDelegate {
  let defaults = NSUserDefaults.standardUserDefaults()
  
  @IBAction func playGame(sender: UIButton) {
    print(defaults.stringForKey("username"))
    performSegueWithIdentifier("Play", sender: self)
  }
  
  @IBAction func goToSettings(sender: UIButton) {
    performSegueWithIdentifier("Settings", sender: self)
  }
  
  @IBOutlet weak var usernameField: UITextField! {
    didSet {
      if defaults.stringForKey("username") != "" {
        usernameField.text = defaults.stringForKey("username")
      }
    }
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    defaults.setObject(usernameField.text!, forKey: "username")
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    usernameField.delegate = self;
  }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if let bvc = segue.destinationViewController as? UITabBarController {
        switch identifier {
          case "Play":
            bvc.selectedIndex = 0
          case "Settings":
            bvc.selectedIndex = 1
          default: break
        }
      }
    }
  }
}


