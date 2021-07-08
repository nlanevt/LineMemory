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
    @IBOutlet weak var QuitGameButton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    
    private weak var game_scene: GameScene?;
    private var gameScenePaused:Bool = false;
    private weak var game_view: SKView?;
    
    private var starting_score:Int64 = 0;
    private var starting_level:Int64 = 1;
    
    deinit {
        //print("Game View Controller has been deallocated");
    }
    
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
        
        game_scene = GameScene(fileNamed: "GameScene");
        // Set the scale mode to scale to fit the window
        game_scene?.scaleMode = .aspectFit
        game_scene?.view_controller = self;
        game_scene?.setStartingValues(starting_level: starting_level, starting_score: starting_score)
        
        game_view = (self.view as! SKView);
        game_view?.presentScene(game_scene)
        game_view?.preferredFramesPerSecond = 60;
        game_view?.ignoresSiblingOrder = true
        //game_view?.showsFPS = true
        //game_view?.showsNodeCount = true
        
        setUpStringLocalization()
    }

    @IBAction func QuitGameButton(_ sender: Any) {
        returnToMenu();
        menu_view_controller.showAd();
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
        game_scene?.isPaused = gameScenePaused;
        if (gameScenePaused) {return};
        game_scene?.refreshRound();
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
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.alpha = 0.0;
        }, completion: {[weak self] (a: Bool) in
            self?.QuitGameButton.alpha = 0.0;
            self?.ContinueButton.alpha = 0.0;
            self?.game_scene?.deallocateContent();
            self?.game_scene?.removeAllChildren();
            self?.game_scene?.removeFromParent();
            self?.game_scene = nil;
            self?.navigationController?.popToRootViewController(animated: true);
            self?.removeFromParentViewController();
            self?.game_view?.removeFromSuperview();
            self?.game_view = nil;
        })
    }
    
    public func hidePauseView() {
        if (!gameScenePaused) {return};
        gameScenePaused = false;
        game_scene?.isPaused = false;
        game_scene?.refreshRound();
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
        game_scene?.isPaused = true;
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
    
    private func setUpStringLocalization() {
        QuitGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontNameA", comment: "")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize24", comment: "")) as NSString).floatValue));
        ContinueButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontNameA", comment: "")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize24", comment: "")) as NSString).floatValue));
    }
    
    public func setStartingValues(starting_level: Int64, starting_score: Int64) {
        self.starting_score = starting_score;
        self.starting_level = starting_level;
    }
}
