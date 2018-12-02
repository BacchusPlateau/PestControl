/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class GameScene: SKScene {
  
  var background : SKTileMapNode!
  var player = Player()
  var bugsNode = SKNode()
  var obstaclesTileMap: SKTileMapNode?
  var firebugCount: Int = 0
  var bugsprayTileMap: SKTileMapNode?
  
  func advanceBreakableTile(locatedAt nodePosition: CGPoint) {
    
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    
    let (column, row) = tileCoordinates(in: obstaclesTileMap, at: nodePosition)
    let obstacle = tile(in: obstaclesTileMap, at: (column, row))
    
    guard let nextTileGroupName = obstacle?.userData?.object(forKey: "breakable") as? String
      else { return }
    
    if let nextTileGroup = tileGroupForName(tileSet: obstaclesTileMap.tileSet, name: nextTileGroupName) {
      obstaclesTileMap.setTileGroup(nextTileGroup, forColumn: column, row: row)
    }
    
  }
  
  func createBugs() {
    
    guard let bugsMap = childNode(withName: "bugs") as? SKTileMapNode else { return }
    
    for row in 0..<bugsMap.numberOfRows {
      for col in 0..<bugsMap.numberOfColumns {
        
        guard let tile = tile(in: bugsMap, at: (col, row))
          else { continue }
        
        let bug : Bug
        if tile.userData?.object(forKey: "firebug") != nil {
          bug = Firebug()
          firebugCount += 1
        } else {
          bug = Bug()
        }
        
        bug.position = bugsMap.centerOfTile(atColumn: col, row: row)
        bugsNode.addChild(bug)
        bug.move()
        
      }
    }
    
    bugsNode.name = "Bugs"
    addChild(bugsNode)
    bugsMap.removeFromParent()
    
  }
  
  func createBugSpray(quantity: Int) {
    
    let tile = SKTileDefinition(texture: SKTexture(pixelImageNamed: "bugspray"))
    let tilerule = SKTileGroupRule(adjacency: SKTileAdjacencyMask.adjacencyAll, tileDefinitions: [tile])
    let tilegroup = SKTileGroup(rules: [tilerule])
    let tileset = SKTileSet(tileGroups: [tilegroup])
    
    let cols = background.numberOfColumns
    let rows = background.numberOfRows
    
    bugsprayTileMap = SKTileMapNode(tileSet: tileset, columns: cols, rows: rows, tileSize: tile.size)
    
    for _ in 1...quantity {
      let col = Int.random(min: 0, max: cols - 1)
      let row = Int.random(min: 0, max: rows - 1)
      bugsprayTileMap?.setTileGroup(tilegroup, forColumn: col, row: row)
    }
    
    bugsprayTileMap?.name = "Bugspray"
    addChild(bugsprayTileMap!)
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
    
    switch other.categoryBitMask {
    case PhysicsCategory.Bug:
      //print("bug!")
      if let bug = other.node as? Bug {
        remove(bug: bug)
      }
    case PhysicsCategory.Firebug:
      if player.hasBugspray {
        if let firebug = other.node as? Firebug {
          remove(bug: firebug)
          player.hasBugspray = false
        }
      }
    case PhysicsCategory.Breakable:
      if let obstacleNode = other.node {
        advanceBreakableTile(locatedAt: obstacleNode.position)
        obstacleNode.removeFromParent()
      }
    default:
      //print("\(other.node?.name ?? "z")")
      break
    }
    
    if let physicsBody = player.physicsBody {
      if physicsBody.velocity.length() > 0 {
        player.checkDirection()
      }
    }
    
  }
  
  override func didMove(to view: SKView) {
    
    addChild(player)
    setUpCamera()
    setUpWorldPhysics()
    createBugs()
    setUpObstaclesPhysics()
    createBugSpray(quantity: firebugCount + 10)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    background = childNode(withName: "background") as? SKTileMapNode
    obstaclesTileMap = childNode(withName: "obstacles") as? SKTileMapNode
    
  }
  
  func setUpCamera() {

    guard let camera = childNode(withName: "camera") as? SKCameraNode else { return }

    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
    
    let xInset = min(view!.bounds.width / 2 * camera.xScale, background.frame.width / 2)
    let yInset = min(view!.bounds.height / 2 * camera.yScale, background.frame.height / 2)
    
    let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
    
    let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
    let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    edgeConstraint.referenceNode = background
    
    camera.constraints = [playerConstraint, edgeConstraint]

  }
  
  func setUpObstaclesPhysics() {
    
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    
    for row in 0..<obstaclesTileMap.numberOfRows {
      for col in 0..<obstaclesTileMap.numberOfColumns {
        
        guard let tile = tile(in: obstaclesTileMap,
                              at: (col, row))
          else { continue }
        
        guard tile.userData?.object(forKey: "obstacle") != nil
          else { continue }
        
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Breakable
        node.position = obstaclesTileMap.centerOfTile(atColumn: col, row: row)
        obstaclesTileMap.addChild(node)
      }
    }
  
  }
  
  func setUpWorldPhysics() {
    
    background.physicsBody = SKPhysicsBody(edgeLoopFrom: background.frame)
    background.physicsBody?.categoryBitMask = PhysicsCategory.Edge
    physicsWorld.contactDelegate = self
    
  }
  
  func tile(in tileMap: SKTileMapNode, at coordiates: TileCoordinates) -> SKTileDefinition? {
    
    return tileMap.tileDefinition(atColumn: coordiates.column, row: coordiates.row)
    
  }
  
  func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
    
    let col = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    
    return (col, row)
    
  }
  
  func tileGroupForName(tileSet: SKTileSet, name: String) -> SKTileGroup? {
    
    let tileGroup = tileSet.tileGroups.filter { $0.name == name }.first
    return tileGroup
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let touch = touches.first else { return }
    player.move(target: touch.location(in: self))
    
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if !player.hasBugspray {
      updateBugSpray()
    }
    advanceBreakableTile(locatedAt: player.position)
    
  }
  
  func updateBugSpray() {
    
    guard let bugsprayTileMap = bugsprayTileMap else { return }
    
    let (column, row) = tileCoordinates(in: bugsprayTileMap, at: player.position)
    
    if tile(in: bugsprayTileMap, at: (column, row)) != nil {
      
      bugsprayTileMap.setTileGroup(nil, forColumn: column, row: row)
      player.hasBugspray = true
      
    }
    
  }
  
}

extension GameScene : SKPhysicsContactDelegate {
  
  func remove(bug: Bug) {
    bug.removeFromParent()
    background.addChild(bug)
    bug.die()
  }
  
}



