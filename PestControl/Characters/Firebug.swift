//
//  Firebug.swift
//  PestControl
//
//  Created by Bret Williams on 11/25/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

class Firebug : Bug {
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Use init()")
  }
  
  override init() {
    super.init()
    
    name = "Firebug"
    color = .red
    colorBlendFactor = 0.8
    physicsBody?.categoryBitMask = PhysicsCategory.Firebug
    
  }
  
}
