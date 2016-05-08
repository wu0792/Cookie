//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by wu0792Mac on 16/5/3.
//  Copyright (c) 2016年 wu0792Mac. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    var curLevel: Int = 1
    var succ:Bool = false
    
    var movesLeft = 0
    var score = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    lazy var backgroundMusic: AVAudioPlayer! = {
        do{
            let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
            let player = try AVAudioPlayer(contentsOfURL: url!)
            player.numberOfLoops = -1
            return player
        }catch{
            return nil
        }
    }()
    
    @IBAction func shuffleButtonPressed(_: AnyObject) {
        shuffle()
        decrementMoves()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameOverPanel.hidden = true
        shuffleButton.hidden = true
        
        backgroundMusic.play()
        
        initLevel()
        beginGame()
    }
    
    func initLevel(){
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        level = Level(filename: "Level_\(curLevel)")
        scene.level = level
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        shuffle()
    }
    
    func shuffle() {
        scene.removeAllCookieSprites()
        scene.removeAllTiles()
        
        scene.addTiles()
        
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            //scene.animateSwap(swap, completion: handleMatches)
            scene.animateSwap(swap) {
                self.handleMatches()
                self.view.userInteractionEnabled = true
            }
        } else {
            scene.animateInvalidSwap(swap){
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count > 0 {
            scene.animateMatchedCookies(chains) {
                for chain in chains {
                    self.score += chain.score
                }
                self.updateLabels()
                
                let columns = self.level.fillHoles()
                self.scene.animateFallingCookies(columns) {
                    let columns = self.level.topUpCookies()
                    self.scene.animateNewCookies(columns) {
                        self.handleMatches()
                        self.view.userInteractionEnabled = true
                    }
                }
            }
        }
        else{
            beginNextTurn()
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        decrementMoves()
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        
        if score >= level.targetScore {
            succ = true
            gameOverPanel.image = UIImage(named: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            succ = false
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
        
        shuffleButton.hidden = true
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        if(succ){
            curLevel++
        }
        
        if(curLevel > 4){
            curLevel = 1
        }
        
        initLevel()
        beginGame()
    }
    
}











