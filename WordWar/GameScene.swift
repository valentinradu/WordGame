//
//  GameScene.swift
//  WordWar
//
//  Created by Valentin Radu on 05/07/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var topNode:SKNode? {
        didSet {
            oldValue?.removeFromParent()
            if let topNode = topNode {
                addChild(topNode)
                topNode.position = CGPoint(x: size.width/2, y: size.height)
                let range = SKRange(value: topNode.position.x, variance: 10)
                topNode.constraints = [SKConstraint.positionX(range)]
            }
        }
    }
    
    var bottomNode:SKNode? {
        didSet {
            oldValue?.removeFromParent()
            if let bottomNode = bottomNode {
                addChild(bottomNode)
                bottomNode.position = CGPoint(x: size.width/2, y: floor?.frame.height ?? 0.0)
            }
        }
    }
    
    var floor:SKShapeNode?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        let floor = SKShapeNode(rectOfSize: CGSize(width: size.width, height: 1))
        addChild(floor)
        floor.lineWidth = 0.0
        floor.fillColor = .clearColor()
        floor.position = CGPoint(x: size.width / 2, y: floor.frame.size.height / 2)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: floor.frame.size)
        floor.physicsBody?.mass = 1
        floor.physicsBody?.friction = 0.5;
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.dynamic = false
        
        self.floor = floor
    }
}
