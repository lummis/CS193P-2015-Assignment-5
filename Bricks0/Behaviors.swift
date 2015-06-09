//
//  Behaviors.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/7/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class Behaviors: UIDynamicBehavior, UICollisionBehaviorDelegate {

    let gravity = UIGravityBehavior()
    
    lazy var ballItemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.9
        return behavior
        }()
    
    lazy var brickItemBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBrickItemBehavior = UIDynamicItemBehavior()
        lazilyCreatedBrickItemBehavior.allowsRotation = true
        lazilyCreatedBrickItemBehavior.elasticity = 0.5
        return lazilyCreatedBrickItemBehavior
        }()
    
    lazy var boundaryCollisionBehavior: UICollisionBehavior = {
        let boundary = UICollisionBehavior()
        boundary.translatesReferenceBoundsIntoBoundary = true
        boundary.collisionDelegate = self
        return boundary
        }()
    
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(brickItemBehavior)
        addChildBehavior(ballItemBehavior)
        addChildBehavior(boundaryCollisionBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        boundaryCollisionBehavior.removeBoundaryWithIdentifier(name)
        boundaryCollisionBehavior.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func animateBrick(brick: UIView) {
        gravity.addItem(brick)
        brickItemBehavior.addItem(brick)
        boundaryCollisionBehavior.addItem(brick)
    }

    func deanimateBrick(brick: UIView) {
        gravity.removeItem(brick)
        brickItemBehavior.removeItem(brick)
        boundaryCollisionBehavior.removeItem(brick)
    }
    
    func animateBall(ball: UIView) {
        ballItemBehavior.addItem(ball)
        boundaryCollisionBehavior.addItem(ball)
    }
    
}
