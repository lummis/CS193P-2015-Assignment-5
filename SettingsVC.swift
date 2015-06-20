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
    
    // settable parameters initialized to dummy values then reset in viewDidLoad
    var brickSize = CGSizeZero
    var ballPushStrength = CGFloat(0)
    var showGameTime = false
    var brickRows = 0
    
    // initialize to true; set false when view appears; set true when user changes a setting
    // so false means this view appeared but the user didn't change anything
    var userChangedSettings = true {
        didSet {
            if userChangedSettings { persistParameters() }
        }
    }
    
    override func viewDidLoad() {
        println("SettingsVC / viewDidLoad")
        super.viewDidLoad()
        
        (brickSize, ballPushStrength, showGameTime, brickRows) = getParameters()
        
        numberOfRowsStepper.value = Double(brickRows)
        numberOfRowsStepper.addTarget(self, action: "setNumberOfRows", forControlEvents: .ValueChanged)
        
        ballPushStrengthSlider.value = Float(ballPushStrength)
        ballPushStrengthSlider.addTarget(self, action: "setBallPushStrength", forControlEvents: .ValueChanged)
        
        showGameTimeSwitch.on = showGameTime
        showGameTimeSwitch.addTarget(self, action: "showGameTimeSwitchChanged", forControlEvents: .ValueChanged)
        
        brickSizeControl.addTarget(self, action: "setBrickSize", forControlEvents: .ValueChanged)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TableViewSegue" {
            println("segue callback")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        println("SettingsVC / viewDidAppear")
        super.viewDidAppear(animated)
        userChangedSettings = false
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
            
        } else {    // on first run user defaults is empty so use Default... values
            brickSize = Parameter.DefaultBrickSize
            ballPushStrength = Parameter.DefaultPushStrength
            showGameTime = Parameter.DefaultShowTime
            brickRows = Parameter.DefaultBrickRows
            persistParameters() // store into user defaults for next time
        }
        
        return (brickSize, ballPushStrength, showGameTime, brickRows)
    }
            
    func persistParameters() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(Float(brickSize.width), forKey: "brickWidth")
        defaults.setFloat(Float(brickSize.height), forKey: "brickHeight")
        defaults.setFloat(Float(ballPushStrength), forKey: "pushStrength")
        defaults.setBool(showGameTime, forKey: "showTime")
        defaults.setInteger(brickRows, forKey: "rows")
    }
    
    func setNumberOfRows() {
        brickRows = Int(numberOfRowsStepper.value)
        userChangedSettings = true
    }
    
    func setBallPushStrength() {
        ballPushStrength = CGFloat(ballPushStrengthSlider.value)
        userChangedSettings = true
    }
    
    func showGameTimeSwitchChanged() {
        showGameTime = showGameTimeSwitch.on
        userChangedSettings = true
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
        userChangedSettings = true
    }
    
    func updateParameters(#brickSize: CGSize, showGameTime: Bool,
        ballPushStrength: CGFloat, brickRows: Int) {
            self.brickSize = brickSize
            self.showGameTime = showGameTime
            self.ballPushStrength = ballPushStrength
            self.brickRows = brickRows
            
            var segment = 0
            switch brickSize {
            case Parameter.BrickSize0:
                segment = 0
            case Parameter.BrickSize1:
                segment = 1
            case Parameter.BrickSize2:
                segment = 2
            case Parameter.BrickSize3:
                segment = 3
            default:
                break
            }
    }
    
//    func tableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = table.dequeueReusableCellWithIdentifier("tablecell", forIndexPath: indexPath) as! UITableViewCell
//        cell.textLabel!.text = "hello"
//        return cell
//    }
    
}
