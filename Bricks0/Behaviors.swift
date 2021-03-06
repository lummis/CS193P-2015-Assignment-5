//
//  Behaviors.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/7/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class Behaviors: UIDynamicBehavior, UICollisionBehaviorDelegate {

    var bricksVC: BricksVC?
    
    // if the ball hits a brick after the brick has entered the bottom region and changed color
    // the brick is removed and disappears
    // bottomRegionY is y at the top of the bottom region
    var bottomRegionY: CGFloat?
    var bottomRegion: UIView?
    
    let gravity = UIGravityBehavior()
    
    lazy var ballItemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.8
        return behavior
        }()
    
    lazy var brickItemBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBrickItemBehavior = UIDynamicItemBehavior()
        lazilyCreatedBrickItemBehavior.allowsRotation = true
        lazilyCreatedBrickItemBehavior.elasticity = 0.5
        return lazilyCreatedBrickItemBehavior
        }()
    
    lazy var boundaryCollisionBehavior: UICollisionBehavior = {
        let boundaryCollisionBehavior = UICollisionBehavior()
        boundaryCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        boundaryCollisionBehavior.collisionDelegate = self
        return boundaryCollisionBehavior
        }()
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        var brickItem: Brick?
        if let brickItem = item1 as? Brick {
            brickCollisionAction(brickItem, otherItem: item2)
            
        } else if let brickItem = item2 as? Brick {
            brickCollisionAction(brickItem, otherItem: item1)
            
        } else { println("no brick") }
    }
    
    var pushBehavior = UIPushBehavior(items: [], mode: UIPushBehaviorMode.Instantaneous)

    func addBottomRegion(gameView: UIView) {
        bottomRegion?.removeFromSuperview()
        let bottomRegionHeight = 0.55 * bricksVC!.brickSize.width   // width is the larger dimension
        bottomRegionY = gameView.frame.size.height - bottomRegionHeight
        bottomRegion = UIView(frame: CGRectMake(0, bottomRegionY!,
            gameView.frame.size.width, bottomRegionHeight))
        bottomRegion!.backgroundColor = UIColor.lightGrayColor()
        bottomRegion!.alpha = 0.1
        gameView.addSubview(bottomRegion!)
    }
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(brickItemBehavior)
        addChildBehavior(ballItemBehavior)
        addChildBehavior(boundaryCollisionBehavior)
        addChildBehavior(pushBehavior)
    }
    
    func pushBall(radians: CGFloat, strength: CGFloat) {
        pushBehavior.angle = radians
        pushBehavior.magnitude = strength
        pushBehavior.active = true
    }
    
//    func addBarrier(path: UIBezierPath, named name: String) {
//        boundaryCollisionBehavior.removeBoundaryWithIdentifier(name)
//        boundaryCollisionBehavior.addBoundaryWithIdentifier(name, forPath: path)
//    }
    
    func animateBrick(brick: Brick, ball: UIView) {
        gravity.addItem(brick)
        brickItemBehavior.addItem(brick)
        boundaryCollisionBehavior.addItem(brick)
        
        var items: [AnyObject] = [ball, brick]
        let ballBrickCollisionBehavior = UICollisionBehavior(items:items)
        self.addChildBehavior(ballBrickCollisionBehavior)
        brick.collisionBehavior = ballBrickCollisionBehavior
    }
    
    func attachBrick(brick: Brick, anchor: CGPoint) {
        let attachmentBehavior = UIAttachmentBehavior(item: brick, attachedToAnchor: anchor)
        brick.attachmentBehavior = attachmentBehavior
        self.addChildBehavior(attachmentBehavior)
        brick.anchor = anchor
    }
    
    func detachBrick(brick: Brick) {
        if let attachmentBehavior = brick.attachmentBehavior {
            self.removeChildBehavior(attachmentBehavior)
            brick.attachmentBehavior = nil
        }
    }

    func deanimateBrick(brick: Brick) {
        gravity.removeItem(brick)
        brickItemBehavior.removeItem(brick)
        boundaryCollisionBehavior.removeItem(brick)
        if brick.collisionBehavior != nil {
            self.removeChildBehavior(brick.collisionBehavior!)
        }
        brick.collisionBehavior = nil
    }
    
    func animateBall(ball: UIView) {
        ballItemBehavior.addItem(ball)
        boundaryCollisionBehavior.addItem(ball)
        pushBehavior.addItem(ball)
    }
    
    func deanimateBall(ball: UIView) {
        ballItemBehavior.removeItem(ball)
        boundaryCollisionBehavior.removeItem(ball)
        pushBehavior.removeItem(ball)
    }
    
    func brickCollisionAction(brick: Brick?, otherItem: UIDynamicItem) {
        if let brickItem = otherItem as? Brick {
            return      // no action when 2 bricks collide
        }
        
        let theBrick = brick!
        if theBrick.backgroundColor == UIColor.redColor() {
            theBrick.backgroundColor = UIColor.brownColor()
        } else {
            detachBrick(theBrick)
        }
        
        // remove brick if it's in the bottom region
        if theBrick.backgroundColor == Constant.BottomRegionBrickColor {
            deanimateBrick(theBrick)
            theBrick.removeFromSuperview()
            bricksVC!.bricks = bricksVC!.bricks.filter() {$0 != theBrick}
            if bricksVC!.bricks.isEmpty { bricksVC?.gameOver() }
        }
    }
    
}
