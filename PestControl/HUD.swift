//
//  HUD.swift
//  PestControl
//
//  Created by Bret Williams on 12/2/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum HUDSettings {
  static let font = "Noteworthy-Bold"
  static let fontSize: CGFloat = 50
}

enum HUDMessage {
  static let tapToStart = "Tap to Start"
  static let win = "You Win!"
  static let lose = "Out of Time!"
  static let nextLevel = "Tap for Next Level"
  static let playAgain = "Tap to Play Again"
  static let reload = "Continue Previous Game?"
  static let yes = "Yes"
  static let no = "No"
}

class HUD : SKNode {
  
  var timerLabel: SKLabelNode?
  
  func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
    
    let label : SKLabelNode
    label = SKLabelNode(fontNamed: HUDSettings.font)
    label.text = message
    label.name = message
    label.zPosition = 100
    addChild(label)
    label.fontSize = fontSize
    label.position = position
    
  }
  
  func addTimer(time: Int) {
    
    guard let scene = scene else { return }
    
    let position = CGPoint(x: 0,
                           y: scene.frame.height / 2 - 10)
    add(message: "Timer", position: position, fontSize: 24)
    timerLabel = childNode(withName: "Timer") as? SKLabelNode
    timerLabel?.verticalAlignmentMode = .top
    timerLabel?.fontName = "Menlo"
    updateTimer(time: time)
    
  }
  
  private func clearUI(gameState: GameState) {
    
    switch gameState {
    case .win:
      remove(message: HUDMessage.win)
      remove(message: HUDMessage.nextLevel)
    case .lose:
      remove(message: HUDMessage.lose)
      remove(message: HUDMessage.playAgain)
    case .start:
      remove(message: HUDMessage.tapToStart)
    default:
      break
    }
    
  }
  
  override init() {
    super.init()
    name = "HUD"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func remove(message: String) {
    childNode(withName: message)?.removeFromParent()
  }
  
  func updateGameState(from: GameState, to: GameState) {
    clearUI(gameState: from)
    updateUI(gameState: to)
  }
  
  func updateTimer(time: Int) {
    
    let minutes = (time / 60) % 60
    let seconds = time % 60
    let timeText = String(format: "%02d:%02d", minutes, seconds)
    timerLabel?.text = timeText
    
  }
  
  private func updateUI(gameState: GameState) {
    
    switch gameState {
    case .win:
      add(message: HUDMessage.win, position: .zero)
      add(message: HUDMessage.nextLevel, position: CGPoint(x: 0, y: -100))
    case .lose:
      add(message: HUDMessage.lose, position: .zero)
      add(message: HUDMessage.playAgain, position: CGPoint(x: 0, y: -100))
    case .start:
      add(message: HUDMessage.tapToStart, position: .zero)
    default:
      break
    }
    
  }
  
}
