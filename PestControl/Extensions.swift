//
//  Extensions.swift
//  PestControl
//
//  Created by Bret Williams on 11/23/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import SpriteKit

extension SKTexture {
  convenience init(pixelImageNamed: String) {
    self.init(imageNamed: pixelImageNamed)
    self.filteringMode = .nearest
  }
}
