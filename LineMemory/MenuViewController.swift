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
import CoreData
import GameKit

var menu_view_controller:MenuViewController!;
var animation_frames_manager = AnimationFramesHelper();

class MenuViewController: UIViewController, GKGameCenterControllerDelegate {
    private var menu_scene:MenuScene!;
    private var highest_score:Int64 = 0;
    private var highest_level:Int64 = 0;
    private var did_beat_game = false;
    private var player:NSManagedObject? = nil;
    private var players:[NSManagedObject] = [];
    private var max_level:Int64 = 256;
    
    /* Variables */
    private var gcEnabled = Bool() // Check if the user has Game Center enabled
    private var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    private let LEADERBOARD_HIGHESTSCORE_ID = "com.linememory.highestscore"
    private let LEADERBOARD_HIGHESTLEVEL_ID = "com.linememory.highestlevel"
    
    private var delete_core_data = false;
    
    @IBAction func StartGameButton(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController;
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScores();
        authenticateLocalPlayer();
        menu_view_controller = self;
        
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
        
        // Load 'MenuScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "MenuScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MenuScene? {
                // Copy gameplay related content over to the scene
                menu_scene = sceneNode;
                // Set the scale mode to scale to fit the window
                menu_scene.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(menu_scene)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    @IBAction func CheckLeaderboard(_ sender: Any) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .default;
        present(gcVC, animated: true, completion: nil)
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
        addHighestScoreToLeaderBoard(score: highest_score);
    }
    
    public func setNewHighestLevel(new_highest_level: Int64) {
        highest_level = new_highest_level;
        addHighestLevelToLeaderBoard(level: highest_level)
    }
    
    public func playerBeatGame(did_player_beat_game: Bool) {
        did_beat_game = did_player_beat_game;
        //addHighestLevelToLeaderBoard(level: max_level)
    }
    
    public func wasGameBeaten() -> Bool {
        return did_beat_game;
    }
    
    public func getHighestScore() -> Int64 {
        return highest_score;
    }
    
    public func getHighestLevel() -> Int64 {
        return highest_level;
    }
    
    public func save_data() {
        save(highest_score: highest_score, highest_level: highest_level);
    }
    
    public func deleteCoreData() {
        if (!players.isEmpty)
        {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            
            for index in 0 ..< players.count
            {
                managedContext.delete(players[index])
            }
            
            players.removeAll();
            
            do {
                try managedContext.save()
            } catch _ {
            }
        }
    }
    
    public func loadScores() {
        if (delete_core_data) {
            deleteCoreData();
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Player")
        
        //3
        do {
            players = try managedContext.fetch(fetchRequest);
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // If there are no records in Core Data for the player yet, create one.
        if (players.isEmpty)
        {
            highest_score = 0;
            highest_level = 0;
            save(highest_score: highest_score, highest_level: highest_level)
        }
        else if (players.count > 1) // if there is for some reason more than one record
        {
            player = players.last;
            highest_score = (player?.value(forKeyPath: "highest_score") as? Int64)!;
            highest_level = (player?.value(forKeyPath: "highest_level") as? Int64)!;
            deleteCoreData();
            save(highest_score: highest_score, highest_level: highest_level)
            loadScores();
        }
        else
        {
            player = players.last;
            highest_score = (player?.value(forKeyPath: "highest_score") as? Int64)!;
            highest_level = (player?.value(forKeyPath: "highest_level") as? Int64)!;
        }
    }
    
    private func save(highest_score: Int64, highest_level: Int64) {
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Player", in: managedContext)!
        
        let player = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        player.setValue(highest_score, forKeyPath: "highest_score");
        player.setValue(highest_level, forKeyPath: "highest_level");
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func addHighestScoreToLeaderBoard(score: Int64) {
        if (self.gcEnabled) {
            let ScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_HIGHESTSCORE_ID)
            ScoreInt.value = score;
            GKScore.report([ScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Your high score was submitted to the High Score Leaderboard!")
                }
            }
        }
    }
    
    private func addHighestLevelToLeaderBoard(level: Int64) {
        if (self.gcEnabled) {
            let LevelInt = GKScore(leaderboardIdentifier: LEADERBOARD_HIGHESTLEVEL_ID)
            LevelInt.value = level;
            GKScore.report([LevelInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Your high score was submitted to the High Score Leaderboard!")
                }
            }
        }
    }
    
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer();
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
            }
        }
    }
    
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
