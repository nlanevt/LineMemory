//
//  MenuScene.swift
//  LineMemory
//
//  Created by Nathan Lane on 3/19/19.
//  Copyright © 2019 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class MenuScene: SKScene, SKPhysicsContactDelegate {
    
    private var grid = [[Tile]]();
    private var grid_height = 13;
    private var grid_width = 7;
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -135;
    private var y_grid_pivot:CGFloat = 275;
    private var tile_size = CGSize(width: 45.0, height: 45.0);
    private var tile_zPosition:CGFloat = 0.5;
    
    private var highest_score_label = SKLabelNode();
    private var highest_level_label = SKLabelNode();
    
    override func didMove(to view: SKView) {
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        highest_level_label = self.childNode(withName: "HighestLevel") as! SKLabelNode;
        
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
                grid[r][c].setNeighbors(grid_width: grid_width, grid_height: grid_height, grid: grid);
            }
        }
        
        animateLines();
        setHighScoreLabels();
    }
    
    private func animateLines() {
        //createLine(turn_count: 3)
        createLine(turn_count: 8);
        //createLine(turn_count: 15);
    }
    
    private func createLine(turn_count: Int) {
        let line = LineController(grid_width: grid_width, grid_height: grid_height, grid: grid);
        line.generateLine(turn_count: turn_count, completion: {
            self.createLine(turn_count: turn_count);
        });
    }
    
    private func setHighScoreLabels() {
        highest_score_label.text = "\(menu_view_controller.getHighestScore())";
        highest_level_label.text = "\(menu_view_controller.getHighestLevel())";
    }
}
