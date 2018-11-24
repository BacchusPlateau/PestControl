//
//  Player.swift
//  PestControl
//
//  Created by Bret Williams on 11/23/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum PlayerSettings {
  static let playerSpeed: CGFloat = 280.0
}

class Player : SKSpriteNode {
  
  var animations: [SKAction] = []
  
  func checkDirection() {
    
    guard let physicsBody = physicsBody else {return}
    
    let direction = animationDirection(for: physicsBody.velocity)
    
    if direction == .left {
      xScale = abs(xScale)
    }
    
    if direction == .right {
      xScale = -abs(xScale)
    }
    
    run(animations[direction.rawValue], withKey: "animation")
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Use init()")
  }
  
  init() {
    
    let texture = SKTexture(pixelImageNamed: "player_ft1")
    
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Player"
    zPosition = 50
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.restitution = 1.0
    physicsBody?.linearDamping = 0.5
    physicsBody?.friction = 0
    physicsBody?.allowsRotation = false
    
    createAnimations(character: "player")
    
  }
  
  func move(target: CGPoint) {
    
    guard let physicsBody = physicsBody else { return }
    
    let newVelocity = (target - position).normalized() * PlayerSettings.playerSpeed
    physicsBody.velocity = CGVector(point: newVelocity)
    
    checkDirection()
    
  }
  
}

extension Player : Animatable {}