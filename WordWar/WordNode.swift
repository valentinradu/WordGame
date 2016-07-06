//
//  WordNode.swift
//  WordWar
//
//  Created by Valentin Radu on 05/07/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import SpriteKit

class WordNode: SKNode {
    
    let letters:[SKLabelNode]
    
    init(text:String) {
        letters = text.characters.map {SKLabelNode(text: String($0))}
        super.init()
        
        var prevLabel:SKLabelNode?
        letters.enumerate().forEach {
            i, label in
            addChild(label)
            label.fontSize = 50
            label.fontColor = .random()
            
            if let prevLabel = prevLabel {
                let distance = prevLabel.frame.width / 2 + label.frame.width / 2
                label.position = CGPoint(x:prevLabel.position.x + distance,
                    y: 0)
                let range = SKRange(value: distance, variance: distance + 30)
                label.constraints = [SKConstraint.distance(range, toNode: prevLabel)]
            }
            prevLabel = label
        }
        
        let width = CGRectGetMaxX(prevLabel?.frame ?? .zero)
        
        letters.forEach {
            label in
            label.position = CGPoint(x: label.position.x - width/2, y: label.position.y)
        }
    }
    
    func addPhysics() {
        var prevLabel:SKLabelNode?
        letters.enumerate().forEach {
            i, label in
            
            label.physicsBody = SKPhysicsBody(rectangleOfSize: label.frame.size,
                center: CGPoint(x: 0, y: label.frame.size.height / 2))
            label.physicsBody?.mass = 1.0;
            label.physicsBody?.angularDamping = 0.5
            label.physicsBody?.linearDamping = 3.5
            label.physicsBody?.friction = 0.85
            label.physicsBody?.restitution = 0.7
            label.physicsBody?.allowsRotation = false
            if let prevLabel = prevLabel {
                let spring = SKPhysicsJointSpring.jointWithBodyA(prevLabel.physicsBody!,
                    bodyB: label.physicsBody!,
                    anchorA: CGPoint(x: 0.5, y: 0.5),
                    anchorB:CGPoint(x: 0.5, y: 0.5))
                spring.damping = 0.05
                spring.frequency = 2
                self.scene?.physicsWorld.addJoint(spring)
            }
            
            prevLabel = label
        }
    }
    
    func applyRandomImpulse(limit:CGFloat) {
        letters.forEach {
            label in
            label.physicsBody?.applyImpulse(CGVector(dx: .random(-limit, upper:limit), dy: .random(-limit, upper:limit)))
        }
    }
    
    func breakOut() {
        letters.forEach {
            label in
            label.physicsBody?.allowsRotation = true
            label.physicsBody?.joints.forEach {
                joint in
                self.scene?.physicsWorld.removeJoint(joint)
            }
            
            label.constraints = []
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
