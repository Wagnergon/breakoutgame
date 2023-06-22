import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    // Variable Declarations
    var ball = UIView()
    var paddle = UIView()
    var bricks = [UIView]()
    var brickCount = 0
    var brickColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue]
    var scoreLabel = UILabel()
    var score = 0
    var livesLabel = UILabel()
    var lives = 3
    var gameTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up game board
        let gameBoard = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        gameBoard.backgroundColor = UIColor.white
        view.addSubview(gameBoard)
        
        // Set up ball
        ball = UIView(frame: CGRect(x: view.frame.width/2 - 10, y: view.frame.height - 70, width: 20, height: 20))
        ball.layer.cornerRadius = 10
        ball.backgroundColor = UIColor.black
        gameBoard.addSubview(ball)
        
        // Set up paddle
        paddle = UIView(frame: CGRect(x: view.frame.width/2 - 50, y: view.frame.height - 40, width: 100, height: 10))
        paddle.backgroundColor = UIColor.gray
        gameBoard.addSubview(paddle)
        
        // Set up bricks
        brickCount = 0
        for i in 0...4 {
            for j in 0...3 {
                let brick = UIView(frame: CGRect(x: j*80 + 10, y: i*30 + 50, width: 70, height: 20))
                brick.backgroundColor = brickColors[i]
                brick.layer.cornerRadius = 5
                gameBoard.addSubview(brick)
                bricks.append(brick)
                brickCount += 1
            }
        }
        
        // Set up score label
        scoreLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 30)
        scoreLabel.font = UIFont.systemFont(ofSize: 18)
        scoreLabel.text = "Score: \(score)"
        gameBoard.addSubview(scoreLabel)
        
        // Set up lives label
        livesLabel.frame = CGRect(x: view.frame.width - 110, y: 10, width: 100, height: 30)
        livesLabel.font = UIFont.systemFont(ofSize: 18)
        livesLabel.textAlignment = NSTextAlignment.right
        livesLabel.text = "Lives: \(lives)"
        gameBoard.addSubview(livesLabel)
        
        // Set up game physics
        let animator = UIDynamicAnimator(referenceView: gameBoard)
        let collisionBehavior = UICollisionBehavior(items: [ball, paddle] + bricks)
        collisionBehavior.collisionDelegate = self
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        let ballBehavior = UIDynamicItemBehavior(items: [ball])
        ballBehavior.friction = 0
        ballBehavior.resistance = 0
        ballBehavior.elasticity = 1
        ballBehavior.allowsRotation = false
        let paddleBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleBehavior.allowsRotation = false
        animator.addBehavior(collisionBehavior)
        animator.addBehavior(ballBehavior)
        animator.addBehavior(paddleBehavior)
        
        // Set up game timer
        gameTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveBall), userInfo: nil, repeats: true)
    }
}
// MARK: - Game Logic Methods
func moveBall() {
    ball.center.x += dx
    ball.center.y += dy
    ballX = ball.center.x
    ballY = ball.center.y
    
    // Bounce off walls
    if ballX < ball.bounds.width / 2 || ballX > view.bounds.maxX - ball.bounds.width / 2 {
        dx = -dx
    }
    if ballY < ball.bounds.height / 2 {
        dy = -dy
    }
    
    // Bounce off paddle
    if ballY > paddle.frame.origin.y - ball.bounds.height / 2 {
        if ballX > paddle.frame.origin.x && ballX < paddle.frame.origin.x + paddle.frame.size.width {
            dy = -dy
            if ballX < paddle.frame.origin.x + paddle.frame.size.width / 3 {
                dx = -3
            } else if ballX < paddle.frame.origin.x + 2 * paddle.frame.size.width / 3 {
                dx = 0
            } else {
                dx = 3
            }
        } else {
            loseLife()
        }
    }
    
    // Bounce off bricks
    for row in bricks {
        for brick in row {
            if ballX > brick.frame.origin.x && ballX < brick.frame.origin.x + brick.frame.size.width &&
                ballY > brick.frame.origin.y && ballY < brick.frame.origin.y + brick.frame.size.height {
                dy = -dy
                brick.isHidden = true
                bricks = bricks.map {
                    $0.map {
                        $0 == brick ? UIView() : $0
                    }
                }
                score += 10
                scoreLabel.text = "Score: \(score)"
                if bricks.flatMap({$0}).isEmpty {
                    winGame()
                }
            }
        }
    }
}

func loseLife() {
    lives -= 1
    livesLabel.text = "Lives: \(lives)"
    if lives == 0 {
        endGame(message: "You lost!")
    } else {
        resetGame()
    }
}

func winGame() {
    endGame(message: "You won!")
}

func resetGame() {
    ball.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    paddle.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 20)
    dx = 0
    dy = 0
}

func endGame(message: String) {
    alert = UIAlertController(title: message, message: "Your score is \(score).", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
    resetGame()
    score = 0
    scoreLabel.text = "Score: \(score)"
    lives = 3
    livesLabel.text = "Lives: \(lives)"
    for row in bricks {
        for brick in row {
            brick.isHidden = false
        }
    }
}

// MARK: - Touch Handling Methods
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
        let touchLocation = touch.location(in: self.view)
        if touchLocation.x < view.bounds.midX {
            leftPressed = true
        } else {
            rightPressed = true
        }
    }
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    leftPressed = false
    rightPressed
