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
    
    let bricksBehavior = BricksBehavior()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animator.addBehavior(bricksBehavior)
        installBricks(rows: 1, brickSize: CGSizeMake(35, 15))
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
                var brick = UIView(frame: frame)
                brick.backgroundColor = UIColor.redColor()
                bricksBehavior.addBrick(brick)
            }
            
        }
        
        
    }
}
