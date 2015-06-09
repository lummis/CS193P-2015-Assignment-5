//
//  BricksVC.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

struct Constant {
    
    static let PaddleWidth = 20

}

class BricksVC: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate
{

    @IBOutlet weak var gameView: BezierPathsView!
 
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
    let bez = BezierPathsView()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animator.addBehavior(behaviors)
        installBricks(rows: 1, brickSize: CGSizeMake(35, 15))
        installBall( CGSize(width: 50.0, height: 25.0), center: CGPoint(x: 0.5 * gameView.bounds.size.width, y: 0.5 * gameView.bounds.size.height) )
    }
    
    func installBricks (#rows: Int, brickSize: CGSize) {
        if brickSize.width > gameView.bounds.size.width / 8 || brickSize.height >= brickSize.width {
            println("bad brickSize")
            return
        }
        
        if rows > 5 {
            println("specified too many rows")
            return
        }
        
        let sideSpace = CGFloat(20)
        let viewWidth = view.bounds.size.width
        let gameViewWidth = gameView.bounds.size.width
        let brickWidth = brickSize.width
        let bricksPerRowFloat = (gameViewWidth - 2 * sideSpace) / brickWidth
        let bricksPerRowInt = Int(bricksPerRowFloat) - 1
        let brickSeparation = (gameViewWidth - 2 * sideSpace - CGFloat(bricksPerRowInt) * brickWidth) / CGFloat( (bricksPerRowInt - 1) )
        
        for row in 0..<rows {
            for col in 0..<bricksPerRowInt {
                let frame = CGRectMake(CGFloat( sideSpace + CGFloat(col) *  (brickWidth  + brickSeparation) ), 20, brickWidth, brickSize.height)
//                var brick = BezierPathsView(frame: frame)
                var brick = UIView(frame: frame)
                brick.backgroundColor = UIColor.redColor()
                gameView.addSubview(brick)      // must come before animateBrick so brick is part of reference view
                behaviors.animateBrick(brick)
                
            }
        }
    }
    
    func installBall (size: CGSize, center: CGPoint) {
        
        let path = UIBezierPath()
        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(0), endAngle:CGFloat(M_PI), clockwise: true)
        path.addArcWithCenter(center, radius:size.width / 2, startAngle:CGFloat(M_PI), endAngle:CGFloat(0), clockwise:true)
        path.closePath()
        path.lineWidth = 15
        gameView.setPath(path, named: "BallPath")
        
        behaviors.addBarrier(path, named: "Ball")
    }
    
    func installSquareBall (size: CGSize) {
        let frame = CGRectMake(100, 350, size.width, size.height)
        var ball = UIView(frame: frame)
        ball.backgroundColor = UIColor.greenColor()
        gameView.addSubview(ball)
        behaviors.animateBall(ball)
    }
}
