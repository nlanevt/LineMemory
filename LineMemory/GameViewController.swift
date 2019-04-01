//
//  GameViewController.swift
//  Concord
//
//  Created by Nathan Lane on 1/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {


    @IBOutlet weak var PauseView: UIView!;
    
    private var game_scene:GameScene!;
    private var gameScenePaused:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(notification:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(notification:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(notification:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        // Conceal the Pause View
        PauseView.isHidden = true;
        PauseView.alpha = 0.0;
        
        print("highest Score: \(menu_view_controller.getHighestScore()), highest level: \(menu_view_controller.getHighestLevel())");
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                // Copy gameplay related content over to the scene
                game_scene = sceneNode;
                // Set the scale mode to scale to fit the window
                game_scene.scaleMode = .aspectFill
                game_scene.view_controller = self;
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(game_scene)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }

    @IBAction func QuitGameButton(_ sender: Any) {
        returnToMenu();
    }
    
    @IBAction func ContinueGameButton(_ sender: Any) {
        hidePauseView();
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        game_scene.isPaused = gameScenePaused;
        if (gameScenePaused) {return};
        game_scene.refreshRound();
        print("applicationDidBecomeActive");
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        if (gameScenePaused) {return};
        self.showPauseView();
        print("applicationDidEnterBackground");
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
       
        if (gameScenePaused) {return};
        self.showPauseView();
         print("applicationWillResignActive");
    }
    
    public func returnToMenu() {
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    public func hidePauseView() {
        if (!gameScenePaused) {return};
        
        gameScenePaused = false;
        game_scene.isPaused = false;
        game_scene.refreshRound();
        UIView.animate(withDuration: 0.25, animations: {
            self.view.viewWithTag(100)?.alpha = 0.0;
            self.PauseView.alpha = 0.0;
        }) { _ in
            self.view.viewWithTag(100)?.removeFromSuperview();
        }
        PauseView.isHidden = true;
    }
    
    public func showPauseView() {
        if (gameScenePaused) {return};
        
        gameScenePaused = true;
        game_scene.isPaused = true;
        PauseView.isHidden = false;
        PauseView.alpha = 0.0;
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.tag = 100;
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0.0;
        self.view.insertSubview(blurEffectView, at: 0)
        NSLayoutConstraint.activate([
            blurEffectView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            blurEffectView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ]);
        UIView.animate(withDuration: 0.25, animations: {
            blurEffectView.alpha = 1.0;
            self.PauseView.alpha = 1.0
        });
    }
}
