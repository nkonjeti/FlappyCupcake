

import SpriteKit

struct PhysicsCategory {
    static let Cupcake : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    var Ground = SKSpriteNode()
    var Cupcake = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        print(UIFont.familyNames())


        self.physicsWorld.contactDelegate = self
        for i in 0..<3 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width , 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 +  self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 60
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Cupcake
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Cupcake
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        Cupcake = SKSpriteNode(imageNamed: "Cupcake")
        Cupcake.size = CGSize(width: 60, height: 60)
        Cupcake.position = CGPoint(x: self.frame.width/2 - Cupcake.frame.width, y: self.frame.height/2)
        
        Cupcake.physicsBody = SKPhysicsBody(circleOfRadius: Cupcake.frame.height/2)
        Cupcake.physicsBody?.categoryBitMask = PhysicsCategory.Cupcake
        Cupcake.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Cupcake.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Cupcake.physicsBody?.affectedByGravity = false
        Cupcake.physicsBody?.dynamic = true
        Cupcake.zPosition = 2
        
        self.addChild(Cupcake)
        

        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        createScene()
        
        
        
        
    }
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed:"RestartBTN")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Cupcake || firstBody.categoryBitMask == PhysicsCategory.Cupcake && secondBody.categoryBitMask == PhysicsCategory.Score{
            
            score += 1
            scoreLbl.text = "\(score)"
            
        } else if firstBody.categoryBitMask == PhysicsCategory.Cupcake && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Cupcake {
            
            
            enumerateChildNodesWithName("wallPair", usingBlock:({
                (node,error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                createBTN()
            }
            
            
        } else if firstBody.categoryBitMask == PhysicsCategory.Cupcake && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Cupcake {
            

            
            enumerateChildNodesWithName("wallPair", usingBlock:({
                (node,error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                createBTN()
            }
            
            
        }
    
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            gameStarted = true
            
            Cupcake.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
            })
            let delay = SKAction.waitForDuration(1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width + 200)
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.007 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Cupcake.physicsBody?.velocity = CGVectorMake(0, 0)
            Cupcake.physicsBody?.applyImpulse(CGVectorMake(0,65))
            
        } else {
            
            if died == true{
                
                
            } else {
                Cupcake.physicsBody?.velocity = CGVectorMake(0, 0)
                Cupcake.physicsBody?.applyImpulse(CGVectorMake(0,65))
            }
            
            
        }
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                }
                
            }
        }
    }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height/2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Cupcake
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 + 350)
        btmWall.position = CGPoint(x: self.frame.width, y: self.frame.height/2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Cupcake
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cupcake
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Cupcake
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cupcake
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        var randomPosition = CGFloat.random(min: -90, max: 175)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if gameStarted == true{
            if died == false{
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 3, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2 , bg.position.y)
                    }
                }))
            }
        }
    }
}
