//
//  BricksVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

 struct Constant {
    
    static let BrickSize0 = CGSize(width: 15, height: 10)
    static let BrickSize1 = CGSize(width: 30, height: 20)
    static let BrickSize2 = CGSize(width: 50, height: 25)
    static let BrickSize3 = CGSize(width: 70, height: 35)
    
    static let DefaultPushStrength = CGFloat(0.15)
    static let DefaultBrickSize = BrickSize1
    static let DefaultBrickRows = 2
    static let DefaultShowTime = false
    static let BallSize = CGSize(width:25, height:25)
    static let BricksSideSpace = CGFloat(15)    // hor. distance from side bricks to gameView
    static let BricksTopSpace = CGFloat(10)     // vert. distance from top bricks to gameView
    static let BrickRowSpacing = CGFloat(12)    // vert. distance between brick rows
    static let InitialBallPosition = CGPoint(x: 150, y: 300)
}

class BricksVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, UIAlertViewDelegate
{

    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameTimeLabel: UILabel!
 
    // the animator will be created the first time it is referenced
    // this satisfied the rule that everything has to be initialized but this can't be
    // created until initialization is complete
    // the compiler recognizes "lazy" as a valid type of initialization
    lazy var animator: UIDynamicAnimator = { [unowned self] in
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
        }()
    
    let behaviors = Behaviors()
    var settingsVC: SettingsVC?
    var ball: UIView?
    var bricks: [Brick] = []
    
    var showGameTime = Constant.DefaultShowTime
    var brickSize: CGSize = Constant.DefaultBrickSize   // may be changed by setBrickSize(index)
    var brickRows = Constant.DefaultBrickRows
    var ballPushStrength = Constant.DefaultPushStrength
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resetGame()
    }
    
    func resetGame() {
        println("resetGame")
        
        let tabBarViewControllers = tabBarController!.viewControllers as! [UIViewController]
        settingsVC = tabBarViewControllers[1] as? SettingsVC
        println("settingsVC: \(settingsVC)")
        if settingsVC?.settingsTabSelected == true && settingsVC?.settingsChanged == false {
            settingsVC?.settingsTabSelected = false
            return
        }
        settingsVC?.settingsTabSelected = false
        behaviors.bricksVC = self
        
        // if userDefaults exists read it and set parameters to its values
        // if not the parameters stay at their default values set above
        let defaults = NSUserDefaults.standardUserDefaults()
        let width = defaults.floatForKey("brickWidth")
        // in the first run userDefaults doesn't exist and width will be set to zero
        // so the parameters need to stay at their default values
        if width != 0 {
            let height = defaults.floatForKey("brickHeight")
            brickSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            showGameTime = defaults.boolForKey("showTime")
            ballPushStrength = CGFloat(defaults.floatForKey("pushStrength"))
            brickRows = Int(defaults.integerForKey("rows"))
        }
        
        gameTimeLabel.text = "hello" 
        
        while !bricks.isEmpty {
            let brick = bricks.removeLast()
            behaviors.detachBrick(brick)
            behaviors.deanimateBrick(brick)
            brick.removeFromSuperview()
        }

        if ball != nil {
            behaviors.deanimateBall(ball!)
            ball!.removeFromSuperview()
        }
        
        animator.removeAllBehaviors()
        if settingsVC?.settingsChanged == true {
            copySettingsParameters(self.settingsVC!)
            persistParameters()
        }
        behaviors.addBottomRegion(gameView) // after copy... because bottomRegionY depends on brick size
        animator.addBehavior(behaviors)
        // following stmt must be before installBricks so ball pre-exists bricks
        installSquareBall(Constant.BallSize, center: Constant.InitialBallPosition)
        installBricks()
    }
    
    // this is called only if settingsVC != nil
    func copySettingsParameters(settingsVC: SettingsVC) {
        brickSize = settingsVC.brickSize
        ballPushStrength = settingsVC.ballPushStrength
        showGameTime = settingsVC.showGameTime
        brickRows = settingsVC.brickRows
    }
    
    func persistParameters() {
        let brickWidthFloat = Float(brickSize.width)
        let brickHeightFloat = Float(brickSize.height)
        let ballPushStrengthFloat = Float(ballPushStrength)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(brickWidthFloat, forKey: "brickWidth")
        defaults.setFloat(brickHeightFloat, forKey: "brickHeight")
        defaults.setFloat(ballPushStrengthFloat, forKey: "pushStrength")
        defaults.setBool(showGameTime, forKey: "showTime")
        defaults.setInteger(brickRows, forKey: "rows")
    }
    
    func installBricks () {
        // array of anchor points, one for each starting brick position
        let anchors: [CGPoint] = setAnchors()
        
        // put a brick on every anchor
        for anchor in anchors {
            let origin = CGPoint(x: anchor.x - brickSize.width / 2, y: anchor.y - brickSize.height / 2)
            let frame = CGRect(origin: origin, size: brickSize)
            var brick = Brick(frame: frame)
            brick.backgroundColor = UIColor.redColor()
            gameView.addSubview(brick)      // before animateBrick so brick is part of reference view
            behaviors.animateBrick(brick, ball: ball!)
            behaviors.attachBrick(brick, anchor: anchor)
            bricks.append(brick)
        }
    }
    
    func setAnchors() -> [CGPoint] {
        let sideSpace = Constant.BricksSideSpace
        let gameViewWidth = gameView.bounds.size.width
        let brickWidth = brickSize.width
        let brickHeight = brickSize.height
        let bricksPerRow = Int( (gameViewWidth - 2 * sideSpace) / brickWidth ) - 1
        let brickSeparation = (gameViewWidth - 2 * sideSpace - CGFloat(bricksPerRow) * brickWidth) / CGFloat( (bricksPerRow - 1) )
        
        var anchors: [CGPoint] = []
        for row in 0..<brickRows {
            for col in 0..<bricksPerRow {
                let point = CGPoint(x:sideSpace + CGFloat(col) * (brickWidth + brickSeparation) + brickWidth / 2,
                    y:Constant.BricksTopSpace + brickHeight / 2 + CGFloat(row) * (Constant.BrickRowSpacing + brickHeight) )
                anchors.append(point)
            }
        }
        return anchors
    }
    
    // not tested or debugged
//    func installOvalBall (size: CGSize, center: CGPoint) {
//        let path = UIBezierPath()
//        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(0), endAngle:CGFloat(M_PI), clockwise: true)
//        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(M_PI), endAngle:CGFloat(0), clockwise:true)
//        path.closePath()
//        path.lineWidth = 15
//        gameView.setPath(path, named: "BallPath")
//        behaviors.addBarrier(path, named: "Ball")
//    }
    
    func installSquareBall (ballSize: CGSize, center: CGPoint) {
        let frame = CGRect(origin: Constant.InitialBallPosition, size: ballSize)
        ball = UIView(frame: frame)
        ball!.backgroundColor = UIColor.greenColor()
        gameView.addSubview(ball!)
        behaviors.animateBall(ball!)
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let tapLocation = sender.locationInView(gameView)
            let ballLocation = ball!.center
            if gameView.pointInside(ballLocation, withEvent: nil) {
                let angle = angleToward(ballLocation, from:tapLocation)
                behaviors.pushBall(angle, strength: ballPushStrength)
            } else {
                ball!.center = tapLocation   // bring ball back if it goes outide of gameView
                behaviors.deanimateBall(ball!)
                behaviors.animateBall(ball!)
                animator.updateItemUsingCurrentState(ball!)
            }
        }
    }
    
    // Caution! Don't change this function unless you're sure something is wrong with it. 
    // It was had and tedious to get it right (assuming it's right)
    // returns the angle in radians of a vector pointing from a "from" point
    // to a "target" point
    func angleToward(target: CGPoint, from: CGPoint) -> CGFloat {
        
        if from.y == target.y && from.x > target.x { return CGFloat(M_PI) }
        if from.y == target.y && from.x < target.x { return CGFloat(0) }
        if from.x == target.x && from.y > target.y { return CGFloat(M_PI_2) }
        if from.x == target.x && from.y < target.y { return -CGFloat(M_PI_2) }
        
        if (from.y > target.y) && (from.x > target.x) {
            return  atan( (target.y - from.y) / (target.x - from.x) ) - CGFloat(M_PI)
            
        } else if from.y < target.y && from.x > target.x {
            return atan( (target.y - from.y) / (target.x - from.x) ) + CGFloat(M_PI)
            
        } else if from.x < target.x {
            return atan( (target.y - from.y) / (target.x - from.x) )
            
        } else { println("should never get here"); return 0 }
    }
    
    func gameOver() {
        let alertView = UIAlertView.init(title: "Game Over", message: "Tap Reset to play again", delegate: self, cancelButtonTitle: "Exit")
        let resetIndex = alertView.addButtonWithTitle("Reset")
        alertView.delegate = self
        alertView.show()
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            exit(0)
        case 1:
            resetGame()
        default:
            break
        }
    }
    

}
