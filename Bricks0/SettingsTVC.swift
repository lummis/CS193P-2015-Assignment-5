//
//  SettingsTVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/20/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    
    @IBOutlet weak var brickSizeL: UILabel!
    @IBOutlet weak var nRowsL: UILabel!
    @IBOutlet weak var showTimeL: UILabel!
    @IBOutlet weak var pushStrengthL: UILabel!
    
    var settingsVC: SettingsVC?
    
    // initialize with dummy values
    var brickSize: CGSize = CGSizeZero
    var ballPushStrength: CGFloat = CGFloat(0)
    var showGameTime: Bool = false
    var brickRows: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateTable()
    }

    // put current parameter values into the table rows
    // get current values by settingsVC!.getParameters()
    // which gets them from the userDefaults file, or from Parameter.Default...
    // if the userDefaults file is empty
    func updateTable () {
        (brickSize, ballPushStrength, showGameTime, brickRows) = settingsVC!.getParameters()
        let spaces = "          "   // used to indent text in table rows
        brickSizeL.text = spaces + String(format: "%2.0f x %2.0f points", settingsVC!.brickSize.width, settingsVC!.brickSize.height)
        nRowsL.text = spaces + String(format: "%d", settingsVC!.brickRows)
        let yesNo: String = settingsVC!.showGameTime ? "YES" : "NO"
        // parens are needed because the ternary operator has lower priority than addition
        showTimeL.text = spaces + (settingsVC!.showGameTime ? "YES" : "NO")
        let pushStrengthMultiplier = CGFloat(200)  // to put the displayed value in the range 20 to 100 for convenience
        pushStrengthL.text = spaces + String(format: "%4.2f", pushStrengthMultiplier * settingsVC!.ballPushStrength)
    }

}
