//
//  GameScene.swift
//  Concord
//
//  Created by Nathan Lane on 1/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import SpriteKit
import GameplayKit




enum direction {
    case left;
    case right;
    case up;
    case down;
    case left_up;
    case left_down;
    case right_up;
    case right_down;
    case up_left;
    case up_right;
    case down_left;
    case down_right;
    case none;
}

class GameScene: SKScene {
    
    public var view_controller:GameViewController!;
    private var level_controller:LevelController!;
    private var line_controller:LineController!;
    
    private var player_score_label = SKLabelNode();
    private var highest_score_label = SKLabelNode();
    private var highest_level_label = SKLabelNode();
    private var level_label = SKLabelNode();
    private var level_display_label = SKLabelNode();
    private var rounds_label = SKLabelNode(); // temporary label. will be replaced by sprite images.
    private var lives_label = SKLabelNode(); // temporary label. will be replaced by sprite images.
    private var gameWonA_label = SKLabelNode();
    private var gameWonB_label = SKLabelNode();
    private var return_home_button = SKLabelNode();
    
    private var player_line_list = [Link]();
    private var max_line_limit = 1000;
    private var ai_line_points = [CGPoint]();
    private var round_started = false;
    private var player_go = false;
    private var score:Int64 = 0;
    private var player_lives = 5;
    private var is_destroying_line = false;
    
    public var grid = [[Tile]]();
    private var grid_height = 10;
    private var grid_width = 7;
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -135;
    private var y_grid_pivot:CGFloat = 195;
    private var tile_size = CGSize(width: 45.0, height: 45.0);
    private var tile_zPosition:CGFloat = 0.5;
    
    private var timer_node = SKSpriteNode();
    private var timer_blocker_left = SKSpriteNode();
    private var timer_blocker_right = SKSpriteNode();
    
    private var pause_button = SKSpriteNode();
    private var pause_button_grid = SKSpriteNode();
    
    private var refresh_button = SKSpriteNode();
    private var refresh_button_grid = SKSpriteNode();
    
    private var round_nodes_array = [SKSpriteNode]();
    private var life_nodes_array = [SKSpriteNode]();
    
    private var game_won = false;
    
    override func sceneDidLoad() {
        self.backgroundColor = SKColor.black;
        
        timer_node = self.childNode(withName: "TimerNode") as! SKSpriteNode;
        timer_blocker_left = self.childNode(withName: "TimerBlockerLeft") as! SKSpriteNode;
        timer_blocker_right = self.childNode(withName: "TimerBlockerRight") as! SKSpriteNode;
        
        player_score_label = self.childNode(withName: "Score") as! SKLabelNode;
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        highest_level_label = self.childNode(withName: "HighestLevel") as! SKLabelNode;
        level_label = self.childNode(withName: "Level") as! SKLabelNode;
        level_display_label = self.childNode(withName: "lblLevel") as! SKLabelNode;
        rounds_label = self.childNode(withName: "RoundsLeft") as! SKLabelNode; // temporary
        lives_label = self.childNode(withName: "Lives") as! SKLabelNode;
        
        pause_button = self.childNode(withName: "PauseButton") as! SKSpriteNode;
        pause_button_grid = self.childNode(withName: "PauseButtonGrid") as! SKSpriteNode;
        
        refresh_button = self.childNode(withName: "RefreshButton") as! SKSpriteNode;
        refresh_button_grid = self.childNode(withName: "RefreshButtonGrid") as! SKSpriteNode;
        gameWonA_label = self.childNode(withName: "lblGameWonA") as! SKLabelNode;
        gameWonB_label = self.childNode(withName: "lblGameWonB") as! SKLabelNode;
        return_home_button = self.childNode(withName: "btnReturnHome") as! SKLabelNode;
        
        grid.removeAll();
        
        for r in 0 ..< grid_height {
            grid.append([Tile]());
            for c in 0 ..< grid_width {
                let new_tile_node = Tile(row: r, column: c, size: tile_size);
                new_tile_node.position = CGPoint(x: x_grid_pivot + (CGFloat(c)*tile_size.width), y: y_grid_pivot - (CGFloat(r)*tile_size.height));
                new_tile_node.zPosition = tile_zPosition;
                self.addChild(new_tile_node)
                grid[r].append(new_tile_node);
            }
        }
        
        
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                grid[r][c].setNeighbors(grid_width: grid_width, grid_height: grid_height);
            }
        }
        
        gameWonA_label.isHidden = true;
        gameWonB_label.isHidden = true;
        return_home_button.isHidden = true;

        // need to set score variable according to CORE Data database
        line_controller = LineController(grid_width: grid_width, grid_height: grid_height, grid: grid);
        level_controller = LevelController(game_scene: self, level: 256);
        setLevelDisplay();
        setRoundsLeftDisplay()
        setLivesDisplay();
        setHighScoreLabels();
        createRoundsAnimation();
        createLivesAnimation();
        startRound();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began");
        if (isPaused) {return}
        
        for touch in touches {
            let location = touch.location(in: self);
            if (player_go && player_line_list.isEmpty) {
                let tile = findTile(location: location);
                if (tile != nil) {
                    player_line_list.append((tile?.addLink(direction: .none))!);
                }
            }
            
            if (!isPaused && pause_button_grid.contains(location))
            {
                pauseGame()
            }
            else if (!isPaused && refresh_button_grid.contains(location)) {
                refreshLine();
            }
            else if (!isPaused && game_won && return_home_button.contains(location)) {
                returnHome();
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isPaused) {return}
        
        if (player_go && !player_line_list.isEmpty) {
            if (player_line_list.count >= max_line_limit) {endRound(round_won: false)}
            
            for touch in touches {
                let location = touch.location(in: self);
                let previous_tile = player_line_list.last?.parent as! Tile;
                let new_tile = previous_tile.checkNeighbors(location: location)
                if (new_tile != nil) {
                    if (player_line_list.count >= 2 && player_line_list[player_line_list.count - 2].parent as? Tile == new_tile) {
                        // erase the current tile
                        let last_link = player_line_list.popLast();
                        let current_link = player_line_list.last;
                        current_link?.setDirection(direction: resetDirection(current_link_dir: (current_link?.getDirection())!));
                        current_link?.setAsHead();
                        last_link?.remove();
                    }
                    else  {
                        // Add new tiles
                        let dir = new_tile?.getDirectionFrom(tile: previous_tile);
                        let previous_link_dir = player_line_list.last!.getDirection();
                        let new_dir_for_previous_link = compareDirections(dirA: previous_link_dir, dirB: dir!);
                        player_line_list.last?.setDirection(direction: new_dir_for_previous_link);
                        player_line_list.append((new_tile?.addLink(direction: dir!))!);
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Compares the player and AI line if the line list is not empty.
        // No comparison will occur if no line has been made.
        print("touches ended");
        if (isPaused) {return}
        
        if (player_go && !player_line_list.isEmpty) {
            
            // Compare their list sizes.
            if (player_line_list.count != ai_line_points.count) {
                endRound(round_won: false);
                return;
            }
            
            // Compare each point individually.
            for i in 0 ..< player_line_list.count {
                if (player_line_list[i].parent != grid[Int(ai_line_points[i].y)][Int(ai_line_points[i].x)]) {
                    endRound(round_won: false);
                    return;
                }
            }
            
            if let last_turn = line_controller.getTurnsOfLastLine().last {
                //player_line_list.last?.setDirection(direction: last_turn);
                let final_direction = last_turn//compareDirections(dirA: player_line_list[player_line_list.count-2].getDirection(), dirB: last_turn);
                player_line_list.last?.setDirection(direction: final_direction)
            }
            
            // If none of the above happen, then you won the round.
            endRound(round_won: true);
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled");
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    private func startRound() {
        if (game_won) {return}
        
        round_started = true;
        player_go = false;
        cleanPlayerLine(); // Removes nodes from the scene. clears up memory.
        ai_line_points.removeAll();
        
        // Create AI Line
        var turns = level_controller.getTurns();
        //turns = ;
        print("level \(level_controller.getCurrentLevel()), round \(level_controller.getRoundsLeft()), turns: \(turns)");
        ai_line_points = line_controller.generateLine(turn_count: turns, completion: {
            self.startTimer();
            self.player_go = true;
        });

        print("starting round: \(score)");
    }
    
    private func endRound(round_won: Bool) {
        print("end round");
        if (!player_go || !round_started) {return}
        
        round_started = false;
        player_go = false;
        resetTimer();
        
        // If you lose the round due to the timer running out or due to incorrect line...
        if (!round_won) {
            self.animatePlayerLineDestruction(iterator: player_line_list.count-1, completion: {
                self.startRound();
            });
            
            // lower player lives
            let level_decreases = level_controller.roundLost();
            
            setLivesDisplay();
            removeLifeAnimation();
            
            if (level_decreases) {
                setRoundsLeftDisplay();
                setLevelDisplay();
                /*flashLabel(label: level_display_label, color: .red, number_of_times: 10)
                flashLabel(label: level_label, color: .red, number_of_times: 10)*/
                levelDecreaseAnimation();
                //MARK: Remove all rounds
                //MARK: Re-create all rounds
                createRoundsAnimation();
                let reduction_amount = level_controller.getScoreReduction();
                let starting_score = score;
                score = score - reduction_amount;
                self.animateSum(starting_value: starting_score, amount: -reduction_amount, label: player_score_label, completion: {});
                createLivesAnimation();
            }
            
            return;
        }
        
        self.animatePlayerLineDissipation(iterator: 0, completion: {
            self.startRound();
        })
        
        // Set and animate the score.
        let amount = Int64(player_line_list.count)*5;
        let starting_score = score;
        score = score + amount;
        self.animateSum(starting_value: starting_score, amount: amount, label: player_score_label, completion: {});
        
        // Increase the level if enough rounds have been won.
        // Calling RoundWon() also increases the difficulty within the level.
        let level_increases = level_controller.roundWon(by_amount: amount);
        setRoundsLeftDisplay();
        removeRoundAnimation();
        
        if (level_increases) {
            // Do things to congratulate player
            // Do animations to increase level (such as a flash for example)
            setLivesDisplay();
            setLevelDisplay();
            //flashLabel(label: level_display_label, color: .yellow, number_of_times: 10)
            //flashLabel(label: level_label, color: .yellow, number_of_times: 10)
            levelIncreaseAnimation()
            createRoundsAnimation();
            createLivesAnimation();
        }
        
        setScoreData();
    }
    
    private func setScoreData() {
        let highest_score = menu_view_controller.getHighestScore();
        let highest_level = menu_view_controller.getHighestLevel();
        let current_level = level_controller.getCurrentLevel();
        let maximum_level = level_controller.getMaximumLevel();
        
        /*if (score <= highest_score && current_level <= highest_level && current_level != maximum_level) {
            return;
        }
        
        if (score > highest_score) {
            menu_view_controller.setNewHighScore(new_high_score: score);
        }
        
        if (current_level > highest_level) {
            menu_view_controller.setNewHighestLevel(new_highest_level: level_controller.getCurrentLevel());
        }*/ //MARK
        
        // Game Won!!!
        if (/*current_level >= maximum_level*/level_controller.didBeatGame()) {
            game_won = true;
            //menu_view_controller.playerBeatGame(did_player_beat_game: true); //MARK
            self.showGameWon();
        }
        
        /*menu_view_controller.deleteCoreData();
        menu_view_controller.save_data();
        menu_view_controller.loadScores();*/ //MARK
        setHighScoreLabels();
    }
    
    //TODO: Not in use
    private func setLivesDisplay() {
        lives_label.text = "\(level_controller.getLivesLeft())";
    }
    
    // The overall aesthetic of this label will change.
    private func setLevelDisplay() {
        level_label.text = "\(level_controller.getCurrentLevel())";
    }
    
    
    private func flashLabel(label: SKLabelNode, color: UIColor, number_of_times: Int) {
        if (number_of_times < 1) {return}
        
        let waitAction = SKAction.wait(forDuration: 0.1);
        let changeColorAction = SKAction.run({
            label.fontColor = color;
        })
        
        let changeColorBackAction = SKAction.run({
            label.fontColor = UIColor.white;
        })
        
        let repeatAction = SKAction.repeat(SKAction.sequence([changeColorAction, waitAction, changeColorBackAction, waitAction]), count: number_of_times);
        
        label.run(repeatAction);
    }
    
    private func levelIncreaseAnimation() {
        let number_of_times = 5;
        let waitAction = SKAction.wait(forDuration: 0.1);
        let changeColorYellow = SKAction.run({
            self.level_display_label.fontColor = UIColor.yellow;
            self.level_label.fontColor = UIColor.yellow;
        })
        
        let changeColorBlue = SKAction.run({
            self.level_display_label.fontColor = UIColor.blue;
            self.level_label.fontColor = UIColor.blue;
        })
        
        let changeColorGreen = SKAction.run({
            self.level_display_label.fontColor = UIColor.green;
            self.level_label.fontColor = UIColor.green;
        })
        
        let changeColorWhite = SKAction.run({
            self.level_display_label.fontColor = UIColor.white;
            self.level_label.fontColor = UIColor.white;
        })
        
        let repeatAction = SKAction.repeat(SKAction.sequence([changeColorGreen, waitAction, changeColorBlue, waitAction, changeColorWhite, waitAction]), count: number_of_times);
        
        level_display_label.run(repeatAction);
        level_label.run(repeatAction);
    }
    
    private func levelDecreaseAnimation() {
        let number_of_times = 10;
        let waitAction = SKAction.wait(forDuration: 0.1);
        let changeColorYellow = SKAction.run({
            self.level_display_label.fontColor = UIColor.yellow;
            self.level_label.fontColor = UIColor.yellow;
        })
        
        let changeColorRed = SKAction.run({
            self.level_display_label.fontColor = UIColor.red;
            self.level_label.fontColor = UIColor.red;
        })
        
        let changeColorGreen = SKAction.run({
            self.level_display_label.fontColor = UIColor.green;
            self.level_label.fontColor = UIColor.green;
        })
        
        let changeColorWhite = SKAction.run({
            self.level_display_label.fontColor = UIColor.white;
            self.level_label.fontColor = UIColor.white;
        })
        
        let repeatAction = SKAction.repeat(SKAction.sequence([changeColorYellow, waitAction, changeColorRed, waitAction, changeColorWhite, waitAction]), count: number_of_times);
        
        level_display_label.run(repeatAction);
        level_label.run(repeatAction);
    }
    
    // Will update this to use animations
    // TODO: Not in use
    private func setRoundsLeftDisplay() {
        rounds_label.text = "\(level_controller.getRoundsLeft())";
    }
    
    // Animate the timer nodes.
    // This animation is subject to change
    private func startTimer() {
        // For earlier levels, the timer is not as intense; as the levels increase, the timer intensifies.
        let run_time = self.line_controller.getRunTime() * self.level_controller.getTimerMultiplier();
        timer_blocker_left.run(SKAction.moveTo(x: -80.0, duration: run_time));
        timer_blocker_right.run(SKAction.moveTo(x: 80.0, duration: run_time), completion: {
            self.endRound(round_won: false);
        })
    }

    private func resetTimer() {
        timer_blocker_left.removeAllActions();
        timer_blocker_right.removeAllActions();
        timer_blocker_left.run(SKAction.moveTo(x: -240.0, duration: 0.25));
        timer_blocker_right.run(SKAction.moveTo(x: 240.0, duration: 0.25));
    }
    
    private func animateSum(starting_value: Int64, amount: Int64, label: SKLabelNode, completion: @escaping ()->Void) {
        print("amount: \(amount), \(Int(amount))");
        
        var score_counter = starting_value;
        var iterator:Int64 = 0;
        
        if (amount > 0) {iterator = 1}
        else if (amount < 0) {iterator = -1}
        else {iterator = 0}
        
        let waitAction = SKAction.wait(forDuration: 0.005);
        let increaseScoreAction = SKAction.run({
            label.fontColor = UIColor.yellow;
            score_counter = score_counter + iterator;
            label.text = "\(score_counter)";
        });
        
        let repeatScoreIncreaseAction = SKAction.repeat(SKAction.sequence([increaseScoreAction, waitAction]), count: abs(Int(amount)));
        
        label.run(repeatScoreIncreaseAction, completion: {
            label.fontColor = UIColor.white;
            completion();
        });
    }
    
    private func animatePlayerLineDissipation(iterator: Int, completion: @escaping ()->Void) {
        if (iterator >= player_line_list.count) {
            completion();
            return;
        }
        
        let iteration_increase = iterator + 1;
        
        player_line_list[iterator].animateDissipation(completion: {
            self.animatePlayerLineDissipation(iterator: iteration_increase, completion: completion)
        })
    }
    
    private func animatePlayerLineDestruction(iterator: Int, completion: @escaping ()->Void) {
        print("destroy player line: \(player_line_list.count)");
        if (player_line_list.isEmpty) {
            completion();
            return;
        }
        
        is_destroying_line = true;
        
        var wait_duration = 0.0;
        while (!player_line_list.isEmpty) {
            let index = Int(arc4random_uniform(UInt32(player_line_list.count)));
            let link = player_line_list.remove(at: index);
            let wait_action = SKAction.wait(forDuration: wait_duration);
            
            if (player_line_list.isEmpty) {
                link.run(SKAction.sequence([wait_action, SKAction.fadeOut(withDuration: 0.25)]), completion: {
                    self.is_destroying_line = false;
                    completion();
                });
            }
            else {
               link.run(SKAction.sequence([wait_action, SKAction.fadeOut(withDuration: 0.25)]));
            }
            wait_duration = wait_duration + 0.05;
        }
    }
    
    // Make sure to do this before releasing the tiles attached tile nodes, that way all of its attached tiles will snap to their own positions on the grid accordingly.
    private func printTiles() {
        print("");
        print("Tile Grid Contents:");
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                //print("[\(grid[r][c].getValue())]\t\t", terminator: "");
            }
            print("");
        }
        print("");
    }
    
    private func findTile(location: CGPoint) -> Tile? {
        
        var c_lowerbound = 0;
        var c_upperbound = grid_width-1;
        var r_lowerbound = 0;
        var r_upperbound = grid_height-1;
        //print("Search Grid:")
        while (true) {
            let mid_c = (c_lowerbound + c_upperbound) / 2;
            let mid_r = (r_lowerbound + r_upperbound) / 2;

            if (grid[mid_r][mid_c].contains(location)) {
                return grid[mid_r][mid_c];
            }
            else if (c_lowerbound > c_upperbound || r_lowerbound > r_upperbound) {
                return nil;
            }
            else {
                if (location.x < grid[mid_r][mid_c].frame.minX) {
                    c_upperbound = mid_c-1;
                }
                else if (location.x > grid[mid_r][mid_c].frame.maxX) {
                    c_lowerbound = mid_c+1;
                }
                
                if (location.y < grid[mid_r][mid_c].frame.minY) {
                    
                    r_lowerbound = mid_r+1;
                }
                else if (location.y > grid[mid_r][mid_c].frame.maxY) {
                    r_upperbound = mid_r-1;
                }
            }
        }
    }
    
    private func compareDirections(dirA: direction, dirB: direction) -> direction {
        if (dirA == .none && dirA != dirB) {return dirB}
        
        if (dirA == dirB) {return dirB}
        
        if (dirA == .up) {
            if (dirB == .right) {
                return .up_right;
            }
            else if (dirB == .left) {
                return .up_left;
            }
            else if (dirB == .down) {
                return .up;
            }
            else {
                return .none;
            }
        }
        
        if (dirA == .down) {
            if (dirB == .right) {
                return .down_right;
            }
            else if (dirB == .left) {
                return .down_left;
            }
            else if (dirB == .up) {
                return .down;
            }
            else {
                return .none;
            }
        }
        
        if (dirA == .left) {
            if (dirB == .up) {
                return .left_up;
            }
            else if (dirB == .down) {
                return .left_down;
            }
            else if (dirB == .right) {
                return .left;
            }
            else {
                return .none;
            }
        }
        
        if (dirA == .right) {
            if (dirB == .up) {
                return .right_up;
            }
            else if (dirB == .down) {
                return .right_down;
            }
            else if (dirB == .left) {
                return .right;
            }
            else {
                return .none;
            }
        }
        
        return .none;
    }
    
    private func resetDirection(current_link_dir: direction) -> direction {
        if (current_link_dir == .up_left || current_link_dir == .up_right) {return .up};
        
        if (current_link_dir == .down_left || current_link_dir == .down_right) {return .down};
        
        if (current_link_dir == .left_down || current_link_dir == .left_up) {return .left};
        
        if (current_link_dir == .right_down || current_link_dir == .right_up) {return .right};
        return current_link_dir;
    }
    
    // MARK: Needs to be fixed due to current bug where line nodes won't permenantly delete.
    private func cleanPlayerLine() {
        for link in player_line_list {
            link.removeFromParent();
            link.removeAllActions();
        }
        
        player_line_list.removeAll();
    }
    
    private func pauseGame() {
        if (self.isPaused == false && !is_destroying_line && player_line_list.isEmpty) {
            print("Pause Game");
            pause_button.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "PauseButtonPressed")), SKAction.wait(forDuration: 0.25)]), completion: {
                    self.view_controller.showPauseView();
                    self.pause_button.texture = SKTexture(imageNamed: "PauseButton");
                });
        }
    }
    
    private func refreshLine() {
        if (!player_go) {return};
    refresh_button.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "RefreshButtonPressed")), SKAction.wait(forDuration: 0.25)]), completion: {
        self.refreshRound();
        self.refresh_button.texture = SKTexture(imageNamed: "RefreshButton");
        });
    }
    
    public func refreshRound() {
        //print("refresh");
        if (isPaused) {return};
        cleanPlayerLine();
        resetTimer();
        startRound();
    }
    
    private func setHighScoreLabels() {
        highest_score_label.text = "\(menu_view_controller.getHighestScore())";
        highest_level_label.text = "\(menu_view_controller.getHighestLevel())";
    }
    
    private func createRoundsAnimation() {
        
        if (round_nodes_array.count > 0) {
            for round in round_nodes_array {
                round.removeFromParent();
                round.removeAllActions();
            }
            round_nodes_array.removeAll();
        }
        
        let start_position = CGPoint(x: -145.0, y: 240.0);
        let round_node_size = CGSize(width: 8, height: 21);
        let round_node_z:CGFloat = 1.0;
        let rounds = level_controller.getRoundsLeft()
        var wait_time:TimeInterval = 0.0;
        for i in 0 ..< rounds {
            let round_node = SKSpriteNode(imageNamed: "Round");
            round_node.size = round_node_size;
            round_node.position = CGPoint(x: start_position.x + CGFloat(1 + i*10), y: start_position.y)
            round_node.zPosition = round_node_z;
            round_nodes_array.append(round_node);
            self.addChild(round_nodes_array[i]);
            round_node.alpha = 0.0;
            let actionSequence = SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.unhide(), SKAction.fadeIn(withDuration: 0.5)])
            round_node.run(actionSequence);
            wait_time = wait_time + 0.2;
        }
    }
    
    private func removeRoundAnimation() {
        let removalSequence = SKAction.sequence([SKAction.animate(with: animation_frames_manager.RoundShrinkFrames, timePerFrame: 0.05), SKAction.hide()])
        var round_node = round_nodes_array.popLast();
        round_node?.run(removalSequence, completion: {round_node?.removeFromParent(); round_node = nil});
    }
    
    private func createLivesAnimation() {
        if (life_nodes_array.count > 0) {
            for round in life_nodes_array {
                round.removeFromParent();
                round.removeAllActions();
            }
            life_nodes_array.removeAll();
        }
        
        let start_position = CGPoint(x: 100.0, y: 242.0);
        let life_node_size = CGSize(width: 24, height: 24);
        let life_node_z:CGFloat = 1.0;
        let lives = level_controller.getLivesLeft();
        var wait_time:TimeInterval = 0.0;
        for i in 0 ..< lives {
            let life_node = SKSpriteNode(imageNamed: "Life");
            life_node.size = life_node_size;
            life_node.position = CGPoint(x: start_position.x - CGFloat(1 + i*25), y: start_position.y)
            life_node.zPosition = life_node_z;
            life_nodes_array.append(life_node);
            self.addChild(life_nodes_array[i]);
            life_node.alpha = 0.0;
            let actionSequence = SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.unhide(), SKAction.fadeIn(withDuration: 0.5)])
            life_node.run(actionSequence);
            wait_time = wait_time + 0.2;
        }
    }
    
    private func removeLifeAnimation() {
        let removalAction = SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.1, duration: 0.2), SKAction.fadeAlpha(to: 0.5, duration: 0.2)]), count: 4), SKAction.fadeOut(withDuration: 0.2)]);
        var life_node = life_nodes_array.popLast();
        life_node?.run(removalAction, completion: {life_node?.removeFromParent(); life_node = nil});
    }


    private func showGameWon() {
        gameWonA_label.alpha = 0.0;
        gameWonB_label.alpha = 0.0;
        return_home_button.alpha = 0.0;
        gameWonA_label.isHidden = false;
        gameWonB_label.isHidden = false;
        return_home_button.isHidden = false;
        let fade_in_time:TimeInterval = 1.0;
        gameWonA_label.run(SKAction.fadeIn(withDuration: fade_in_time));
        gameWonB_label.run(SKAction.fadeIn(withDuration: fade_in_time));
        return_home_button.run(SKAction.fadeIn(withDuration: fade_in_time));
    }
    
    private func returnHome() {
        return_home_button.run(SKAction.sequence([SKAction.run({self.return_home_button.color = UIColor.clear}), SKAction.wait(forDuration: 0.5)]), completion: {
            self.view_controller.returnToMenu();
        })
    }
}
