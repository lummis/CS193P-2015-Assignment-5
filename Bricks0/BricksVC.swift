//
//  BricksVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

 struct Constant {
    static let BallSize = CGSize(width:25, height:25)
    static let BricksSideSpace = CGFloat(15)    // hor. distance from side bricks to gameView
    static let BricksTopSpace = CGFloat(40)     // vert. distance from top bricks to gameView
    static let BrickRowSpacing = CGFloat(12)    // vert. distance between brick rows
    static let InitialBallPosition = CGPoint(x: 150, y: 300)
    static let BottomRegionBrickColor = UIColor.orangeColor()
}

class BricksVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, UIAlertViewDelegate, RCLElapsedTimerDelegate
{

    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameTimeLabel: UILabel!
 
    // the animator will be created the first time it is referenced
    // the animator can't be created until initialization is complete
    // but the compiler recognizes "lazy" as a valid type of initialization
    // so this satisfies the rule that every property has to be initialized
    lazy var animator: UIDynamicAnimator = { [unowned self] in
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
        }()
    
    let behaviors = Behaviors()
    var settingsVC: SettingsVC? // initialized by storyboard; set below in viewWillAppear
    var ball: UIView?
    var bricks: [Brick] = []
    
    // 4 adjustable parameters
    // they are initialized here to dummy values; they will be set to valid values in viewWillAppear
    var showGameTime: Bool = false {
        didSet {
            gameTimeLabel.hidden = !showGameTime
        }
    }
    var brickSize: CGSize = CGSizeZero
    var brickRows = 0
    var ballPushStrength = CGFloat(0)
    
    // MARK: - RCLElapsedTimerDelegate property
    var sessionTime: Float = 0 {
        didSet {
            updateGameTimeLabel(sessionTime)
            removeLostBricks()
            updateBricksInBottomRegion()
        }
    }
    
    
    // MARK: - Life Cycle Methods
    override func viewWillAppear(animated: Bool) {
        println("BricksVC / viewWillAppear")
        super.viewWillAppear(animated)
        
        behaviors.bricksVC = self
        // these 4 properties are settable in the Settings tab and
        // are persisted in NSUserDefaults
        settingsVC = (tabBarController!.viewControllers as! [UIViewController])[1] as? SettingsVC
        (brickSize, ballPushStrength, showGameTime, brickRows) = settingsVC!.getParameters()
    }
    
    override func viewDidAppear(animated: Bool) {
        println("BricksVC / viewDidAppear")
        
        super.viewDidAppear(animated)
        resetGame()
    }
    
    func resetGame() {
        
        // ********** DEBUG
        println("settingsVC: \(settingsVC)")
        println("sum: \(settingsVC!.doSum(a:0, b:3))")
        if let xxx = settingsVC?.brickRows {
            println("settingsVC/brickRows: \(settingsVC!.brickRows)")
        } else {
            println("settingsVC.brickRows is nil")
        }
        println("sum: \(settingsVC!.doSum(a:1, b:3))")
        // ********** TEST END ***
        
        if settingsVC?.userChangedSettings == false {
            // we might have gotten here because user looked at the Settings tab then returned here
            // but if the user didn't change any parameter just carry on
            return
        }
        
        // stop sessionTime update. Start it again on the first tapAction
        let timer = RCLElapsedTimer.sharedTimer
        timer.delegate = self
        timer.stop()
        sessionTime = 0
    
        gameTimeLabel.hidden = !showGameTime

        updateGameTimeLabel(sessionTime)
        
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
        behaviors.addBottomRegion(gameView) // must be after brickSize is set
        animator.addBehavior(behaviors)
        // following stmt must be before installBricks so ball pre-exists bricks
        installSquareBall(Constant.BallSize, center: Constant.InitialBallPosition)
        installBricks()
    }

    func updateGameTimeLabel(sessionTime: Float) {
        gameTimeLabel.text = String(format: "Play Time: %4.0f", sessionTime)
    }
    
    func removeLostBricks() {
        for brick in bricks {
            if !gameView.pointInside(brick.center, withEvent: nil) {
                behaviors.detachBrick(brick)
                behaviors.deanimateBrick(brick)
                brick.removeFromSuperview()
                println("A lost brick was removed. Number of remaining bricks: \(bricks.count).")
                bricks = bricks.filter( {$0 != brick} )
                if bricks.isEmpty { gameOver() }
            }
        }
    }
    
    func updateBricksInBottomRegion() {
        for brick in bricks {
            if brick.center.y > behaviors.bottomRegionY {
                brick.backgroundColor = Constant.BottomRegionBrickColor
            }
        }
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
            if gameView.pointInside(ballLocation, withEvent: nil) {  // test for ball out of bounds
                let angle = angleToward(ballLocation, from:tapLocation)
                behaviors.pushBall(angle, strength: ballPushStrength)
            } else {
                // I can't figure out how to bring the existing ball back with zero velocity
                // so I'm removing it and creating a new ball at the topLocation
                println("Ball seems to be lost. ballLocation: \(ballLocation)")
                behaviors.deanimateBall(ball!)
                ball!.removeFromSuperview()
                installSquareBall(Constant.BallSize, center: tapLocation)
                animator.updateItemUsingCurrentState(ball!)
            }
            
            let timer = RCLElapsedTimer.sharedTimer
            timer.delegate = self
            timer.start()
        }
    }
    
    // Caution! Don't change this function unless you're sure something is wrong with it
    // It was hard and tedious to get it working
    // returns angle in radians of a vector from "from" point to "target" point
    // zero angle points toward right. positive angle is clockwise from zero
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
