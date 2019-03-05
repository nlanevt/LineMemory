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
    
    private var level_controller:LevelController!;
    private var line_controller:LineController!;
    
    private var player_score_label = SKLabelNode();
    private var highest_score_label = SKLabelNode();
    private var level_label = SKLabelNode();
    private var rounds_label = SKLabelNode(); // temporary label. will be replaced by sprite images.
    private var lives_label = SKLabelNode(); // temporary label. will be replaced by sprite images.
    
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
    private var grid_width = 8;
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -133;
    private var y_grid_pivot:CGFloat = 128;
    private var tile_size = CGSize(width: 38.0, height: 38.0);
    private var tile_zPosition:CGFloat = 0.0;
    
    private var timer_node = SKSpriteNode();
    private var timer_blocker_left = SKSpriteNode();
    private var timer_blocker_right = SKSpriteNode();
    
    private var pause_button = SKSpriteNode();
    private var pause_button_grid = SKSpriteNode();
    private var pauseButtonTexture:SKTexture = SKTexture.init(imageNamed: "pauseButton");
    private var pauseButtonAnimationTexture:SKTexture = SKTexture.init(imageNamed: "pauseButtonAnimation");
    
    public var view_controller:GameViewController!;
    
    override func sceneDidLoad() {
        self.backgroundColor = SKColor.black;
        
        timer_node = self.childNode(withName: "TimerNode") as! SKSpriteNode;
        timer_blocker_left = self.childNode(withName: "TimerBlockerLeft") as! SKSpriteNode;
        timer_blocker_right = self.childNode(withName: "TimerBlockerRight") as! SKSpriteNode;
        
        player_score_label = self.childNode(withName: "Score") as! SKLabelNode;
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        level_label = self.childNode(withName: "Level") as! SKLabelNode;
        rounds_label = self.childNode(withName: "RoundsLeft") as! SKLabelNode; // temporary
        lives_label = self.childNode(withName: "Lives") as! SKLabelNode;
        pause_button = self.childNode(withName: "PauseButton") as! SKSpriteNode;
        pause_button_grid = self.childNode(withName: "PauseButtonGrid") as! SKSpriteNode;
        
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
        
        player_score_label = self.childNode(withName: "Score") as! SKLabelNode;
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        // need to set score variable according to CORE Data database
        line_controller = LineController(grid_width: grid_width, grid_height: grid_height, grid: grid);
        level_controller = LevelController(game_scene: self, level: 1);
        setLevelDisplay();
        setRoundsLeftDisplay()
        setLivesDisplay();
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
            
        }
        
      /* if (player_go && player_line_list.isEmpty) {
            for touch in touches {
                let location = touch.location(in: self);
                let tile = findTile(location: location);
                if (tile != nil) {
                    player_line_list.append((tile?.addLink(direction: .none))!);
                }
            }
        }*/
        
        // pause the game
        
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
        round_started = true;
        
        cleanPlayerLine(); // Removes nodes from the scene. clears up memory.
        
        ai_line_points.removeAll();
        
        // Create AI Line
        ai_line_points = line_controller.generateLine(turn_count: level_controller.getTurns(), completion: {
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
            
            if (level_decreases) {
                setRoundsLeftDisplay();
                setLevelDisplay();
                let reduction_amount = level_controller.getScoreReduction();
                let starting_score = score;
                score = score - reduction_amount;
                self.animateSum(starting_value: starting_score, amount: -reduction_amount, label: player_score_label, completion: {})
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
        let level_increases = level_controller.roundWon(by_amount: amount);
        setRoundsLeftDisplay();
        if (level_increases) {
            // Do things to congratulate player
            // Do animations to increase level (such as a flash for example)
            setLivesDisplay();
            setLevelDisplay();
        }
    }
    
    private func setLivesDisplay() {
        lives_label.text = "\(level_controller.getLivesLeft())";
    }
    
    // The overall aesthetic of this label will change.
    private func setLevelDisplay() {
        level_label.text = "\(level_controller.getCurrentLevel())";
    }
    
    // Will update this to use animations
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
        
        let dissipation_action = SKAction.fadeOut(withDuration: 0.1);
        
        let iteration_increase = iterator + 1;
        
        player_line_list[iterator].run(dissipation_action, completion:{
            self.animatePlayerLineDissipation(iterator: iteration_increase, completion: completion)
        });
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
            //print("check at: \(mid_r), \(mid_c) with [\(r_lowerbound), \(r_upperbound)] and [\(c_lowerbound), \(c_upperbound)]")
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
    
    private func cleanPlayerLine() {
        for link in player_line_list {
            link.removeFromParent();
            link.removeAllActions();
        }
        
        player_line_list.removeAll();
    }
    
    private func pauseGame()
    {
        if (self.isPaused == false && !is_destroying_line && player_line_list.isEmpty) {
            print("Pause Game");
            pause_button.run(SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed: "PauseButtonPressed")), SKAction.wait(forDuration: 0.25)]), completion: {
                //self.isPaused = true;
                self.view_controller.showPauseView();
                self.pause_button.texture = SKTexture(imageNamed: "PauseButton");
            });
        }
    }
    
    public func refreshRound() {
        print("refresh");
        if (isPaused) {return};
        cleanPlayerLine();
        resetTimer();
        startRound();
    }
}
