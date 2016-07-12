//
//  Level1.swift
//  Bubble Shooter
//
//  Created by sapir oded on 3/23/16.
//  Copyright © 2016 sapir oded. All rights reserved.
//

import SpriteKit
import AVFoundation

class Level : NSObject, SKPhysicsContactDelegate {
    let bubbleSize = CGFloat(33.6)
    private var scene : GameScene
    private var options = [""]
    private var downDelta : Int!
    private let rowDiff = 5
    private let minBubbles = 3
    private let pointsPerBubble = 5
    private var mtimer : NSTimer!
    
    private var startingIndex = 0 // First active row
    private var matrix : [[SKSpriteNode?]]
    private var positions : [[CGPoint?]]
    private var group = [SKSpriteNode]()
    private var firstIndeces : [CGPoint?]
    private var connected = [CGPoint]()
    private var numBubbles = 0
    private var levelNumber : Int!
    
    private var heightDeltaUp :CGFloat!
    private var heightDeltaDown :CGFloat!
    private var height : CGFloat!
    private var width : CGFloat!
    private var xGap : CGFloat!
    
    private let highScore : SKLabelNode
    private let pillar = SKSpriteNode(imageNamed: "pillar")
    let leftWall = SKSpriteNode(imageNamed: "wood")
    let rightWall = SKSpriteNode(imageNamed: "wood")
    let winPanel : SKSpriteNode
    let losePanel : SKSpriteNode
    
    var activeBubble : SKSpriteNode?
    
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
            rows += 1
            d -= bubbleSize
        }
        rows += 1
        
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
        
        highScore = SKLabelNode(fontNamed: "Ariel")
        highScore.text = "New high score!"
        highScore.fontColor = UIColor.redColor()
        highScore.position = CGPoint(x: self.width/2, y: self.height/2-50)
        highScore.fontSize = 20
        
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
            return
        }
        
        initBoard()
        startTimer()
    }
    
    private func level1() {
        options = ["bubble_3","bubble_4"]
        downDelta = 10

        for i in 0 ..< matrix.count/2+1 {
            if matrix.count/2-i <= 2 || matrix.count/2-i > 3 {
                matrix[i][0] = SKSpriteNode(imageNamed: options[0])
                matrix[matrix.count-i-1][0] = SKSpriteNode(imageNamed: options[0])
            } else {
                 matrix[i][0] = SKSpriteNode(imageNamed: options[1])
                matrix[matrix.count-i-1][0] = SKSpriteNode(imageNamed: options[1])
            }
        }
        
        for i in 0 ..< matrix.count {
            if fabs(CGFloat(matrix.count/2-i)) < 2 {
                matrix[i][1] = SKSpriteNode(imageNamed: options[1])
            } else if fabs(CGFloat(matrix.count/2-i)) == 2 {
                matrix[i][1] = SKSpriteNode(imageNamed: options[1])
            } else if fabs(CGFloat(matrix.count/2-i)) == 3 {
                 matrix[i][1] = SKSpriteNode(imageNamed: options[0])
            }
        }
        
        for i in 0 ..< matrix.count/2+1 {
            if matrix.count/2-i == 0 {
                matrix[i][2] = SKSpriteNode(imageNamed: options[1])
                matrix[matrix.count-i-1][2] = SKSpriteNode(imageNamed: options[1])
            } else if matrix.count/2-i < 4 {
                matrix[i][2] = SKSpriteNode(imageNamed: options[0])
                matrix[matrix.count-i-1][2] = SKSpriteNode(imageNamed: options[0])
            }
        }
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))-1][3] = SKSpriteNode(imageNamed: options[0])
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))][3] = SKSpriteNode(imageNamed: options[1])
        matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))+1][3] = SKSpriteNode(imageNamed: options[0])
    }
    
    private func level2() {
        options = ["bubble_3","bubble_4","bubble_5","bubble_6"]
        downDelta = 16
        
        for j in 0 ..< matrix[0].count/4 {
            matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))][j] = SKSpriteNode(imageNamed: options[1])
        }
        
        for j in matrix[0].count/4 ..< matrix[0].count/4+3 {
            matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))+1][j] = SKSpriteNode(imageNamed: options[3])
            
            if j%2 == 1 {
                matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))][j] = SKSpriteNode(imageNamed: options[3])
            } else {
                matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))-1][j] = SKSpriteNode(imageNamed: options[3])
                matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))][j] = SKSpriteNode(imageNamed: options[2])
            }
        }
        

        for j in 0 ..< 2 {
            matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))-1][j] = SKSpriteNode(imageNamed: options[0])
            matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))+2][j] = SKSpriteNode(imageNamed: options[0])
            if j == 0 {
                matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))-2][j] = SKSpriteNode(imageNamed: options[0])
                matrix[(Int)(CGFloat(matrix.count)/CGFloat(2))+1][j] = SKSpriteNode(imageNamed: options[0])
            }
        }
    }
    
    private func level3() {
        options = ["bubble_3","bubble_4",
            "bubble_5","bubble_6","bubble_7"]
        downDelta = 20
        
        for j in 0 ..< 6 {
            if j==2 {
                for k in 0 ..< j {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[1])
                    matrix[matrix.count-k-1][j] = SKSpriteNode(imageNamed: options[1])
                }
                
                for k in j ..< options.count {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[k])
                    matrix[matrix.count-k-1][j] = SKSpriteNode(imageNamed: options[k])
                }
                continue
            }
            
            if j == 3 {
                for k in 1 ..< j {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[2])
                    matrix[matrix.count-k][j] = SKSpriteNode(imageNamed: options[2])
                }
                
                for k in j ..< options.count {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[k])
                    matrix[matrix.count-k][j] = SKSpriteNode(imageNamed: options[k])
                }
                continue
            }
            
            if j == 4 {
                for k in 0 ..< j-1 {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[3])
                    matrix[matrix.count-k-1][j] = SKSpriteNode(imageNamed: options[3])
                }
                
                matrix[3][j] = SKSpriteNode(imageNamed: options[4])
                matrix[matrix.count-4][j] = SKSpriteNode(imageNamed: options[4])
                continue
            }
            
            if j == 5 {
                for k in 1 ..< j-1 {
                    matrix[k][j] = SKSpriteNode(imageNamed: options[4])
                    matrix[matrix.count-k][j] = SKSpriteNode(imageNamed: options[4])
                }
                continue
            }
            
            for k in 0 ..< options.count {
                matrix[k+1][j] = SKSpriteNode(imageNamed: options[k])
            }
            matrix[matrix.count-1][j] = SKSpriteNode(imageNamed: options[0])
            
            if j == 0 {
                matrix[0][j] = SKSpriteNode(imageNamed: options[0])
                for k in 0 ..< options.count {
                    matrix[matrix.count-k-2][j] = SKSpriteNode(imageNamed: options[k])
                }
            }
            
            if j == 1 {
                for k in 1 ..< options.count {
                    matrix[matrix.count-k-1][j] = SKSpriteNode(imageNamed: options[k])
                }
            }
        }
    }
    
    private func level4() {
        options = ["bubble_3","bubble_4",
            "bubble_5","bubble_6","bubble_7","bubble_8"]
        downDelta = 24
        
        for i in 0 ..< matrix.count/2+1 {
            if matrix.count/2-i <= 1 {
                matrix[i][0] = SKSpriteNode(imageNamed: options[5])
                matrix[matrix.count-i-1][0] = SKSpriteNode(imageNamed: options[5])
            }
        }
        
        for i in 0 ..< matrix.count/2+1 {
            if (matrix.count-1)%2 == 1 {
                if matrix.count/2-i == 0 {
                    matrix[i][1] = SKSpriteNode(imageNamed: options[5])
                } else if matrix.count/2-i == 1 {
                    matrix[i][1] = SKSpriteNode(imageNamed: options[4])
                    matrix[matrix.count-i][1] = SKSpriteNode(imageNamed: options[4])
                }
            } else {
                if matrix.count/2-i <= 1 {
                    matrix[i][1] = SKSpriteNode(imageNamed: options[5])
                    matrix[matrix.count-i-1][1] = SKSpriteNode(imageNamed: options[5])
                } else if matrix.count/2-i == 2 {
                    matrix[i][1] = SKSpriteNode(imageNamed: options[4])
                    matrix[matrix.count-i][1] = SKSpriteNode(imageNamed: options[4])
                }
            }
        }
        
        
    }
    
    private func startTimer() {
        mtimer = NSTimer.scheduledTimerWithTimeInterval(Double(downDelta), target: self, selector: #selector(Level.pushDown), userInfo: nil, repeats: true)
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
    
    private func addBubble(bubble: SKSpriteNode, index: CGPoint) {
        let copy = SKSpriteNode()
        copy.texture = bubble.texture
        copy.size = bubble.size
        copy.position = getPositionFromPoint(index)
        matrix[(Int)(index.x)][(Int)(index.y)] = copy
        scene.addChild(copy)
        numBubbles += 1
        print("ball added at (\((Int)(index.x)),\((Int)(index.y)))")
    }
    
    private func initBoard() {
        for i in 0 ..< matrix.count {
            for j in 0 ..< matrix[i].count {
                let bubble = matrix[i][j]
                if positions[i][j] == nil { // init positions
                    positions[i][j] = getPositionFromPoint(CGPoint(x: i, y: j))
                }
                if bubble != nil {
                    numBubbles += 1
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
    
    private func getPositionFromPoint(p: CGPoint) -> CGPoint {
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
                for i in 0 ..< matrix.count {
                    for j in startingIndex ..< matrix[i].count {
                        if matrix[i][j] != nil && CGPoint.distance(pos, p2: matrix[i][j]!.position) <= bubbleSize+1 {
                            collided(index!, dir: dir)
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func collided(index: CGPoint, dir: CGVector) {
        var index1 = index
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
            index1 = i!
        }
        
        if index.y%2 == 1 && index.x == 0 {
            index1.y++
        }
        
        let audioFileUrl = NSURL.fileURLWithPath(scene.hit!)
        do {
            try scene.audioPlayer = AVAudioPlayer(contentsOfURL: audioFileUrl)
            scene.audioPlayer.play()
        }
        catch {
            print("Error playing hit sound")
        }

        addBubble(activeBubble!, index: index1)
        scene.endShoot()
        
        group.removeAll()
        checkNeighbors(matrix[(Int)(index1.x)][(Int)(index1.y)]!, index: index1)
        
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
            
            for i in 0 ..< group.count {
                let animation = SKAction.moveToY(0, duration: 1)
                let doneAction = (SKAction.runBlock({
                    if self.group.count > 0 {
                        self.scene.removeChildrenInArray(self.group)
                        self.group.removeAll()
                        self.scene.canShoot = true
                    }
                }))
                let sequence = (SKAction.sequence([animation, doneAction]))
                group[i].runAction(sequence)
            }
            
            if numBubbles <= 0 { // Win
                winLose(true)
            }
        } else { // Return the bubbles
            for i in 0 ..< firstIndeces.count {
                if firstIndeces[i] != nil {
                    let x = (Int)(firstIndeces[i]!.x)
                    let y = (Int)(firstIndeces[i]!.y)
                    matrix[x][y] = group[i]
                }
            }
            group.removeAll()
            scene.canShoot = true
        }
        
        for i in 0 ..< firstIndeces.count {
            firstIndeces[i] = nil
        }
        
        activeBubble = nil
        checkLose()
    }
    
    private func positionIndex(pos: CGPoint) -> CGPoint? {
        for i in 0 ..< positions.count {
            for j in startingIndex ..< positions[i].count {
                let rect = CGRect(x: positions[i][j]!.x - bubbleSize/2, y: positions[i][j]!.y - bubbleSize/2, width: bubbleSize, height: bubbleSize)
                if(CGRectContainsPoint(rect, pos)) {
                    return CGPoint(x: i,y: j)
                }
            }
        }
        
        return nil
    }
    
    private func checkNeighbors(root: SKSpriteNode, index: CGPoint) {
        let col = (Int)(index.x)
        let row = (Int)(index.y)
        let color = root.texture?.description
        var bubble : SKSpriteNode?
        
        if !group.contains(root) {
            group.append(root)
            matrix[col][row] = nil
            
            // Saving the first indeces to return the bubbles to their place if there are not enough buubles
            for i in 0 ..< firstIndeces.count {
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
    
    private func checkFalls() {
        var flags = [[Bool]](count: matrix.count, repeatedValue: [Bool](count: matrix[0].count, repeatedValue: false))
        connected.removeAll()
        
        for i in 0 ..< matrix.count {
            if matrix[i][startingIndex] != nil {
                connections(CGPoint(x: i, y: startingIndex))
                for j in 0 ..< connected.count {
                    let x = (Int)(connected[j].x)
                    let y = (Int)(connected[j].y)
                    flags[x][y] = true
                }
            }
        }
        
        for i in 0 ..< flags.count {
            for j in 0 ..< flags[i].count {
                if matrix[i][j] != nil && !flags[i][j] { // Bubble is not connected
                    group.append(matrix[i][j]!)
                    matrix[i][j] = nil
                }
            }
        }
    }
    
    private func connections(index: CGPoint) {
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
            while !self.scene.canShoot {} // Wait for shooting to end
            self.scene.canShoot = false
            self.pillar.position.y = self.positions[0][self.startingIndex+1]!.y-self.bubbleSize/2
            for i in 0 ..< self.matrix.count {
              //  for var j=self.matrix[i].count-1;j>=self.startingIndex;j-=1
                for j in (self.startingIndex...self.matrix[i].count-1).reverse() {
                    if j-self.startingIndex < 2 {
                        if self.matrix[i][j] != nil {
                            self.matrix[i][j] = nil
                        }
                    } else {
                        if self.matrix[i][j-2] != nil {
                            self.matrix[i][j] = self.matrix[i][j-2]
                            self.matrix[i][j]!.position = self.positions[i][j]!
                            self.matrix[i][j-2] = nil
                        }
                    }
                }
            }
            
            self.startingIndex+=2
            
            self.checkLose()
            self.scene.canShoot = true
        })
    }
    
    private func checkLose() {
        for i in 0 ..< matrix.count {
            if matrix[i][matrix[i].count-2] != nil {
                winLose(false)
                break
            }
        }
    }
    
    private func winLose(win: Bool) {
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
            
            let scoresDB = Scores.getInstance()
            let previousScore = scoresDB.loadLevelScore(levelNumber)
            
            if scene.score > previousScore { // New high score
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    scoresDB.update(self.levelNumber, s: self.scene.score)
                })
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC) * 1250), dispatch_get_main_queue(), {
                    self.showHighScore()
                })
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
    
    private func showHighScore() {
        scene.addChild(highScore)
        let growAction = SKAction.scaleBy(1.3, duration: 1)
        let doneAction = (SKAction.runBlock({
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 2), dispatch_get_main_queue(), {
               self.highScore.removeFromParent()
            })
        }))
        let sequence = (SKAction.sequence([growAction, doneAction]))
        highScore.runAction(sequence)
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
        for i in 0 ..< matrix.count {
            for j in 0 ..< matrix[i].count {
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