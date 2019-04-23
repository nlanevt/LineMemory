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
    
    private var grid:[[Tile?]]? = [];
    private var grid_height = 13;
    private var grid_width = 7;
    private var grid_center:CGFloat = -64.0;
    
    private var x_grid_pivot:CGFloat = -135;
    private var y_grid_pivot:CGFloat = 275;
    private var tile_size = CGSize(width: 45.0, height: 45.0);
    private var tile_zPosition:CGFloat = 0.0;
    
    private var highest_score_label = SKLabelNode();
    private var highest_level_label = SKLabelNode();
    private var lblHighestLevel = SKLabelNode();
    private var lblHighestScore = SKLabelNode();
    
    private var line_controller_A:LineController?
    private var line_controller_B:LineController?
    
    private var line_alpha:CGFloat = 0.1;
    
    deinit {
        //print("Menu Scene has been deallocated");
    }
    
    override func didMove(to view: SKView) {
        highest_score_label = self.childNode(withName: "HighestScore") as! SKLabelNode;
        highest_level_label = self.childNode(withName: "HighestLevel") as! SKLabelNode;
        lblHighestLevel = self.childNode(withName: "lblHighestLevel") as! SKLabelNode;
        lblHighestScore = self.childNode(withName: "lblHighestScore") as! SKLabelNode;
        
        grid?.removeAll();
        
        for r in 0 ..< grid_height {
            grid?.append([Tile?]());
            for c in 0 ..< grid_width {
                var new_tile_node = Tile(row: r, column: c, size: tile_size);
                new_tile_node.position = CGPoint(x: x_grid_pivot + (CGFloat(c)*tile_size.width), y: y_grid_pivot - (CGFloat(r)*tile_size.height));
                new_tile_node.zPosition = tile_zPosition;
                self.addChild(new_tile_node)
                grid?[r].append(new_tile_node);
            }
        }
        
        
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                grid?[r][c]?.setNeighbors(grid_width: grid_width, grid_height: grid_height, grid: grid! as! [[Tile]]);
            }
        }
        
        line_controller_A = LineController(grid_width: grid_width, grid_height: grid_height, grid: grid! as! [[Tile]], alpha: line_alpha, smoke_on: false);
        line_controller_B = LineController(grid_width: grid_width, grid_height: grid_height, grid: grid! as! [[Tile]], alpha: line_alpha, smoke_on: false);
        
        animateLineA();
        animateLineB();
        setHighScoreLabels();
        setUpStringLocalization()
    }
    
    private func animateLineA() {
        line_controller_A?.generateLine(turn_count: 3, completion: {[weak self] in
            self?.animateLineA();
        })
    }
    
    private func animateLineB() {
        line_controller_B?.generateLine(turn_count: 2, completion: {[weak self] in
            self?.animateLineB();
        })
    }
    
    private func setHighScoreLabels() {
        highest_score_label.text = "\(menu_view_controller.getHighestScore())";
        highest_level_label.text = "\(menu_view_controller.getHighestLevel())";
    }
    
    private func setUpStringLocalization() {
        lblHighestLevel.fontName = String.localizedStringWithFormat(NSLocalizedString("fontNameA", comment: "The localized font"));
        lblHighestLevel.text = String.localizedStringWithFormat(NSLocalizedString("Your Highest Level", comment: "N/A"));
        
        lblHighestScore.fontName = String.localizedStringWithFormat(NSLocalizedString("fontNameA", comment: "The localized font"));
        lblHighestScore.text = String.localizedStringWithFormat(NSLocalizedString("Your Highest Score", comment: "N/A"));
    }
    
    public func deallocateContent() {
        for r in 0 ..< grid_height {
            for c in 0 ..< grid_width {
                grid?[r][c]?.deallocateContent();
                grid?[r][c]?.removeFromParent();
                grid?[r][c] = nil;
            }
        }
        grid?.removeAll(keepingCapacity: false);
        grid = nil;
        line_controller_A = nil;
        line_controller_B = nil;
        self.removeAllActions();
        self.removeAllChildren();
    }
}
