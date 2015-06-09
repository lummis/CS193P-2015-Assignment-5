//
//  BallBehavior.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/7/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class BallBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {

//    lazy var ballItemBehavior: UIDynamicItemBehavior = {
//        let behavior = UIDynamicItemBehavior()
//        behavior.allowsRotation = true
//        behavior.elasticity = 0.9
//        return behavior
//    }()
//    
//    lazy var boundaryCollisionBehavior: UICollisionBehavior = {
//        let lazilyCreatedBoundary = UICollisionBehavior()
//        lazilyCreatedBoundary.translatesReferenceBoundsIntoBoundary = true
//        lazilyCreatedBoundary.collisionDelegate = self
//        return lazilyCreatedBoundary
//        }()
//    
//    override init() {
//        super.init()
//        
//        addChildBehavior(ballItemBehavior)
//        addChildBehavior(boundaryCollisionBehavior)
//    }
//    
//    func addBall(ball: UIBezierPath, named name: String) {
//        boundaryCollisionBehavior.removeBoundaryWithIdentifier(name)
//        boundaryCollisionBehavior.addBoundaryWithIdentifier(name, forPath: ball)
//        ballItemBehavior.addItem(ball)
//        dynamicAnimator?.referenceView?.addSubview(ball)
////        ballBehavior.addItem(ball)
//    }

    // MARK:- CollisionBehaviorDelegate

//    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
//        <#code#>
//    }
}
