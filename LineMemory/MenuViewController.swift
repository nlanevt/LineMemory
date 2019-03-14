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


var menu_view_controller:MenuViewController!;

class MenuViewController: UIViewController {
    
    private var highest_score:Int64 = 0;
    private var highest_level:Int = 0;
    private var did_beat_game = false;
    
    @IBAction func StartGameButton(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController;
        self.navigationController?.pushViewController(gameVC, animated: true)
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
        
        menu_view_controller = self;
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

    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {

    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        
    }
    
    public func setNewHighScore(new_high_score: Int64) {
        highest_score = new_high_score;
    }
    
    public func setNewHighestLevel(new_highest_level: Int) {
        highest_level = new_highest_level;
    }
    
    public func playerBeatGame(did_player_beat_game: Bool) {
        did_beat_game = did_player_beat_game;
    }
    
    public func wasGameBeaten() -> Bool {
        return did_beat_game;
    }
    
    public func getHighestScore() -> Int64 {
        return highest_score;
    }
    
    public func getHighestLevel() -> Int {
        return highest_level;
    }
    
    public func save_data() {
        
    }
    
    public func deleteCoreData() {
        
    }
    
    public func loadScores() {
        
    }
    
}
