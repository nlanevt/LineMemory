//
//  GameScene.swift
//  Concord
//
//  Created by Nathan Lane on 1/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import SpriteKit
import GameplayKit

var tiles = [[Tile]]();
var grid_height = 8;
var grid_width = 8;
var column_coordinates = [CGFloat]();
var boundaries:CGRect = CGRect();

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
    private var list = [Tile]();
    private var start_tiles = [Tile]();
    private var round_started = false;
    private var score = 0;
    
    private var start1 = SKSpriteNode();
    private var start2 = SKSpriteNode();
    
    private var top_board_boundary:CGFloat = 160;
    private var bottom_board_boundary:CGFloat = -224;
    
    private var grabbed_tile:Tile!;
    private var tile_grabbed = false;
    private var tile_movement_start:CGPoint!;
    private var tile_movement_previous_direction:direction!;
    private var transitionable = false; // used for when tile movement row/column is eligable to change direction.
    private var blocks:[[SKShapeNode]] = [[SKShapeNode]]();
    private var top_boundary:CGFloat = 0.0;
    private var bottom_boundary:CGFloat = 0.0;
    private var left_boundary:CGFloat = 0.0;
    private var right_boundary:CGFloat = 0.0;
    private var boundaries:CGRect = CGRect();
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -133;
    private var y_grid_pivot:CGFloat = 128;
    private var tile_size = CGSize(width: 38.0, height: 38.0);
    private var tile_zPosition:CGFloat = 0.0;
    
    override func sceneDidLoad() {
        self.backgroundColor = SKColor.black;
        
        tiles.removeAll();
        
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
            tiles.append([Tile]());
            blocks.append([SKShapeNode]());
            for c in 0 ..< grid_width {
                
                let new_tile_node = SKSpriteNode(imageNamed: "Tile");
                new_tile_node.position = CGPoint(x: x_grid_pivot + (CGFloat(c)*tile_size.width), y: y_grid_pivot + (CGFloat(r)*tile_size.height));
                new_tile_node.zPosition = tile_zPosition;
                tiles[r].append(Tile(tileNode: new_tile_node, game_scene: self, row: r, column: c));
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
        }
        
        
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                tiles[r][c].setNeighbors();
            }
        }
        
        boundaries = CGRect(x: 0, y: grid_center, width: CGFloat(grid_width)*blocks[0][0].frame.size.width, height: CGFloat(grid_height)*blocks[0][0].frame.size.height);
        
        print("Boundaries: top \(top_boundary), bottom \(bottom_boundary), left \(left_boundary), right \(right_boundary)");
        
        player_score_label = self.childNode(withName: "Score") as! SKLabelNode;
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        // need to set score variable according to CORE Data database
        level_controller = LevelController.init(game_scene: self);
        startRound();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if (list.isEmpty) {
            for touch in touches {
                let location = touch.location(in: self);
                //print("touchesBegan: \(location)");
                if (location.y > bottom_board_boundary && location.y < top_board_boundary && !tile_grabbed) {
                    //TODO
                    for r in 0 ..< grid_height {
                        for c in 0 ..< grid_width {
                            if (tiles[r][c].node.contains(location)) {
                                grabbed_tile = tiles[r][c];
                                grabbed_tile.grab();
                                tile_grabbed = true;
                                tile_movement_start = location;
                                break;
                            }
                        }
                    }
    
                }
                else {
                    for tile in start_tiles {
                        if (tile.node.contains(location)) {
                            list.append(tile)
                            tile.cover();
                            break;
                        }
                    }
                }
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (round_started) {
            
            // If they have grabbed a tile, then we focus on moving the tiles left/right/up/down, not on creating a line.
            if (tile_grabbed) {
                // Check if grabbed tile is FULLY within a box; if it is, then we reset tile_movement_start to the coordinates at that box and we reset neighbors.
                
                for touch in touches {
                    let location = touch.location(in: self);
                    let touch_direction:[direction] = getDirection(touch_position: location);
                    var tile_direction = touch_direction[0];
                    
                    //transitionable = grabbed_tile.node.contains(location) ? true : false; // make sure that the persons finger is actually on the tile that will be used to transition between row to column and vice versa.
                    transitionable = false;
                    if (tile_movement_previous_direction == nil || tile_movement_previous_direction == .none) {
                        tile_direction = touch_direction[0];
                        grabbed_tile.setTileMovement(dir: tile_direction);
                        tile_movement_previous_direction = tile_direction;
                    }
                    else if (tile_movement_previous_direction == .left || tile_movement_previous_direction == .right) { // If the previous direction was horizontal
                        if (touch_direction[0] == .left || touch_direction[0] == .right) {
                            tile_direction = touch_direction[0];
                            tile_movement_previous_direction = tile_direction;
                        }
                        else if (touch_direction[0] == .up || touch_direction[0] == .down) { //touch_direction[0] == .up or .down; Change direction from horizontal to
                            if (transitionable) {
                                print("Change direction from horizontal to vertical");
                                tile_direction = touch_direction[0];
                                setTileToNearestBlock(tile: grabbed_tile)
                                grabbed_tile.releaseTileMovement();
                                grabbed_tile.setTileMovement(dir: tile_direction);
                                tile_movement_previous_direction = tile_direction;
                            }
                            else {
                                tile_direction = touch_direction[1];
                            }
                        }
                        else { //touch_direction[0] = .none
                            tile_direction = tile_movement_previous_direction;
                        }
                    }
                    else if (tile_movement_previous_direction == .up || tile_movement_previous_direction == .down) { // if the previous direction was vertical.
                        if (touch_direction[0] == .up || touch_direction[0] == .down) {
                            tile_direction = touch_direction[0];
                            tile_movement_previous_direction = tile_direction;
                        }
                        else if (touch_direction[0] == .left || touch_direction[0] == .right) { //touch_direction[0] == .left or .right
                            if (transitionable) {
                                print("Change direction from vertical to horizontal");
                                tile_direction = touch_direction[0];
                                setTileToNearestBlock(tile: grabbed_tile)
                                //grabbed_tile.releaseTileMovement();
                                grabbed_tile.setTileMovement(dir: tile_direction);
                                tile_movement_previous_direction = tile_direction;
                            }
                            else {
                                tile_direction = touch_direction[1];
                            }
                        }
                        else { // touch_direction[0] = none
                            tile_direction = tile_movement_previous_direction;
                        }
                    }
                    
                    if (tile_direction == .left || tile_direction == .right) {
                        grabbed_tile.node.position.x = location.x;
                    }
                    else if (tile_direction == .up || tile_direction == .down) {
                        grabbed_tile.node.position.y = location.y;
                    }
                    else { //tile_direction == .none
                        // Do nothing in this circumstance.
                    }

                    //Column/Row movement fix TODO:
                    //XXX1. Fix row/column moving in a direction it is not supposed to move in.
                    //XXX2. Create snapping effect
                        //a. determine if grabbed_tile is within a block
                        //b. make row/column set itself to that blocks coordinates when touch ends
                    //2. The ability to transition between rows and columns
                    //3. Add wrap around effect
                    //4. enable new tile positions to be updated across all tiles
                }
                
            }
            else if (!list.isEmpty) { // list.isEmpty will return true if they player hasn't touched and moved from one of the start tiles. So if they don't touch from the start tiles and move from there then list.isEmpty will return false.
                for touch in touches {
                    //print("list count: \(list.count)")
                    
                    if let neighbor = list.last?.checkNeighbors(location: touch.location(in: self)) {
                        //print("checking");
                        if (!neighbor.occupied && !neighbor.isObstacle()) { // if the block you selected is not occupied AND it is not an obstacle like a bush, rock or block then cover it  
                            neighbor.cover();
                            list.append(neighbor);
                            if (neighbor.isStartTile()) { //if full connection is made
                                endRound();
                            }
                        }
                        else if (list.count-2 >= 0) { // if it is occupied AND it is the previous block you just selected, then uncover it.
                            if (neighbor.node == list[list.count-2].node) {
                                list.popLast()?.uncover();
                                
                            }
                        }
                        
                    }
                }
            }
            // If list.isEmpty is true then we can assume they haven't actually started a line yet
            else {
                
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (round_started) {
            //print("touchesEnded");
            if (tile_grabbed) {
                tile_grabbed = false;
                setTileToNearestBlock(tile: grabbed_tile);
                tile_movement_previous_direction = nil;
                // Snap tile to nearest position
                // Reset neighbors for tiles
            }
            else if (!list.isEmpty) {
                self.dissipateLine(forward: false, completion: {});
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
        /*for tile in start_tiles {
            tile.setStartTilePosition(column: Int(arc4random_uniform(UInt32(grid_width))))
        }*/
        
        level_controller.setTileValues();
        print("starting round: \(score)");
        //print("score: \(score)");
    }
    
    private func endRound() {
        round_started = false;
        var amount = 0
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
        })
        
    }
    
    private func dissipateLine(forward: Bool, completion: @escaping ()->Void) {
        if (list.isEmpty) {
            completion();
            return;
        }
        
        let cover_node = SKSpriteNode(imageNamed: "CoveredTile");
        cover_node.zPosition = 1.0;
        let removed_node = forward ? list.removeFirst() : list.popLast();
        
        removed_node?.uncover();
        removed_node?.node.addChild(cover_node);
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
    
    private func getDirection(touch_position: CGPoint) -> [direction] {
        var result:[direction] = [];
        
        let horizontal_difference = touch_position.x - tile_movement_start.x;
        let vertical_difference = touch_position.y - tile_movement_start.y;
        var horizontal_first = false;
        
        var horizontal:direction = .none;
        var vertical:direction = .none;
        
        // move horizontally - so either left or right
        if (horizontal_difference > 0) { // right;
            horizontal = .right;
        }
        else if (horizontal_difference < 0) { // left;
            horizontal = .left;
        }
        else {
            horizontal = .none;
        }
        
        if (vertical_difference > 0) { // up
            vertical = .up;
        }
        else if (vertical_difference < 0) { // down
            vertical = .down;
        }
        else {
            vertical = .none;
        }
        
        if (abs(horizontal_difference) > abs(vertical_difference)) {
            horizontal_first = true;
        }
        else if (abs(horizontal_difference) < abs(vertical_difference)) {
            horizontal_first = false;
            // move vertically - so either up or down
        }
        else {
            // 45 degree angle; move in the direction of the previous direction.
            if (tile_movement_previous_direction == .left || tile_movement_previous_direction == .right) {
                return [tile_movement_previous_direction, vertical];
            }
            else if tile_movement_previous_direction == .up || tile_movement_previous_direction == .down {
                return [tile_movement_previous_direction, horizontal];
            }
            else {
                return [.none, .none];
            }
        }
        
        if (horizontal_first) {
            result.append(horizontal);
            result.append(vertical);
        }
        else {
            result.append(vertical);
            result.append(horizontal);
        }
        
        return result;
    }
    
    private func isTileInBlock(tile: Tile) -> CGPoint {
        var result:CGPoint = tile.node.position;
        
    
        
        return result;
    }
    
    // Make sure to do this before releasing the tiles attached tile nodes, that way all of its attached tiles will snap to their own positions on the grid accordingly.
    private func setTileToNearestBlock(tile: Tile) {
        
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                if blocks[r][c].frame.contains(tile.node.position) {
                    tile.node.position = blocks[r][c].position;
                    break;
                }
            }
        }
        let movement_tiles = tile.movement_tiles;
        let dir = tile.movement_direction;
        tile.release();
        tile.releaseTileMovement();

        self.printTiles();
        
    }
    
    private func printTiles() {
        print("");
        print("Tile Grid Contents:");
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                print("[\(tiles[r][c].getValue())]\t\t", terminator: "");
            }
            print("");
        }
        print("");
    }

}
