//
//  GameViewController.swift
//  WordWar
//
//  Created by Valentin Radu on 05/07/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import UIKit
import SpriteKit

private let NotestCategory = UInt32(0x1 << 1)
private let ActiveCategory = UInt32(0x1 << 2)
private let PassiveCategory = UInt32(0x1 << 3)
private let GhostCategory = UInt32(0x1 << 4)


class GameViewController: UIViewController, SKPhysicsContactDelegate {
    
    var dictionary:[String:String]?
    private var activeWord:String?
    private var passiveWord:String?
    private var livesLabel:UILabel?
    private var scoreLabel:UILabel?
    
    private var livesCount:Int = 0 {
        didSet {
            updateLivesLabel()
        }
    }
    
    private var score:Int = 0 {
        didSet {
            updateScoreLabel()
        }
    }
    
    override func loadView() {
        view = SKView(frame: .zero)
        
        let livesLbl = UILabel(frame: .zero)
        view.addSubview(livesLbl)
        livesLbl.translatesAutoresizingMaskIntoConstraints = false
        livesLbl.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20).active = true
        livesLbl.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 20).active = true
        livesLabel = livesLbl
        
        let scoreLbl = UILabel(frame: .zero)
        view.addSubview(scoreLbl)
        scoreLbl.translatesAutoresizingMaskIntoConstraints = false
        scoreLbl.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20).active = true
        scoreLbl.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -20).active = true
        scoreLabel = scoreLbl
        
        updateLivesLabel()
        updateScoreLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let view = view as? SKView else {assertionFailure();return}
        
        let scene = GameScene(size: view.frame.size)
        scene.scaleMode = .ResizeFill
        scene.physicsWorld.contactDelegate = self
        view.presentScene(scene)
        
        scene.floor?.physicsBody?.categoryBitMask = PassiveCategory
        
        stopGame()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let alert = UIAlertController(title: "Ready?", message: "Did you know that enneacontakaienneagon is actually a word in the English language?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Start!", style: .Default, handler: {
            action in
            self.startGame()
        }))
        self.showViewController(alert, sender: self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let view = view as? SKView else {assertionFailure();return}
        guard let touch = touches.first else {assertionFailure();return}
        guard let scene = view.scene as? GameScene else {assertionFailure();return}
        guard let topNode = scene.topNode as? WordNode else {assertionFailure();return}
        
        let point = scene.convertPointFromView(touch.locationInView(view))
        let node = scene.nodeAtPoint(point)
        
        if topNode.children.contains(node) {
            topNode.letters.forEach{$0.physicsBody?.categoryBitMask = GhostCategory}
            topNode.letters.forEach{$0.physicsBody?.contactTestBitMask = NotestCategory}
            
            topNode.breakOut()
            topNode.applyRandomImpulse(1000)
            let fade = SKAction.fadeOutWithDuration(0.25)
            let remove = SKAction.removeFromParent()
            let notify = SKAction.runBlock {
                self.resetActiveWord()
            }
            topNode.runAction(SKAction.sequence([fade, remove, notify]))
        }
        
        if areWordsMatching() {
            livesCount -= 1
            if livesCount == 0 {
                stopGame()
                let message = String(format:"%@ and %@ actually mean the same thing! Try again?", activeWord ?? "", passiveWord ?? "")
                let alert = UIAlertController(title: "Game over",
                                              message:  message ,
                                              preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Yes!", style: .Default, handler: {
                    action in
                    self.startGame()
                }))
                self.showViewController(alert, sender: self)
            }
        }
        else {
            score += 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.PortraitUpsideDown, .Portrait]
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        guard (contact.bodyA.categoryBitMask & contact.bodyB.contactTestBitMask != 0) else {return}
        guard let view = view as? SKView else {assertionFailure();return}
        guard let scene = view.scene as? GameScene else {assertionFailure();return}
        guard let topNode = scene.topNode as? WordNode else {assertionFailure();return}
        guard let bottomNode = scene.bottomNode as? WordNode else {assertionFailure();return}
        
        let group = dispatch_group_create()
        
        func hide(node:WordNode) {
            dispatch_group_enter(group)
            node.letters.forEach{$0.physicsBody?.categoryBitMask = GhostCategory}
            node.letters.forEach{$0.physicsBody?.contactTestBitMask = NotestCategory}
            
            node.breakOut()
            
            let fade = SKAction.fadeOutWithDuration(0.25)
            let remove = SKAction.removeFromParent()
            let notify = SKAction.runBlock {
                dispatch_group_leave(group)
            }
            node.runAction(SKAction.sequence([fade, remove, notify]))
        }
        
        func explode(node:WordNode) {
            dispatch_group_enter(group)
            node.letters.forEach{$0.physicsBody?.categoryBitMask = GhostCategory}
            node.letters.forEach{$0.physicsBody?.contactTestBitMask = NotestCategory}
            
            node.breakOut()
            
            node.applyRandomImpulse(1000)
            let fade = SKAction.fadeOutWithDuration(0.25)
            let remove = SKAction.removeFromParent()
            let notify = SKAction.runBlock {
                dispatch_group_leave(group)
            }
            node.runAction(SKAction.sequence([fade, remove, notify]))
        }
        
        if areWordsMatching() {
            hide(topNode)
            hide(bottomNode)
            score += 3
        }
        else {
            explode(topNode)
            explode(bottomNode)
            livesCount -= 1
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.resetActiveWord()
            self.resetPassiveWord()
            
            if self.livesCount == 0 {
                self.stopGame()
                let message = String(format:"Nope %@ and %@ mean different things! Try again?", self.activeWord ?? "", self.passiveWord ?? "")
                let alert = UIAlertController(title: "Game over",
                                              message: message,
                                              preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Yes!", style: .Default, handler: {
                    action in
                    self.startGame()
                }))
                self.showViewController(alert, sender: self)
            }
        }
    }
    
    private func resetActiveWord() {
        guard let view = view as? SKView else {assertionFailure();return}
        guard let scene = view.scene as? GameScene else {assertionFailure();return}
        
        randomizeActiveWord()
        let topNode = WordNode(text: self.activeWord ?? "")
        scene.topNode = topNode
        initializeWord(topNode)
        topNode.applyRandomImpulse(200)
        topNode.letters.forEach{$0.physicsBody?.contactTestBitMask = PassiveCategory}
        topNode.letters.forEach{$0.physicsBody?.categoryBitMask = ActiveCategory}
    }
    
    private func resetPassiveWord() {
        guard let view = view as? SKView else {assertionFailure();return}
        guard let scene = view.scene as? GameScene else {assertionFailure();return}
        
        randomizePassiveWord()
        let bottomNode = WordNode(text: self.passiveWord ?? "")
        scene.bottomNode = bottomNode
        initializeWord(bottomNode)
        bottomNode.letters.forEach{$0.physicsBody?.contactTestBitMask = ActiveCategory}
        bottomNode.letters.forEach{$0.physicsBody?.categoryBitMask = PassiveCategory}
    }
    
    private func initializeWord(node:WordNode) {
        node.alpha = 0.0
        node.runAction(SKAction.fadeInWithDuration(0.25))
        node.addPhysics()
    }
    
    private func randomizePassiveWord() {
        guard let dictionary = dictionary else {assertionFailure();return}
        passiveWord = Array(dictionary.keys).shuffle().first
    }
    
    private func randomizeActiveWord() {
        guard let dictionary = dictionary else {assertionFailure();return}
        activeWord = Array(dictionary.values).shuffle().first
    }
    
    private func areWordsMatching() -> Bool {
        guard let activeWord = activeWord else {assertionFailure();return false}
        guard let passiveWord = passiveWord else {assertionFailure();return false}
        return dictionary?[passiveWord] == activeWord
    }
    
    private func updateLivesLabel() {
        let attrs = [NSFontAttributeName:UIFont.systemFontOfSize(20),
                     NSForegroundColorAttributeName:UIColor.lipstick()]
        livesLabel?.attributedText = NSAttributedString(string: String(livesCount) + "♥", attributes: attrs)
    }
    
    private func updateScoreLabel() {
        let attrs = [NSFontAttributeName:UIFont.systemFontOfSize(20),
                     NSForegroundColorAttributeName:UIColor.chillBlue()]
        scoreLabel?.attributedText = NSAttributedString(string: String(score), attributes: attrs)
    }
    
    private func startGame() {
        guard let view = self.view as? SKView else {assertionFailure();return}
        view.paused = false
        livesCount = 3
        score = 0
        resetActiveWord()
        resetPassiveWord()
    }
    
    private func stopGame() {
        guard let view = self.view as? SKView else {assertionFailure();return}
        view.paused = true
    }
}
