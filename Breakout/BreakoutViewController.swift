//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Ben Vest on 2/4/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, BreakoutBehaviorDelegate {
  private var paddle: UIView!
  private var balls = [UIView!]()
  private var bricks = [UIView!]()
  private var lastBrickView: UIView!
    
  let breakoutBehavior = BreakoutBehavior()
  let settings = NSUserDefaults.standardUserDefaults()
    
  var num = 0
  var paused = false
  var gameStarted = false
    
  struct Constants {
    static let NumberOfRows = 2
    static let BrickHeight: CGFloat = 25
    static let PaddleHeight: Int = 25
    static let PaddleWidth: Int = 100
  }
    
  lazy var animator: UIDynamicAnimator = {
    let lazyAnimator = UIDynamicAnimator(referenceView: self.breakoutView)
    lazyAnimator.delegate = self
    return lazyAnimator
  }()

  var special: Bool {
    get{
      if settings.boolForKey("specialBricks") {
        return true
      } else {
        return false
      }
    }
  }

  var bricksPerRow: Int {
    get{
      if settings.integerForKey("bricksPerRow") > 0 {
        return settings.integerForKey("bricksPerRow")
      } else {
        return 10
      }
    }
  }

  var numberOfBalls: Int {
    get{
      if settings.integerForKey("numberOfBalls") > 0 {
        return settings.integerForKey("numberOfBalls")
      } else {
        return 1
      }
    }
  }

  private var brickSize: CGSize {
    let size = (breakoutView.bounds.size.width - CGFloat(bricksPerRow) ) / CGFloat(bricksPerRow)
    return CGSize(width: size, height: Constants.BrickHeight)
  }

  //MARK: Outlets
  @IBOutlet weak var breakoutView: UIView! {
    didSet {
      breakoutBehavior.breakoutBehaviorDelegate = self
    }
  }

  @IBOutlet weak var deathLabel: UIBarButtonItem!
  @IBOutlet weak var scoreLabel: UIBarButtonItem!

  @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Began:fallthrough
    case .Ended:break
    case .Changed:
        let translation = sender.translationInView(breakoutView)
        let newX = paddle.center.x + translation.x

        if  newX > paddle.bounds.size.width / 2 && newX < breakoutView.bounds.maxX - paddle.bounds.size.width / 2 {
            paddle.center.x = newX
            breakoutBehavior.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: 20), named: "Paddle") // change to constant name
            animator.updateItemUsingCurrentState(paddle!)
        }
        
        sender.setTranslation(CGPointZero, inView: breakoutView)
    default: break
    }
  }

  @IBAction func moveBall(sender: UITapGestureRecognizer) {
    switch sender.state {
    case .Ended:
        for ball in balls {
            breakoutBehavior.pushBall(ball)
        }
    default: break
    }
  }

  //MARK: Application Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    animator.addBehavior(breakoutBehavior)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if settings.boolForKey("settingsChanged") {
        removeLayout()
        layoutGame()
        settings.setBool(false, forKey: "settingsChanged")
        showAlert("Paused")
    }else if paused {
        showAlert("Paused")
    } else if !gameStarted {
        layoutGame()
        showAlert("Main")
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    paused = true
    breakoutBehavior.pauseGame(balls)
  }

  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    removeLayout()
    layoutGame()
  }

  func showAlert(toShow: String) {
    switch toShow {
    case "Paused":
      let alert = UIAlertController(title: "Game Paused", message: "Game state changed", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Play", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) -> Void in
          self.breakoutBehavior.resumeGame(self.balls)
          self.paused = false
      }))
      presentViewController(alert, animated: true, completion: nil)
    case "Main":
      let alert = UIAlertController(title: "Welcome to Breakout", message: "Destroy all Bricks", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Go To Settings", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
          self.tabBarController?.selectedIndex = 1
      }))
      alert.addAction(UIAlertAction(title: "Start Game", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
          self.breakoutBehavior.startBalls(self.balls)
          self.paused = false
          self.gameStarted = true
      }))
      presentViewController(alert, animated: true, completion: nil)
    case "Won":
      let alert = UIAlertController(title: "Congrats You Win", message: "All the bricks have been destroyed", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) -> Void in
          self.paused = false
          self.restartGame()
      }))
      presentViewController(alert, animated: true, completion: nil)
    default: break
    }
  }

  // MARK: Layout Game Functions
  func addBrickToLayout(brickLoc: CGPoint, color: UIColor) -> UIView{
    let frame = CGRect(origin: brickLoc, size: brickSize)
    let brickView = UIView(frame: frame)
    brickView.backgroundColor = color
    bricks.append(brickView)

    let path = UIBezierPath(rect: brickView.frame)
    breakoutBehavior.addBarrier(path, named: "brick\(num)")

    return brickView
  }

  func addBallsToLayout() {
    for aBall in 1...numberOfBalls{
      let ballSize = CGSize(width: 10, height: 10)
      let frame = CGRect(origin: CGPoint(x: paddle.frame.midX - CGFloat(5 * aBall), y: paddle.frame.midY - 25), size: ballSize)
      let ballView = UIView(frame: frame)
      
      ballView.backgroundColor = UIColor.blackColor()
      
      balls.append(ballView)
      breakoutBehavior.addBall(ballView)
    }
  }

  func addPaddleToLayout() {
    let paddleSize = CGSize(width: Constants.PaddleWidth, height: Constants.PaddleWidth)
    let frame = CGRect(origin: CGPoint(x: breakoutView.bounds.midX - paddleSize.width/2, y: breakoutView.bounds.midY + breakoutView.bounds.midY/2), size: paddleSize)
    let paddleView = UIView(frame: frame)
    paddleView.backgroundColor = UIColor.redColor()
    let path = UIBezierPath(rect: paddleView.frame)
    paddle = paddleView
    breakoutBehavior.addBarrier(path, named: "Paddle")
    breakoutBehavior.addPaddle(paddleView)
  }

  func layoutGame() {
    let bottom = UIBezierPath()

    bottom.moveToPoint(CGPoint(x: breakoutView.bounds.origin.x, y: breakoutView.frame.size.height))
    bottom.addLineToPoint(CGPoint(x: breakoutView.frame.maxX, y: breakoutView.frame.size.height))
    
    breakoutBehavior.addBarrier(bottom, named: "Bottom")

    layoutBricks()
    addPaddleToLayout()
    addBallsToLayout()
  }

  func layoutBricks() {
    let horizontalSeperation: CGFloat = ((breakoutView.bounds.size.width - (brickSize.width * CGFloat(bricksPerRow))) / CGFloat(bricksPerRow))
    let verticalSeperation = Int(Constants.BrickHeight + 3)
    var specialBrickIndexes = [Int]()
    num = 0
      
      
    if special {
      var x = 0
      while x < (Constants.NumberOfRows * bricksPerRow) {
          x += Int.random(1, max: 5)
          specialBrickIndexes.append(x)
      }
    }
      
    for row in 1...Constants.NumberOfRows {
      let brickOriginY = row * verticalSeperation
      var brickOriginX = CGFloat(0.25)
          
      for _ in 1...bricksPerRow {
        if special {
          if specialBrickIndexes.contains(num) {
            lastBrickView = addBrickToLayout(CGPoint(x: brickOriginX, y: CGFloat(brickOriginY)), color: UIColor.random)
          } else {
            lastBrickView = addBrickToLayout(CGPoint(x: brickOriginX, y: CGFloat(brickOriginY)), color: UIColor.blueColor())
          }
        } else {
            lastBrickView = addBrickToLayout(CGPoint(x: brickOriginX, y: CGFloat(brickOriginY)), color: UIColor.blueColor())
        }
              
        breakoutBehavior.addBrick(lastBrickView, name: "brick\(num)")
            
        brickOriginX += lastBrickView.bounds.maxX + horizontalSeperation
              
        num++
      }
    }
  }

  func removeLayout() {
    if paddle != nil{
        breakoutBehavior.removePaddle(paddle)
    }
    removeAllBalls()
    var brNum = 0
    for brick in bricks {
        breakoutBehavior.removeBrick(brick, name: "brick\(brNum)")
        brNum++
    }
  }

  func removeAllBalls() {
    for ball in balls {
        breakoutBehavior.removeBall(ball)
    }
  
    balls.removeAll()
  }

  func restartGame() {
    removeLayout()
    layoutGame()
  
    if !paused {
        breakoutBehavior.startBalls(balls)
    }
  }

  var ballsRemoved = 1

  func resetBall(ball: UIView) {
    if numberOfBalls > 1 && ballsRemoved != numberOfBalls{
      ballsRemoved++
      balls.removeAtIndex(balls.indexOf({$0 === ball})!)
      breakoutBehavior.removeBall(ball)
    } else if numberOfBalls == 1 || ballsRemoved == numberOfBalls {
      ballsRemoved = 1
      removeAllBalls()
      addBallsToLayout()
      if !paused {
        breakoutBehavior.startBalls(balls)
      }
    }
  }

  func gameOver(playerWon: Bool) {
    if playerWon {
        breakoutBehavior.pauseGame(balls)
        self.paused = true
        self.gameStarted = false
        showAlert("Won")
    }
  }

  func setScore(score: Int) {
    scoreLabel.title = "Score:  \(score)"
  }

  func setDeath(deaths: Int) {
    deathLabel.title = "Deaths:  \(deaths)"
  }
}

  //MARK: Extensions
private extension CGFloat {
  static func random(max: Int) -> CGFloat {
    return CGFloat(arc4random() % UInt32(max))
  }
}

private extension UIColor {
  class var random: UIColor {
    switch arc4random()%5 {
    case 0: return UIColor.greenColor()
    case 1: return UIColor.blueColor()
    case 2: return UIColor.orangeColor()
    case 3: return UIColor.redColor()
    case 4: return UIColor.purpleColor()
    default: return UIColor.blackColor()
    }
  }
}

public extension Int {
  /// Returns a random Int point number between 0 and Int.max.
  public static var random: Int {
    get {
        return Int.random(Int.max)
    }
  }

  public static func random(n: Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
  }

  public static func random(min: Int, max: Int) -> Int {
    return Int.random(max - min + 1) + min
    //Int(arc4random_uniform(UInt32(max - min + 1))) + min }
  }
}
