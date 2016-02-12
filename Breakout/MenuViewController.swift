//
//  MenuViewController.swift
//  Breakout
//
//  Created by Ben Vest on 2/11/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
  let defaults = NSUserDefaults.standardUserDefaults()
  
  @IBAction func playGame(sender: UIButton) { performSegueWithIdentifier("Play", sender: self) }
  
  @IBAction func goToSettings(sender: UIButton) { performSegueWithIdentifier("Settings", sender: self) }
  
  @IBAction func playerHistory(sender: UIButton) { performSegueWithIdentifier("User", sender: self) }
  
  @IBOutlet weak var usernameField: UITextField! {
    didSet {
      if defaults.stringForKey("username") != "" {
        usernameField.text = defaults.stringForKey("username")
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if let bvc = segue.destinationViewController as? UITabBarController {
        switch identifier {
          case "Play":
            bvc.selectedIndex = 0
          case "Settings":
            bvc.selectedIndex = 1
              
            if let tvc = bvc.selectedViewController as? UINavigationController {
              let svc = tvc.viewControllers[0] as? SettingsViewController
              print(svc)
            }
          case "User":
            bvc.selectedIndex = 2
        default: break
        }
      }
    }
  }
}

        
    

