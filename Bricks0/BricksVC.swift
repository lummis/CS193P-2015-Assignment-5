//
//  BricksVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

 struct Constant {
    
    static let BrickSize0 = CGSize(width: 30, height: 20)
    static let BrickSize1 = CGSize(width: 50, height: 25)
    static let BrickSize2 = CGSize(width: 75, height: 50)
    static let BrickSize3 = CGSize(width: 150, height: 100)
    
    static let DefaultPushStrength = CGFloat(0.15)
    static let DefaultBrickSize = BrickSize1
    static let DefaultBrickRows = 2
    static let DefaultShowTime = false
    static let DefaultBallSize = CGSize(width:25, height:15)
    static let BricksSideSpace = CGFloat(15)    // hor. distance from side bricks to gameView
    static let BricksTopSpace = CGFloat(10)     // vert. distance from top bricks to gameView
    static let BrickRowSpacing = CGFloat(12)    // vert. distance between brick rows
    static let InitialBallPosition = CGPoint(x: 150, y: 300)
}

class BricksVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, UIAlertViewDelegate
{

    @IBOutlet weak var gameView: UIView!
 
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
    
    var showGameTime = Constant.DefaultShowTime
    var ball: UIView = UIView(frame: CGRectZero)
    var bricks: [Brick] = [] {
        willSet {
            if newValue.count == 0 { gameOver() }
        }
        didSet {
            // I suspect a brick can go out of gameView so when no more are on screen the alertView doesn't pop up
            // this will let me confirm that there are still one or more bricks left in that situation
            println("nBricks: \(bricks.count)")
        }
    }
    var brickSize: CGSize = Constant.DefaultBrickSize   // may be changed by setBrickSize(index)
    var brickRows = Constant.DefaultBrickRows
    var ballPushStrength = Constant.DefaultPushStrength
    var nBricks = 0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // this stmt shows that each time the view appears it is the same view controller instance
        println("BricksVC/viewDidAppear; \(self)")
        resetGame()
    }
    
    func resetGame() {
        println("resetGame")
        let tabBarViewControllers = tabBarController!.viewControllers as! [UIViewController]
        settingsVC = tabBarViewControllers[1] as? SettingsVC
        
        if settingsVC == nil {
            println("settingsVC is nil")
        }
        
        animator.addBehavior(behaviors)
        behaviors.setBottomBoundary(gameView)
        behaviors.vc = self
        while !bricks.isEmpty {
            let brick = bricks.removeLast()
            behaviors.detachBrick(brick)
            behaviors.deanimateBrick(brick)
        }
        copySettingsParameters(settingsVC!)
        behaviors.deanimateBall(ball)
        ball.removeFromSuperview()
        // following stmt must be before installBricks so ball pre-exists bricks
        installSquareBall(Constant.DefaultBallSize, center: Constant.InitialBallPosition)
        installBricks()
    }
    
    func copySettingsParameters(settingsVC: SettingsVC) {
        if settingsVC.settingsChanged {
            brickSize = settingsVC.brickSize
            ballPushStrength = settingsVC.ballPushStrength
            showGameTime = settingsVC.showGameTime
            brickRows = settingsVC.brickRows
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
            behaviors.animateBrick(brick, ball: ball)
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
    
//    func installOvalBall (size: CGSize, center: CGPoint) {
//        let path = UIBezierPath()
//        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(0), endAngle:CGFloat(M_PI), clockwise: true)
//        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(M_PI), endAngle:CGFloat(0), clockwise:true)
//        path.closePath()
//        path.lineWidth = 15
//        gameView.setPath(path, named: "BallPath")
//        behaviors.addBarrier(path, named: "Ball")
//    }
    
    func installSquareBall (size: CGSize, center: CGPoint) {
        let frame = CGRect(origin: Constant.InitialBallPosition, size: size)
        ball.frame = frame
        ball.backgroundColor = UIColor.greenColor()
        gameView.addSubview(ball)
        behaviors.animateBall(ball)
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let tapLocation = sender.locationInView(gameView)
            let ballLocation = ball.center
            if gameView.pointInside(ballLocation, withEvent: nil) {
                let angle = angleToward(ballLocation, from:tapLocation)
                behaviors.pushBall(angle, strength: ballPushStrength)
            } else {
                ball.center = tapLocation   // bring ball back if it goes outide of gameView
                behaviors.deanimateBall(ball)
                behaviors.animateBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
    }
    
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
            
        } else { println("should never get here"); return 12345 }
    }
    
    func gameOver() {
        println("gameOver")
        
        let alertView = UIAlertView.init(title: "Game Over", message: "Tap Reset to play again", delegate: self, cancelButtonTitle: "Exit")
        let resetIndex = alertView.addButtonWithTitle("Reset")
        alertView.delegate = self
        alertView.show()
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("buttonIndex: \(buttonIndex)")
        
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
