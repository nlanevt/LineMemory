//
//  GameScene.swift
//  Concord
//
//  Created by Nathan Lane on 1/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import SpriteKit
import GameplayKit


var grid_height = 8;
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
        
        /*for r in 0 ..< grid_height {
            tiles.append([Tile]())
            blocks.append([SKShapeNode]())
            for c in 0 ..< grid_width {
                tiles[r].append(Tile(tileNode: self.childNode(withName: "Tile\(r)\(c)") as! SKSpriteNode, game_scene: self, row: r, column: c));
                let block:SKShapeNode = SKShapeNode(rectOf: CGSize(width: tiles[r][c].node.size.width, height: tiles[r][c].node.size.height));
                block.fillColor = .black;
                block.zPosition = -1;
                block.position = tiles[r][c].node.position;
                self.addChild(block);
                blocks[r].append(block);
                // Add and save the coordinates to the columns so that you can properly adjust the starting tiles, which need to know those coordinates.
                // Should only do this first time running through this inner loop.
                if (column_coordinates.count < grid_width) {
                    column_coordinates.append(tiles[r][c].node.position.x)
                }
            }
            
            
        }*/
        
        for r in 0 ..< grid_height {
            grid.append([Tile]());
            for c in 0 ..< grid_width {
                let new_tile_node = Tile(row: r, column: c, size: tile_size);
                new_tile_node.position = CGPoint(x: x_grid_pivot + (CGFloat(c)*tile_size.width), y: y_grid_pivot + (CGFloat(r)*tile_size.height));
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
        }

        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled");

    }
    
    
    override func update(_ currentTime: TimeInterval) {

    }
    
    private func startRound() {
        round_started = true;
        
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

}
