//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Ben Vest on 2/4/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

protocol BreakoutBehaviorDelegate: class {
    func gameOver(playerWon: Bool)
    func resetBall(ball: UIView)
    func setScore(score: Int)
    func setDeath(deaths: Int)
}

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    let settings = NSUserDefaults.standardUserDefaults()
    
    var prevBallSpeed = [CGPoint]()
    var bricks = [String: UIView!]()
    var score = 0
    var deathCnt = 0
    
    weak var breakoutBehaviorDelegate: BreakoutBehaviorDelegate?
    
    //MARK: Collision Delegation
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if identifier != nil {
            if let iden = (identifier! as? String) {
                switch iden {
                case "Paddle":
                    let ran = Int.random(-200, max: 200)
                    if ballBehavior.linearVelocityForItem(item).y < -500 {
                        ballBehavior.addLinearVelocity(CGPoint(x: ran, y: 300), forItem: item)
                    } else {
                        ballBehavior.addLinearVelocity(CGPoint(x: ran, y: -150), forItem: item)
                    }
                case "Bottom":
                    breakoutBehaviorDelegate?.resetBall((item as? UIView)!)
                    breakoutBehaviorDelegate?.setDeath(deathCnt++)
                default:break
                }
            }

        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if identifier != nil {
            if let iden = (identifier! as? String) {
                if let brick = bricks[iden] {
                    if brick.backgroundColor != UIColor.blueColor(){
                        if brick.alpha > 0.25 {
                            brick.alpha -= 0.25
                        } else {
                            animateBrick(brick, iden: iden, scoreInc: 2, option: .TransitionFlipFromBottom)
                        }
                    } else {
                        animateBrick(brick, iden: iden, scoreInc: 1, option: .TransitionCurlUp)
                    }
                } else if bricks.isEmpty {
                    breakoutBehaviorDelegate?.gameOver(true)
                }
            }
        }
    }
    
    var hitBricks = [UIView!]()
        
    func animateBrick(brick: UIView!, iden: String, scoreInc: Int, option: UIViewAnimationOptions) {
        if !hitBricks.contains({$0 === brick}) {
            hitBricks.append(brick)
            score += scoreInc
            
            UIView.transitionWithView(brick,
                duration: 1.0,
                options: UIViewAnimationOptions.TransitionCurlUp,
                animations: { brick.alpha = 0.0 },
                completion: { (success) -> Void in
                    if success {
                        self.removeBrick(brick, name: iden)
                        self.collider.removeBoundaryWithIdentifier(iden)
                        self.breakoutBehaviorDelegate?.setScore(self.score)
                        if self.bricks.isEmpty {
                            self.breakoutBehaviorDelegate?.gameOver(true)
                        }
                    }
            })
        }
    }

    //MARK: Behaviors
    //lazy here to allow for configuration in the initializer
    lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        gravity.magnitude = 0.05
        return gravity
    }()
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        lazilyCreatedCollider.collisionDelegate = self
        return lazilyCreatedCollider
    }()
    
    lazy var paddleBehavior: UIDynamicItemBehavior = {
        let lazyPaddleBehavior = UIDynamicItemBehavior()
        lazyPaddleBehavior.allowsRotation = false
        lazyPaddleBehavior.elasticity = 1.0
        lazyPaddleBehavior.density = 100000
        return lazyPaddleBehavior
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = false
        lazyBallBehavior.elasticity = self.getBallElasticity()
        lazyBallBehavior.resistance = 0.0
        lazyBallBehavior.friction = 0.0
        return lazyBallBehavior
    }()
    
    //MARK: Init
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(paddleBehavior)
    }
    
    //get the elasticity from settings
    func getBallElasticity() -> CGFloat {
        let elasticity = settings.floatForKey("ballBounciness")
        return CGFloat(elasticity)
    }
    
    //MARK: Pause and Resume
    func pauseGame(balls: [UIView!]){
        for ball in balls {
            let currentVel = ballBehavior.linearVelocityForItem(ball)
            prevBallSpeed.append(currentVel)
            gravity.removeItem(ball)
            ballBehavior.addLinearVelocity(CGPoint(x: -currentVel.x, y: -currentVel.y), forItem: ball)
        }
    }
    
    func resumeGame(balls: [UIView!]){
        var num = 0
        for ball in balls {
            if prevBallSpeed.count == balls.count {
                ballBehavior.addLinearVelocity(prevBallSpeed[num], forItem: ball)
                gravity.addItem(ball)
            } else {
                ballBehavior.addLinearVelocity(CGPoint(x: 25 + num * 5, y: 250), forItem: ball)
            }
            
            num++
        }
        
        prevBallSpeed.removeAll()
    }
    
    func startBalls(balls: [UIView!]){
        for ball in balls {
            gravity.addItem(ball)
            ballBehavior.addLinearVelocity(CGPoint(x: 25, y: 250), forItem: ball)
        }
    }
    
    func pushBall(ball: UIView){
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        
        push.setAngle(CGFloat(arc4random() % 6), magnitude: 0.05)
        
        push.action = { [unowned push] in
            push.dynamicAnimator!.removeBehavior(push)
        }
        
        addChildBehavior(push)
    }
    
    //MARK: Add Items
    //add the views and behaviors for the Brick
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addPaddle(paddle: UIView) {
        dynamicAnimator?.referenceView?.addSubview(paddle)
        paddleBehavior.addItem(paddle)
    }
    
    func addBall(ball: UIView){
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func addBrick(brick: UIView, name: String) {
        dynamicAnimator?.referenceView?.addSubview(brick)
        bricks[name] = brick
    }
    
    //MARK: Remove Items
    func removeBarrier(name: String) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
    func removeBrick(brick: UIView, name: String) {
        bricks.removeValueForKey(name)
        removeBarrier(name)
        brick.removeFromSuperview()
    }
    
    func removePaddle(paddle: UIView) {
        paddleBehavior.removeItem(paddle)
        paddle.removeFromSuperview()
    }
    
    func removeBall(ball: UIView){
        ballBehavior.removeItem(ball)
        collider.removeItem(ball)
        gravity.removeItem(ball)
        ball.removeFromSuperview()
    }
}
