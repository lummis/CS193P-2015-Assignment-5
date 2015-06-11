//
//  Brick.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/11/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class Brick: UIView {
    var attachmentBehavior: UIAttachmentBehavior?
    var collisionBehavior: UICollisionBehavior?
    var anchor: CGPoint = CGPointZero
}
