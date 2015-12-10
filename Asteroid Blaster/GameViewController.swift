//
//  GameViewController.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/1/15.
//  Copyright (c) 2015 Brandon Groff. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGame", name: "pauseGame", object: nil)

        let skView: SKView = self.view as! SKView
//        let myScene = GameScene(size: skView.frame.size)
        let myScene = MainScreen(size: skView.frame.size)
        skView.presentScene(myScene)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
