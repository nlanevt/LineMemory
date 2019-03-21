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

class MenuViewController: UIViewController {
    
    private var highest_score:Int64 = 0;
    private var highest_level:Int64 = 0;
    private var did_beat_game = false;
    var player:NSManagedObject? = nil;
    var players:[NSManagedObject] = [];
    
    @IBAction func StartGameButton(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController;
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScores();
        
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
    
    public func setNewHighestLevel(new_highest_level: Int64) {
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
    
}
