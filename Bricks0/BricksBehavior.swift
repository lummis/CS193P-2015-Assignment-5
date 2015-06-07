//
//  BricksBehavior.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/4/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class BricksBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    let gravity = UIGravityBehavior()
    
    lazy var brickBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBrickBehavior = UIDynamicItemBehavior()
        lazilyCreatedBrickBehavior.allowsRotation = false
        lazilyCreatedBrickBehavior.elasticity = 0.5
        return lazilyCreatedBrickBehavior
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.allowsRotation = true
        lazilyCreatedBallBehavior.elasticity = 0.6
        return lazilyCreatedBallBehavior
        }()
    
    lazy var boundaryCollisionBehavior: UICollisionBehavior = {
        let lazilyCreatedBoundary = UICollisionBehavior()
        lazilyCreatedBoundary.translatesReferenceBoundsIntoBoundary = true
        lazilyCreatedBoundary.collisionDelegate = self
        return lazilyCreatedBoundary
    }()
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(brickBehavior)
        addChildBehavior(ballBehavior)
        addChildBehavior(boundaryCollisionBehavior)
    }
    
    func addBrick(brick: UIView) {
        dynamicAnimator?.referenceView?.addSubview(brick)
        gravity.addItem(brick)
        brickBehavior.addItem(brick)
        boundaryCollisionBehavior.addItem(brick)
    }
    
//    func addBall(ball: UIView) {
//        dynamicAnimator?.referenceView?.addSubview(ball)
//        boundary.addItem(ball)
//    }
    
    // MARK:- CollisionBehaviorDelegate
    
//    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
//        <#code#>
//    }

}
