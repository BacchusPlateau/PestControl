//
//  Bug.swift
//  PestControl
//
//  Created by Bret Williams on 11/23/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import SpriteKit

class Bug : SKSpriteNode {
  
  var animations: [SKAction] = []
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Use init()")
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
    
  //  createAnimations(character: "bug")
    
  }
  
  
}


extension Bug : Animatable {}
