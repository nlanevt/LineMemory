//
//  GameScene.swift
//  Concord
//
//  Created by Nathan Lane on 1/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import SpriteKit
import GameplayKit


var grid_height = 10;
var grid_width = 8;

enum direction {
    case left;
    case right;
    case up;
    case down;
    case none;
}

class GameScene: SKScene {
    
    private var level_controller:LevelController!;
    private var player_score_label = SKLabelNode();
    private var highest_score_label = SKLabelNode();
    private var player_line_list = [Tile]();
    private var round_started = false;
    private var player_go = false;
    private var score = 0;
    
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -133;
    private var y_grid_pivot:CGFloat = 128;
    private var tile_size = CGSize(width: 38.0, height: 38.0);
    private var tile_zPosition:CGFloat = 0.0;
    
    public var grid = [[Tile]]();
    
    override func sceneDidLoad() {
        self.backgroundColor = SKColor.black;
        
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
                grid[r][c].setNeighbors();
            }
        }
        
        player_score_label = self.childNode(withName: "Score") as! SKLabelNode;
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        // need to set score variable according to CORE Data database
        level_controller = LevelController.init(game_scene: self);
        startRound();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        for touch in touches {
            let location = touch.location(in: self);
            if (player_go) {
                let tile = findTile(location: location);
                if (tile != nil) {
                    tile?.cover();
                }
            }
        }

        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (player_go) {
            for touch in touches {
                let location = touch.location(in: self);
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (player_go) {
            for touch in touches {
                let location = touch.location(in: self);
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled");

    }
    
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    private func startRound() {
        round_started = true;
        player_go = true; //temporary for testing purposes.
        print("starting round: \(score)");
    }
    
    private func endRound() {
        round_started = false;
        /*var amount = 0
        let starting_score = score;
        
        for tile in list {
            if (!tile.isStartTile()) {
                amount = amount + tile.getValue();
            }
        }
        
        score = score + amount;
        //print("score: \(score)");
        
        self.animateSum(starting_value: Int64(starting_score), amount: Int64(amount), label: player_score_label, completion: {})

        self.dissipateLine(forward: true, completion: {
            self.startRound();
        })*/
        
    }
    
    private func dissipateLine(forward: Bool, completion: @escaping ()->Void) {
        if (player_line_list.isEmpty) {
            completion();
            return;
        }
        
        let cover_node = SKSpriteNode(imageNamed: "CoveredTile");
        cover_node.zPosition = 1.0;
        let removed_node = forward ? player_line_list.removeFirst() : player_line_list.popLast();
        
        removed_node?.uncover();
        removed_node?.addChild(cover_node); ///WTF???
        cover_node.run(SKAction.fadeOut(withDuration: 0.05), completion: {
            cover_node.removeFromParent();
            self.dissipateLine(forward: forward, completion: completion)
        })

    }
    
    private func animateSum(starting_value: Int64, amount: Int64, label: SKLabelNode, completion: @escaping ()->Void) {
        print("amount: \(amount), \(Int(amount))");
        var score_counter = starting_value;
        let iterator:Int64 = amount > 0 ? 1 : -1;
        let waitAction = SKAction.wait(forDuration: 0.005);
        let increaseScoreAction = SKAction.run({
            label.fontColor = UIColor.yellow;
            score_counter = score_counter + iterator;
            label.text = "\(score_counter)";
        })
        
        let repeatScoreIncreaseAction = SKAction.repeat(SKAction.sequence([increaseScoreAction, waitAction]), count: abs(Int(amount)));
        
        label.run(repeatScoreIncreaseAction, completion: {
            label.fontColor = UIColor.white;
            completion();
        });
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
}
