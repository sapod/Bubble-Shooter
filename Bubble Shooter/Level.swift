//
//  Level1.swift
//  Bubble Shooter
//
//  Created by sapir oded on 3/23/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Level : NSObject, SKPhysicsContactDelegate {
    let scalefactor = CGFloat(0.07)
    internal let bubbleCategory: UInt32 = 0x1 << 0
    var scene : GameScene
    var options = [""]
    var downDelta : Int!
    let bubbleSize = CGFloat(33.6)
    let rowDiff = 5
    let minBubbles = 3
    let pointsPerBubble = 5
    var mtimer : NSTimer!
    
    var startingIndex = 0 // First active row
    var activeBubble : SKSpriteNode?
    var matrix : [[SKSpriteNode?]]
    var positions : [[CGPoint?]]
    var group = [SKSpriteNode]()
    var firstIndeces : [CGPoint?]
    var connected = [CGPoint]()
    var numBubbles = 0
    var levelNumber : Int!
    
    var heightDeltaUp :CGFloat!
    var heightDeltaDown :CGFloat!
    var height : CGFloat!
    var width : CGFloat!
    var xGap : CGFloat!
    
    let winPanel : SKSpriteNode
    let losePanel : SKSpriteNode
    
    let pillar = SKSpriteNode(imageNamed: "pillar")
    let leftWall = SKSpriteNode(imageNamed: "wood")
    let rightWall = SKSpriteNode(imageNamed: "wood")
    
    init(num: Int, scene: GameScene) {
        self.levelNumber = num
        self.scene = scene
        heightDeltaUp = scene.navHeight
        heightDeltaDown = scene.skground.size.height
        height = (scene.view?.frame.height)! - heightDeltaUp - heightDeltaDown
        width = (scene.view?.frame.width)!
        var rows = (Int)(height/bubbleSize)
        let cols = (Int)(width/bubbleSize)
        xGap = width - CGFloat(cols)*bubbleSize
        
        var d = CGFloat(rowDiff*rows)
        while d >= bubbleSize {
            rows++
            d -= bubbleSize
        }
        rows++
        
        matrix = [[SKSpriteNode?]](count: cols, repeatedValue: [SKSpriteNode?](count: rows, repeatedValue: nil))
        positions = [[CGPoint?]](count: cols, repeatedValue: [CGPoint?](count: rows, repeatedValue: nil))
        activeBubble = nil
        firstIndeces = [CGPoint?](count: minBubbles-1, repeatedValue: nil)
        
        let size = CGSize(width: width-10, height: 200)
        let pos = CGPoint(x: width/2, y: height/2 + heightDeltaDown)
        
        winPanel = SKSpriteNode(imageNamed: "win")
        winPanel.size = size
        winPanel.position = pos
        
        losePanel = SKSpriteNode(imageNamed: "lose")
        losePanel.size = size
        losePanel.position = pos
        
        // For time lowering
        pillar.position = CGPoint(x: 0, y: height + heightDeltaDown)
        pillar.anchorPoint = CGPoint(x: 0, y: 0)
        let h = CGFloat(pillar.size.height / pillar.size.width) * width
        pillar.size = CGSize(width: width,height: h)
        scene.addChild(pillar)
        
        // Left wall
        leftWall.position = CGPoint(x: 0, y: heightDeltaDown)
        leftWall.anchorPoint = CGPoint(x: 0, y: 0)
        leftWall.size = CGSize(width: xGap/2, height: height)
        scene.addChild(leftWall)
        
        // Right wall
        rightWall.position = CGPoint(x: width-xGap/2, y: heightDeltaDown)
        rightWall.anchorPoint = CGPoint(x: 0, y: 0)
        rightWall.size = CGSize(width: xGap/2, height: height)
        scene.addChild(rightWall)
        
        /*let r = CGRect(x: 0, y: heightDeltaDown, width: width, height: height)
        let rect = SKShapeNode()
        rect.lineWidth = 3
        rect.strokeColor = SKColor.greenColor()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, r)
        rect.path = path
        scene.addChild(rect)*/
        
        super.init()
        
        switch(num) {
        case 1:
            level1()
            break;
        case 2:
            level2()
            break;
        case 3:
            level3()
            break;
        case 4:
            level4()
            break;
        default:
            print("No such level number: \(num)")
        }
    }
    
    func level1() {
        options = ["bubble_3","bubble_4"]
        downDelta = 10
       // startTimer()
        
        for var i=0;i<matrix.count;i++ {
            if(i==3 || i == matrix.count-4) {
                matrix[i][0] = SKSpriteNode(imageNamed: options[1])
            } else {
                matrix[i][0] = SKSpriteNode(imageNamed: options[0])
            }
        }
        for var i=3;i<matrix.count-2;i++ {
            if(i==3 || i == matrix.count-3) {
                matrix[i][1] = SKSpriteNode(imageNamed: options[0])
            }
            else {
                matrix[i][1] = SKSpriteNode(imageNamed: options[1])
            }
        }
        for var i=3;i<matrix.count-3;i++ {
            if(i < 5 || i > matrix.count-6) {
                matrix[i][2] = SKSpriteNode(imageNamed: options[0])
            }
            else {
                matrix[i][2] = SKSpriteNode(imageNamed: options[1])
            }
        }
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))-1][3] = SKSpriteNode(imageNamed: options[0])
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))][3] = SKSpriteNode(imageNamed: options[1])
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))+1][3] = SKSpriteNode(imageNamed: options[0])
 
        initBoard()
    }
    
    func level2() {
        options = ["bubble_3","bubble_4","bubble_5","bubble_6"]
        downDelta = 7
        startTimer()
        
        initBoard()
    }
    
    func level3() {
        options = ["bubble_3","bubble_4",
            "bubble_5","bubble_6","bubble_7","bubble_8"]
        downDelta = 5
        startTimer()
        
        initBoard()
    }
    
    func level4() {
        options = ["bubble_1","bubble_2","bubble_3","bubble_4",
            "bubble_5","bubble_6","bubble_7","bubble_8"]
        downDelta = 3
        startTimer()
        
        initBoard()
    }
    
    func startTimer() {
        mtimer = NSTimer.scheduledTimerWithTimeInterval(Double(downDelta), target: self, selector: Selector("pushDown"), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        if mtimer != nil {
            mtimer.invalidate()
        }
    }
    
    func generateBubble() -> String {
        let random = arc4random_uniform(UInt32(options.count))
        let bubble = options[Int(random)]
        return bubble
    }
    
    func getOptions() -> [String] {
        return options
    }
    
    func addBubble(bubble: SKSpriteNode, index: CGPoint) {
        let copy = SKSpriteNode()
        copy.texture = bubble.texture
        copy.size = bubble.size
        copy.position = getPositionFromPoint(index)
        matrix[(Int)(index.x)][(Int)(index.y)] = copy
        scene.addChild(copy)
        numBubbles++
        print("ball added at (\((Int)(index.x)),\((Int)(index.y)))")
    }
    
    func initBoard() {
        for var i=0;i<matrix.count;i++ {
            for var j=0;j<matrix[i].count;j++ {
                let bubble = matrix[i][j]
                if positions[i][j] == nil { // init positions
                    positions[i][j] = getPositionFromPoint(CGPoint(x: i, y: j))
                }
                if bubble != nil {
                    numBubbles++
                    bubble!.size = CGSize(width: bubbleSize, height: bubbleSize)
                    bubble!.position = positions[i][j]!
                    
                    scene.addChild(bubble!)
                }
            }
        }
        
        let line = SKShapeNode()
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, xGap/2, positions[0][positions[0].count-2]!.y + bubbleSize/2)
        CGPathAddLineToPoint(pathToDraw, nil, width-xGap/2, positions[0][positions[0].count-2]!.y + bubbleSize/2)
        line.path = pathToDraw
        line.strokeColor = SKColor.redColor()
        line.lineWidth = 2
        scene.addChild(line)
        
        print("c = \(matrix.count), index c = \(matrix[0].count)")
    }
    
    func getPositionFromPoint(p: CGPoint) -> CGPoint {
        var pos = CGPointMake(xGap/2 + CGFloat(p.x)*bubbleSize+bubbleSize/2, height+heightDeltaDown-(CGFloat(p.y)*bubbleSize+bubbleSize/2))
        pos.y += p.y*CGFloat(rowDiff)
        if p.y%2 == 1 {
            pos.x -= bubbleSize/2
        }
        return pos
    }
    
    func checkCollision(dir: CGVector) {
        if activeBubble != nil {
            let pos = activeBubble!.position
            let index = positionIndex(pos)
            
            if index != nil && Int(index!.y) == startingIndex { // Last possible row
                collided(index!, dir: dir)
            } else if index != nil {
                for var i=0;i<matrix.count;i++ {
                    for var j=startingIndex;j<matrix[i].count;j++ {
                        if matrix[i][j] != nil && CGPoint.distance(pos, p2: matrix[i][j]!.position) <= bubbleSize+1 {
                            collided(index!, dir: dir)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func collided(var index: CGPoint, dir: CGVector) {
        if matrix[(Int)(index.x)][(Int)(index.y)] != nil {
            print("Error: Filled index!")
            
            var pos = activeBubble!.position
            
            var i : CGPoint?
            i = index
            while i == index {
                pos.x -= dir.dx
                pos.y -= dir.dy
                i = positionIndex(pos)
                
                if i == nil || matrix[(Int)(i!.x)][(Int)(i!.y)] != nil {
                    scene.endShoot()
                    activeBubble = nil
                    print("could't fix error")
                    return
                }
            }
            index = i!
        }
        
        if index.y%2 == 1 && index.x == 0 {
            index.y++
        }
        
        let audioFileUrl = NSURL.fileURLWithPath(scene.hit!)
        do {
            try scene.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
            scene.audioPlayer.play()
        }
        catch {
            print("Error playing hit sound")
        }

        addBubble(activeBubble!, index: index)
        scene.endShoot()
        
        group.removeAll()
        checkNeighbors(matrix[(Int)(index.x)][(Int)(index.y)]!, index: index)
        
        if group.count >= minBubbles {
            checkFalls()
            numBubbles -= group.count
            scene.updateScore(group.count * pointsPerBubble)
            print("current number of bubbles: \(numBubbles)")
            
            let audioFileUrl = NSURL.fileURLWithPath(scene.falling!)
            do {
                try scene.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
                scene.audioPlayer.play()
            }
            catch {
                print("Error playing falling sound")
            }
            
            for var i=0;i<group.count;i++ {
                let animation = SKAction.moveToY(0, duration: 1.5)
                let doneAction = (SKAction.runBlock({
                    if self.group.count > 0 {
                        self.scene.removeChildrenInArray(self.group)
                        self.group.removeAll()
                    }
                }))
                let sequence = (SKAction.sequence([animation, doneAction]))
                group[i].runAction(sequence)
            }
            
            if numBubbles <= 0 { // Win
                winLose(true)
            }
        } else { // Return the bubbles
            for var i=0;i<firstIndeces.count;i++ {
                if firstIndeces[i] != nil {
                    let x = (Int)(firstIndeces[i]!.x)
                    let y = (Int)(firstIndeces[i]!.y)
                    matrix[x][y] = group[i]
                }
            }
            group.removeAll()
        }
        
        for var i=0;i<firstIndeces.count;i++ {
            firstIndeces[i] = nil
        }
        
        activeBubble = nil
        checkLose()
    }
    
    func positionIndex(pos: CGPoint) -> CGPoint? {
        for var i=0;i<positions.count;i++ {
            for var j=startingIndex;j<positions[i].count;j++ {
                let rect = CGRect(x: positions[i][j]!.x - bubbleSize/2, y: positions[i][j]!.y - bubbleSize/2, width: bubbleSize, height: bubbleSize)
                if(CGRectContainsPoint(rect, pos)) {
                    return CGPoint(x: i,y: j)
                }
            }
        }
        
        return nil
    }
    
    func checkNeighbors(root: SKSpriteNode, index: CGPoint) {
        let col = (Int)(index.x)
        let row = (Int)(index.y)
        let color = root.texture?.description
        var bubble : SKSpriteNode?
        
        if !group.contains(root) {
            group.append(root)
            matrix[col][row] = nil
            
            // Saving the first indeces to return the bubbles to their place if there are not enough buubles
            for var i=0;i<firstIndeces.count;i++ {
                if firstIndeces[i] == nil {
                    firstIndeces[i] = index
                    break
                }
            }
        }
        
        // Same row
        if col > 0 {
            bubble = matrix[col-1][row]
            if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                checkNeighbors(bubble!, index: CGPoint(x: col-1, y: row))
            }
        }
        
        if col < matrix.count-1 {
            bubble = matrix[col+1][row]
            if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                checkNeighbors(bubble!, index: CGPoint(x: col+1, y: row))
            }
        }
        
        // Previous row
        if row > 0 {
            bubble = matrix[col][row-1]
            if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                checkNeighbors(bubble!, index: CGPoint(x: col, y: row-1))
            }
            
            if row%2 == 0 {
                if col < matrix.count-1 {
                    bubble = matrix[col+1][row-1]
                    if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                        checkNeighbors(bubble!, index: CGPoint(x: col+1, y: row-1))
                    }
                }
            } else  {
                if col > 0 {
                    bubble = matrix[col-1][row-1]
                    if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                        checkNeighbors(bubble!, index: CGPoint(x: col-1, y: row-1))
                    }
                }
            }
        }
        
        // Next row
        if row < matrix[col].count-1 {
            bubble = matrix[col][row+1]
            if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                checkNeighbors(bubble!, index: CGPoint(x: col, y: row+1))
            }
            
            if row%2 == 0 {
                if col < matrix.count-1 {
                    bubble = matrix[col+1][row+1]
                    if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                        checkNeighbors(bubble!, index: CGPoint(x: col+1, y: row+1))
                    }
                }
            } else  {
                if col > 0 {
                    bubble = matrix[col-1][row+1]
                    if bubble != nil && bubble!.texture?.description == color && !group.contains(bubble!) {
                        checkNeighbors(bubble!, index: CGPoint(x: col-1, y: row+1))
                    }
                }
            }
        }
    }
    
    func checkFalls() {
        var flags = [[Bool]](count: matrix.count, repeatedValue: [Bool](count: matrix[0].count, repeatedValue: false))
        connected.removeAll()
        
        for var i=0;i<matrix.count;i++ {
            if matrix[i][startingIndex] != nil {
                connections(CGPoint(x: i, y: startingIndex))
                for var j=0;j<connected.count;j++ {
                    let x = (Int)(connected[j].x)
                    let y = (Int)(connected[j].y)
                    flags[x][y] = true
                }
            }
        }
        
        for var i=0;i<flags.count;i++ {
            for var j=0; j<flags[i].count;j++ {
                if matrix[i][j] != nil && !flags[i][j] { // Bubble is not connected
                    group.append(matrix[i][j]!)
                    matrix[i][j] = nil
                }
            }
        }
    }
    
    func connections(index: CGPoint) {
        if !connected.contains(index) {
            connected.append(index)
        }
        let col = (Int)(index.x)
        let row = (Int)(index.y)
        var bubble : SKSpriteNode?
        var item : CGPoint
        
        // Same row
        if col > 0 {
            bubble = matrix[col-1][row]
            item = CGPoint(x: col-1, y: row)
            if bubble != nil && !connected.contains(item) {
                connections(item)
            }
        }
        
        if col < matrix.count-1 {
            bubble = matrix[col+1][row]
            item = CGPoint(x: col+1, y: row)
            if bubble != nil && !connected.contains(item) {
                connections(item)
            }
        }
        
        // Previous row
        if row > 0 {
            bubble = matrix[col][row-1]
            item = CGPoint(x: col, y: row-1)
            if bubble != nil && !connected.contains(item) {
                connections(item)
            }
            
            if row%2 == 0 {
                if col < matrix.count-1 {
                    bubble = matrix[col+1][row-1]
                    item = CGPoint(x: col+1, y: row-1)
                    if bubble != nil && !connected.contains(item) {
                        connections(item)
                    }
                }
            } else  {
                if col > 0 {
                    bubble = matrix[col-1][row-1]
                    item = CGPoint(x: col-1, y: row-1)
                    if bubble != nil && !connected.contains(item) {
                        connections(item)
                    }
                }
            }
        }
        
        // Next row
        if row < matrix[col].count-1 {
            bubble = matrix[col][row+1]
            item = CGPoint(x: col, y: row+1)
            if bubble != nil && !connected.contains(item) {
                connections(item)
            }
            
            if row%2 == 0 {
                if col < matrix.count-1 {
                    bubble = matrix[col+1][row+1]
                    item = CGPoint(x: col+1, y: row+1)
                    if bubble != nil && !connected.contains(item) {
                        connections(item)
                    }
                }
            } else  {
                if col > 0 {
                    bubble = matrix[col-1][row+1]
                    item = CGPoint(x: col-1, y: row+1)
                    if bubble != nil && !connected.contains(item) {
                        connections(item)
                    }
                }
            }
        }
    }
    
    func pushDown() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while self.activeBubble != nil {} // Wait for fired bubble to take it's place
            self.pillar.position.y = self.positions[0][self.startingIndex+1]!.y-self.bubbleSize/2
            for var i=0;i<self.matrix.count;i++ {
                for var j=self.matrix[i].count-1;j>=self.startingIndex;j-- {
                    if j-self.startingIndex < 2 {
                        if self.matrix[i][j] != nil {
                            self.matrix[i][j] = nil
                        }
                    } else {
                        if self.matrix[i][j-2] != nil {
                            self.matrix[i][j-2]!.position = self.positions[i][j]!
                            self.matrix[i][j] = self.matrix[i][j-2]
                        }
                    }
                }
            }
            
            self.startingIndex+=2
            
            self.checkLose()
        });
    }
    
    func checkLose() {
        for var i=0;i<matrix.count;i++ {
            if matrix[i][matrix[i].count-1] != nil {
                winLose(false)
                break
            }
        }
    }
    
    func winLose(win: Bool) {
        if win {
            scene.addChild(winPanel)
            
            let audioFileUrl = NSURL.fileURLWithPath(scene.win!)
            do {
                try scene.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
                scene.audioPlayer.play()
            }
            catch {
                print("Error playing win sound")
            }
        } else {
            scene.addChild(losePanel)
            
            let audioFileUrl = NSURL.fileURLWithPath(scene.lose!)
            do {
                try scene.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
                scene.audioPlayer.play()
            }
            catch {
                print("Error playing lose sound")
            }
        }
        scene.gameActive = false
        scene.setVictory(win)
        endTimer()
    }
    
    func removePanels() {
        if scene.children.contains(winPanel) {
            winPanel.removeFromParent()
        }
        if scene.children.contains(losePanel) {
            losePanel.removeFromParent()
        }
    }
    
    func reset() {
        for var i=0;i<matrix.count;i++ {
            for var j=0;j<matrix[i].count;j++ {
                if matrix[i][j] != nil {
                    matrix[i][j]!.removeFromParent()
                }
            }
        }
        
        let arr = [pillar, leftWall, rightWall]
        scene.removeChildrenInArray(arr)
    }
}

private extension CGPoint {
    static func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDist = (p2.x - p1.x);
        let yDist = (p2.y - p1.y);
        return sqrt((xDist * xDist) + (yDist * yDist));
    }
}