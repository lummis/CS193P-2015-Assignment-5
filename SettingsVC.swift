//
//  SettingsVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/11/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

struct Parameter {
    static let BrickSize0 = CGSize(width: 15, height: 10)
    static let BrickSize1 = CGSize(width: 30, height: 20)
    static let BrickSize2 = CGSize(width: 50, height: 25)
    static let BrickSize3 = CGSize(width: 70, height: 35)

    static let NumberOfParameters = 4
    static let DefaultPushStrength = CGFloat(0.15)
    static let DefaultBrickSize = BrickSize1
    static let DefaultBrickRows = 2
    static let DefaultShowTime = false
}

class SettingsVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var brickSizeControl: UISegmentedControl!
    @IBOutlet weak var numberOfRowsStepper: UIStepper!
    @IBOutlet weak var ballPushStrengthSlider: UISlider!
    @IBOutlet weak var showGameTimeSwitch: UISwitch!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var bricksVC: BricksVC!
    var settingsTVC: SettingsTVC?
    
    // settable parameters initialized to dummy values then reset in viewDidLoad
    var brickSize = CGSizeZero
    var ballPushStrength = CGFloat(0)
    var showGameTime = false
    var brickRows = 0
    
    // initialize to true; set false when view appears; set true when user changes a setting
    // so false means this view did appear but the user didn't change anything
    var userChangedSettings = true {
        didSet {
            if userChangedSettings {
                println("userChangedSettings: " + (userChangedSettings ? "true" : "false"))
                persistParameters()
//                settingsTVC?.updateTable()
            }
        }
    }
    
    override func viewDidLoad() {
        println("SettingsVC / viewDidLoad")
        super.viewDidLoad()
        
        setupControls(getParameters())
    }
    
    override func viewDidAppear(animated: Bool) {
        println("SettingsVC / viewDidAppear")
        super.viewDidAppear(animated)
        
        RCLElapsedTimer.sharedTimer.pause()
        userChangedSettings = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "TableEmbedSegue" {
            println("segue callback")
            settingsTVC = (segue.destinationViewController as! SettingsTVC) // parens to supress warning
            settingsTVC!.settingsVC = self
        }
    }
    
    // return 4 parameters from defaults file or from Parameter.Default...
    func getParameters() -> (brickSize: CGSize, ballPushStrength: CGFloat, showGameTime: Bool, brickRows: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let width = defaults.floatForKey("brickWidth")
        
        // if width is not 0 then user defaults contains valid data
        if width != 0 {
            let height = defaults.floatForKey("brickHeight")
            brickSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            showGameTime = defaults.boolForKey("showTime")
            ballPushStrength = CGFloat(defaults.floatForKey("pushStrength"))
            brickRows = Int(defaults.integerForKey("rows"))
            
        // on first run user defaults is empty so use Default... values
        } else {
            brickSize = Parameter.DefaultBrickSize
            ballPushStrength = Parameter.DefaultPushStrength
            showGameTime = Parameter.DefaultShowTime
            brickRows = Parameter.DefaultBrickRows
            persistParameters()
        }
        
        return (brickSize, ballPushStrength, showGameTime, brickRows)
    }
    
    // convenience func name
    func persistParameters() {
        persistParameters(brickSize: brickSize,
            ballPushStrength: ballPushStrength,
            showGameTime: showGameTime,
            brickRows: brickRows)
    }
    
    func persistParameters(#brickSize: CGSize, ballPushStrength: CGFloat, showGameTime: Bool, brickRows: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(Float(brickSize.width), forKey: "brickWidth")
        defaults.setFloat(Float(brickSize.height), forKey: "brickHeight")
        defaults.setFloat(Float(ballPushStrength), forKey: "pushStrength")
        defaults.setBool(showGameTime, forKey: "showTime")
        defaults.setInteger(brickRows, forKey: "rows")
    }
    
    func setupControls(parameters: (CGSize, CGFloat, Bool, Int)) {
        let (size, strength, showTime, nRows) = parameters
        
        brickSizeControl.addTarget(self, action: "setBrickSize", forControlEvents: .ValueChanged)
        var index = -1
        switch size {
        case Parameter.BrickSize0:
            index = 0
        case Parameter.BrickSize1:
            index = 1
        case Parameter.BrickSize2:
            index = 2
        case Parameter.BrickSize3:
            index = 3
        default:
            index = -1   // impossible value to cause a crash
            break
        }
        brickSizeControl.selectedSegmentIndex = index
        
        numberOfRowsStepper.addTarget(self, action: "setNumberOfRows", forControlEvents: .ValueChanged)
        numberOfRowsStepper.value = Double(nRows)
        
        showGameTimeSwitch.addTarget(self, action: "showGameTimeSwitchChanged", forControlEvents: .ValueChanged)
        showGameTimeSwitch.on = showTime
        
        ballPushStrengthSlider.addTarget(self, action: "setBallPushStrength", forControlEvents: .ValueChanged)
        ballPushStrengthSlider.value = Float(strength)
    }
    
    func setBrickSize() {
        switch brickSizeControl.selectedSegmentIndex {
        case 0:
            brickSize = Parameter.BrickSize0
        case 1:
            brickSize = Parameter.BrickSize1
        case 2:
            brickSize = Parameter.BrickSize2
        case 3:
            brickSize = Parameter.BrickSize3
        default:
            break
        }
        persistParameters()
        userChangedSettings = true
    }
    
    func setNumberOfRows() {
        brickRows = Int(numberOfRowsStepper.value)
        persistParameters()
        userChangedSettings = true
    }
    
    func showGameTimeSwitchChanged() {
        showGameTime = showGameTimeSwitch.on
        persistParameters()
//        userChangedSettings = true
    }
    
    func setBallPushStrength() {
        ballPushStrength = CGFloat(ballPushStrengthSlider.value)
        persistParameters()
        userChangedSettings = true
    }
}
