//
//  Bug.swift
//  PestControl
//
//  Created by Bret Williams on 11/23/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import SpriteKit

enum BugSettings {
  static let bugDistance: CGFloat = 16
}

class Bug : SKSpriteNode {
  
  var animations: [SKAction] = []
  
  func die() {
    
    removeAllActions()
    texture = SKTexture(pixelImageNamed: "bug_lt1")
    yScale = -1
    
    physicsBody = nil
    run(SKAction.sequence([SKAction.fadeOut(withDuration: 3),
                           SKAction.removeFromParent()]))
    
  }
  
  override func encode(with aCoder: NSCoder) {
    
    aCoder.encode(animations, forKey: "Bug.animations")
    
    super.encode(with: aCoder)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animations = aDecoder.decodeObject(forKey: "Bug.animations") as! [SKAction]
  }
  
  init() {
    
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Bug"
    zPosition = 1
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.restitution = 0.5
    physicsBody?.linearDamping = 0.5
    physicsBody?.friction = 0
    physicsBody?.allowsRotation = false
    physicsBody?.categoryBitMask = PhysicsCategory.Bug
    
    createAnimations(character: "bug")
    
  }
  
  @objc func moveBug() {
    
    let randomX = CGFloat(Int.random(min: -1, max: 1))
    let randomY = CGFloat(Int.random(min: -1, max: 1))
    
    let vector = CGVector(dx: randomX * BugSettings.bugDistance,
                          dy: randomY * BugSettings.bugDistance)
    let moveBy = SKAction.move(by: vector, duration: 1)
    let moveAgain = SKAction.perform(#selector(moveBug), onTarget: self)
    
    let direction = animationDirection(for: vector)
    if direction == .left {
      xScale = abs(xScale)
    } else if direction == .right {
      xScale = -abs(xScale)
    }
    
    run(animations[direction.rawValue], withKey: "animation")
    run(SKAction.sequence([moveBy, moveAgain]))
    
  }
  
  
}


extension Bug : Animatable {}
















