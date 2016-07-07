//
//  GameScene.swift
//  Bubble Shooter
//
//  Created by sapir oded on 3/15/16.
//  Copyright (c) 2016 sapir oded. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var level : Level!
    var score = 0
    let node = SKNode()
    let arrow = SKSpriteNode(imageNamed: "arrow")
    let firebg = SKSpriteNode(imageNamed: "fireBG")
    let fireBall = SKSpriteNode(imageNamed: "bubble_1")
    let nextBall = SKSpriteNode(imageNamed: "bubble_1")
    let fired = SKSpriteNode(imageNamed: "bubble_1")
    var startFire = false
    var dirX = 1
    var speedX : CGFloat!
    var speedY : CGFloat!
    var dir : CGVector!
    var levelNum : Int!
    let numOfLevels = 4
    var navHeight : CGFloat!
    var viewController : GameViewController!
    
    var gameActive = true
    var didWin = true
    
    var mtimer : NSTimer!
    
    // Setup your scene here
    override func didMoveToView(view: SKView) {
        level = Level(num: levelNum, scene: self)
        
        backgroundColor = UIColor(red: 159.0/255.0, green: 201.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        addGround()
        addScore()
        
        setNode()
        node.addChild(arrow)
        node.addChild(firebg)
        addChild(node)
        
        setFireBalls()
        addChild(fireBall)
        addChild(nextBall)
        addChild(fired)
        
        viewController.title = "Level \(levelNum)"
        
        mtimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updatePosition"), userInfo: nil, repeats: true)
    }
    
    // Called when a touch begins
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        
        if gameActive {
            if(location.y > view!.frame.height/10 && !startFire) {
                let const = SKConstraint.orientToPoint(location, offset: SKRange(constantValue: -90*CGFloat(M_PI)/180))
                node.constraints = [const]
            
                startFire = true
                let diffx = location.x - (view?.frame.width)!/2
                let diffy = location.y - (view?.frame.height)!/10
                if(location.x > (view?.frame.width)!/2) {
                    dirX = 1
                }
                else {
                    dirX = -1
                }
                speedX = CGFloat(1)*CGFloat(dirX)*diffx
                speedY = CGFloat(1)*diffy
                fired.texture = fireBall.texture
                fireBall.texture =  nextBall.texture
                nextBall.texture =  SKTexture(imageNamed: level.generateBubble())
                dir = CGVector(dx: CGFloat(dirX)*speedX, dy: speedY).normalized
                level.activeBubble = fired
            }
        } else { // Win or Lose
            if didWin {
                if level.winPanel.containsPoint(location) { // Clicked
                    if levelNum < numOfLevels {
                        levelNum!++                        
                        level.removePanels()
                        level = Level(num: levelNum, scene: self)
                        resetGame()
                    }
                    else {
                        let alert = UIAlertController(title: "Out of levels", message: "Sorry, there are no more levels at this moment", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        viewController.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                if level.losePanel.containsPoint(location) { // Clicked
                    level.removePanels()
                    level = Level(num: levelNum, scene: self)
                    resetGame()

                }
            }
        }
    }
    
    func updatePosition() {
        if startFire {
            fired.position.x += dir.dx*2
            fired.position.y += dir.dy*2
            level.checkCollision(dir)
            
            if fired.position.x > view!.frame.width-level.bubbleSize/2+3 {
                fired.physicsBody?.velocity.dx = -1*fabs((fired.physicsBody?.velocity.dx)!)
                dir.dx = -1*fabs(dir.dx)
            }
            else if fired.position.x < level.bubbleSize/2+3 {
                fired.physicsBody?.velocity.dx = fabs((fired.physicsBody?.velocity.dx)!)
                dir.dx = fabs(dir.dx)
            }
        }
    }
    
   // Called before each frame is rendered
    override func update(currentTime: CFTimeInterval) {
      /*  if startFire {
            
            fired.position.x += dir.dx*50
            fired.position.y += dir.dy*50
            level.checkCollision(dir)
            
            if fired.position.x > view!.frame.width-level.bubbleSize/2+3 {
                fired.physicsBody?.velocity.dx = -1*fabs((fired.physicsBody?.velocity.dx)!)
                dir.dx = -1*fabs(dir.dx)
            }
            else if fired.position.x < level.bubbleSize/2+3 {
                fired.physicsBody?.velocity.dx = fabs((fired.physicsBody?.velocity.dx)!)
                dir.dx = fabs(dir.dx)
            }
        }*/
    }
    
    internal func endShoot() {
        if(startFire) {
            startFire = false
            fired.texture = fireBall.texture
            fired.position = CGPointMake(view!.frame.width/2, view!.frame.height/10)
        }
    }
    
    func setFireBalls() {
        fireBall.position = CGPointMake(view!.frame.width/2, view!.frame.height/10)
        fireBall.size = CGSize(width: level.bubbleSize, height: level.bubbleSize)
        fireBall.texture =  SKTexture(imageNamed: level.generateBubble())
        
        nextBall.position = CGPointMake(view!.frame.width/2, view!.frame.height/10-40)
        nextBall.size = CGSize(width: level.bubbleSize, height: level.bubbleSize)
        nextBall.texture =  SKTexture(imageNamed: level.generateBubble())
        
        fired.position = CGPointMake(view!.frame.width/2, view!.frame.height/10)
        fired.size = CGSize(width: level.bubbleSize, height: level.bubbleSize)
        fired.texture = fireBall.texture
    }
    
    func setNode() {
        node.position = CGPointMake(CGRectGetMidX(self.frame), view!.frame.height/10)
        node.zPosition = 0
        
        arrow.position = CGPointMake(0, 40)
        arrow.size = CGSize(width: 61.11, height: 49.21)
        
        firebg.position = CGPointMake(0, 0)
        firebg.size = CGSize(width: 40.44, height: 40.44)
    }
    
    func addGround() {
        let skground = SKSpriteNode(imageNamed: "ground")
        skground.size = CGSize(width: view!.frame.width*2, height: view!.frame.height/10)
        skground.position = CGPointMake(0, view!.frame.height/20)
        addChild(skground)
    }
    
    func addScore() {
        let coinView = UIImageView(frame: CGRect(x: 8, y: (view?.frame.height)!-40, width: 32, height: 32))
        coinView.image = UIImage.animatedImageNamed("coin", duration: 1.5)
        view!.addSubview(coinView)
        
        let scoreLabel = UILabel(frame: CGRect(x: 45, y: (view?.frame.height)!-48, width: 150, height: 50))
        scoreLabel.text = "Score: \(score)"
        scoreLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        scoreLabel.font = scoreLabel.font.fontWithSize(24)
        view!.addSubview(scoreLabel)
    }
    
    func setVictory(win: Bool) {
        didWin = win
    }
    
    func resetGame() {
        viewController.title = "Level \(levelNum)"
        gameActive = true
        setFireBalls()
        setNode()
    }
}

private extension CGVector {
    // Get the length (a.k.a. magnitude) of the vector
    var length: CGFloat { return sqrt(self.dx * self.dx + self.dy * self.dy) }
    
    // Normalize the vector (preserve its direction, but change its magnitude to 1)
    var normalized: CGVector { return CGVector(dx: self.dx / self.length, dy: self.dy / self.length) }
}