//
//  BricksVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

 struct Constant {
    
    static let PaddleWidth = CGFloat(20)
    static let PushStrength = CGFloat(0.1)
    static let BrickSize = CGSize(width:35, height:10)
    static let BallSize = CGSize(width:25, height:25)
    static let SideSpace = CGFloat(20)
    static let NBrickRows = 5
    static let BrickRowSpacing = CGFloat(10)
    
}

class BricksVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate
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
    var ball: UIView = UIView(frame: CGRectZero)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animator.addBehavior(behaviors)
        var anchors: [CGPoint] = setAnchors()
        installBricks(rows: Constant.NBrickRows, brickSize:Constant.BrickSize)
        installSquareBall(Constant.BallSize, center:CGPoint(x:gameView.bounds.size.width / 2, y:gameView.bounds.size.height / 2))
    }
    
    func setAnchors() -> [CGPoint] {
        let sideSpace = Constant.SideSpace
        let viewWidth = view.bounds.size.width
        let gameViewWidth = gameView.bounds.size.width
        let brickWidth = Constant.BrickSize.width
        let bricksPerRowFloat = (gameViewWidth - 2 * sideSpace) / brickWidth
        let bricksPerRowInt = Int(bricksPerRowFloat) - 1
        let brickSeparation = (gameViewWidth - 2 * sideSpace - CGFloat(bricksPerRowInt) * brickWidth) / CGFloat( (bricksPerRowInt - 1) )
        
        var points: [CGPoint] = []
        for row in 0..<Constant.NBrickRows {
            for col in 0..<bricksPerRowInt {
                let point = CGPointMake(CGFloat(sideSpace + CGFloat(col) * (brickWidth + brickSeparation)),
                                Constant.BrickRowSpacing + (Constant.BrickRowSpacing + Constant.BrickSize.height) * CGFloat(row))
                points.append(point)
            }
        }
        return points
    }
    
    func installBricks (#rows: Int, brickSize: CGSize) {
        if brickSize.width > gameView.bounds.size.width / 8 || brickSize.height >= brickSize.width {
            println("bad brickSize")
            return
        }
        
        let sideSpace = Constant.SideSpace
        let viewWidth = view.bounds.size.width
        let gameViewWidth = gameView.bounds.size.width
        let brickWidth = brickSize.width
        let bricksPerRowFloat = (gameViewWidth - 2 * sideSpace) / brickWidth
        let bricksPerRowInt = Int(bricksPerRowFloat) - 1
        let brickSeparation = (gameViewWidth - 2 * sideSpace - CGFloat(bricksPerRowInt) * brickWidth) / CGFloat( (bricksPerRowInt - 1) )
        
        for row in 0..<rows {
            for col in 0..<bricksPerRowInt {
                let frame = CGRectMake(CGFloat(sideSpace + CGFloat(col) * (brickWidth + brickSeparation)), Constant.BrickRowSpacing + (Constant.BrickRowSpacing + brickSize.height) * CGFloat(row),
                    brickWidth, brickSize.height)
                var brick = UIView(frame: frame)
                brick.backgroundColor = UIColor.redColor()
                gameView.addSubview(brick)      // before animateBrick so brick is part of reference view
                behaviors.animateBrick(brick)
            }
        }
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
        let frame = CGRect(origin: CGPoint(x:center.x - size.width / 2, y: center.y - size.height / 2), size: size)
        ball.frame = frame
        ball.backgroundColor = UIColor.greenColor()
        gameView.addSubview(ball)
        behaviors.animateBall(ball)
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let tapLocation = sender.locationInView(gameView)
            let ballLocation = ball.center
            let angle = angleToward(ballLocation, from:tapLocation)
            behaviors.pushBall(angle, strength: Constant.PushStrength)
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
}
