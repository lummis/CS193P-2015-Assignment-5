//
//  SettingsVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/11/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var brickSizeControl: UISegmentedControl!
    @IBOutlet weak var numberOfRowsStepper: UIStepper!
    @IBOutlet weak var ballPushStrengthSlider: UISlider!
    @IBOutlet weak var showGameTimeSwitch: UISwitch!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var bricksVC: BricksVC!
    var settingsViewEntered = false
    
    // settable parameters
    var brickSize: CGSize!
    var ballPushStrength: CGFloat!
    var showGameTime: Bool!
    var brickRows: Int!
    
    // set false when view appears, set true if user changes a setting
    var settingsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarViewControllers = tabBarController!.viewControllers as! [UIViewController]
        bricksVC = tabBarViewControllers[0] as! BricksVC
        
        brickSize = Constant.DefaultBrickSize
        ballPushStrength = Constant.DefaultPushStrength
        showGameTime = Constant.DefaultShowTime
        brickRows = Constant.DefaultBrickRows
        
        numberOfRowsStepper.value = Double(Constant.DefaultBrickRows)
        numberOfRowsStepper.addTarget(self, action: "setNumberOfRows", forControlEvents: .ValueChanged)
        
        ballPushStrengthSlider.value = Float(ballPushStrength)
        ballPushStrengthSlider.addTarget(self, action: "setBallPushStrength", forControlEvents: .ValueChanged)
        
        showGameTimeSwitch.on = showGameTime
        showGameTimeSwitch.addTarget(self, action: "showGameTimeSwitchChanged", forControlEvents: .ValueChanged)
        
        brickSizeControl.addTarget(self, action: "setBrickSize", forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        settingsViewEntered = true
        settingsChanged = false
    }
    
    func setNumberOfRows() {
        brickRows = Int(numberOfRowsStepper.value)
        settingsChanged = true
    }
    
    func setBallPushStrength() {
        ballPushStrength = CGFloat(ballPushStrengthSlider.value)
        settingsChanged = true
    }
    
    func showGameTimeSwitchChanged() {
        showGameTime = showGameTimeSwitch.on
        settingsChanged = true
    }
    
    func setBrickSize() {
        switch brickSizeControl.selectedSegmentIndex {
        case 0:
            brickSize = Constant.BrickSize0
        case 1:
            brickSize = Constant.BrickSize1
        case 2:
            brickSize = Constant.BrickSize2
        case 3:
            brickSize = Constant.BrickSize3
        default:
            break
        }
        settingsChanged = true
    }
    
    // called from BricksVC when it sees that user defaults contains saved data
    func updateFromUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let width = defaults.floatForKey("brickWidth")
        if width != 0 {
            let height = defaults.floatForKey("brickHeight")
            brickSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            showGameTime = defaults.boolForKey("showTime")
            ballPushStrength = CGFloat(defaults.floatForKey("pushStrength"))
            brickRows = Int(defaults.integerForKey("rows"))
        }
    }
    
}
