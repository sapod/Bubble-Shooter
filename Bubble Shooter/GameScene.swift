//
//  GameScene.swift
//  Bubble Shooter
//
//  Created by sapir oded on 3/15/16.
//  Copyright (c) 2016 sapir oded. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    static let numOfLevels = 4
    private var level : Level!
    
    private var scoreLabel : UILabel!
    private let node = SKNode()
    private let arrow = SKSpriteNode(imageNamed: "arrow")
    private let firebg = SKSpriteNode(imageNamed: "fireBG")
    private let fireBall = SKSpriteNode(imageNamed: "bubble_1")
    private let nextBall = SKSpriteNode(imageNamed: "bubble_1")
    private let fired = SKSpriteNode(imageNamed: "bubble_1")
    
    private var didWin = true
    private var startFire = false
    private var dirX = 1
    private var speedX : CGFloat!
    private var speedY : CGFloat!
    private var dir : CGVector!
    
    var canShoot = true
    var gameActive = true
    var levelNum : Int!
    var score = 0
    var navHeight : CGFloat!
    var viewController : GameViewController!
    var skground : SKSpriteNode!
    
    // Audio
    var audioPlayer:AVAudioPlayer!
    let hit = NSBundle.mainBundle().pathForResource("hit", ofType: "wav")
    let shoot = NSBundle.mainBundle().pathForResource("shoot", ofType: "wav")
    let falling = NSBundle.mainBundle().pathForResource("falling", ofType: "wav")
    let win = NSBundle.mainBundle().pathForResource("win", ofType: "wav")
    let lose = NSBundle.mainBundle().pathForResource("lose", ofType: "wav")
    
    // Scene setup
    override func didMoveToView(view: SKView) {
        let scoresDB = Scores.getInstance()
        scoresDB.checkDB()
        
        backgroundColor = UIColor(red: 159.0/255.0, green: 201.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        addGround()
        addScore()
        
        level = Level(num: levelNum, scene: self)
        viewController.title = "Level \(levelNum)"
        
        setNode()
        node.addChild(arrow)
        node.addChild(firebg)
        addChild(node)
        
        setFireBalls()
        addChild(fireBall)
        addChild(nextBall)
        addChild(fired)     
    }
    
    func cancelLevelThread() {
        level.endTimer()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        
        if gameActive {
            if(location.y > view!.frame.height/10 && canShoot) {
                let audioFileUrl = NSURL.fileURLWithPath(shoot!)
                do {
                    try audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
                    audioPlayer.play()
                }
                catch {
                    print("Error playing shoot sound")
                }
                
                let const = SKConstraint.orientToPoint(location, offset: SKRange(constantValue: -90*CGFloat(M_PI)/180))
                node.constraints = [const]
            
                startFire = true
                canShoot = false
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
                
                startThread()
            }
        } else { // Win or Lose
            if didWin {
                if level.winPanel.containsPoint(location) { // Next level
                    if levelNum < GameScene.numOfLevels {
                        levelNum! += 1                        
                        level.removePanels()
                        level.reset()
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
                if level.losePanel.containsPoint(location) { // Restart game
                    level.removePanels()
                    level.reset()
                    level = Level(num: levelNum, scene: self)
                    resetGame()

                }
            }
        }
    }
    
    private func startThread() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.updatePosition()
        })
    }
    
    private func updatePosition() {
        while startFire {
            let delta = CGFloat(0.3)
            var point = fired.position
            
            if dir.dx < 0 {
                point.x -= level.bubbleSize/2
            } else {
                point.x += level.bubbleSize/2
            }
            
            if level.rightWall.containsPoint(point)  {
                dir.dx = -1*fabs(dir.dx)
            }
            else if level.leftWall.containsPoint(point) {
                dir.dx = fabs(dir.dx)
            }
            
            fired.position.x += dir.dx*delta
            fired.position.y += dir.dy*delta
            level.checkCollision(dir)
        }
    }
    
    internal func endShoot() {
        if(startFire) {
            startFire = false
            fired.texture = fireBall.texture
            fired.position = CGPointMake(view!.frame.width/2, view!.frame.height/10)
        }
    }
    
    private func setFireBalls() {
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
    
    private func setNode() {
        node.position = CGPointMake(CGRectGetMidX(self.frame), view!.frame.height/10)
        node.zPosition = 0
        
        arrow.position = CGPointMake(0, 40)
        arrow.size = CGSize(width: 61.11, height: 49.21)
        
        firebg.position = CGPointMake(0, 0)
        firebg.size = CGSize(width: 40.44, height: 40.44)
    }
    
    private func addGround() {
        skground = SKSpriteNode(imageNamed: "ground")
        skground.size = CGSize(width: view!.frame.width, height: view!.frame.height/10)
        skground.position = CGPointMake(view!.frame.width/2, view!.frame.height/20)
        addChild(skground)
    }
    
    private func addScore() {
        let coinView = UIImageView(frame: CGRect(x: 8, y: (view?.frame.height)!-40, width: 32, height: 32))
        coinView.image = UIImage.animatedImageNamed("coin", duration: 1.5)
        view!.addSubview(coinView)
        
        scoreLabel = UILabel(frame: CGRect(x: 45, y: (view?.frame.height)!-48, width: 150, height: 50))
        scoreLabel.text = "Score: \(score)"
        scoreLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        scoreLabel.font = scoreLabel.font.fontWithSize(24)
        view!.addSubview(scoreLabel)
    }
    
    func setVictory(win: Bool) {
        didWin = win
    }
    
    func updateScore(s: Int) {
        score += s
        dispatch_async(dispatch_get_main_queue(), {
            self.scoreLabel.text = "Score: \(self.score)"
        })
        
    }
    
    private func resetGame() {
        viewController.title = "Level \(levelNum)"
        gameActive = true
        setFireBalls()
        setNode()
        score = 0
        updateScore(0)
    }
}

private extension CGVector {
    // Get the length (a.k.a. magnitude) of the vector
    var length: CGFloat { return sqrt(self.dx * self.dx + self.dy * self.dy) }
    
    // Normalize the vector (preserve its direction, but change its magnitude to 1)
    var normalized: CGVector { return CGVector(dx: self.dx / self.length, dy: self.dy / self.length) }
}