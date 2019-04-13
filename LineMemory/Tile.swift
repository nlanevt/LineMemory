//
//  Tile.swift
//  SigmaConnect
//
//  Created by Nathan Lane on 10/15/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Tile: SKSpriteNode {
    private var covered_texture = SKTexture.init(imageNamed: "CoveredTile"); // will replace with more detailed directional cover tiles.
    private var uncovered_texture = SKTexture.init(imageNamed: "Tile");
    private var neighbor_indexes = [[Int]]();
    private var neighbors:[Tile?]? = [];
    private var row = 0;
    private var column = 0;
    private var value = 0;
    private var label = SKLabelNode();
    public weak var leftNeighbor:Tile? = nil;
    public weak var topNeighbor:Tile? = nil;
    public weak var bottomNeighbor:Tile? = nil;
    public weak var rightNeighbor:Tile? = nil;
    
    init(row: Int, column: Int, size: CGSize) {
        self.row = row;
        self.column = column;
        super.init(texture: uncovered_texture, color: .clear, size: size)
    }
    
    deinit {
        //print("Tile has been deallocated");
    }
    
    convenience init() {
        self.init(row: 0, column: 0, size: CGSize(width: 16.0, height: 16.0));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addNeighbor(tile: Tile)
    {
        self.neighbors?.append(tile);
    }
    
    public func setNeighbors(grid_width: Int, grid_height: Int, grid: [[Tile]]) {
        neighbors?.removeAll();
        leftNeighbor = nil;
        rightNeighbor = nil
        topNeighbor = nil;
        bottomNeighbor = nil;
        
        if column - 1 >= 0 {
            leftNeighbor = grid[row][column-1];
            neighbors?.append(leftNeighbor!)
        }
        
        
        if row - 1 >= 0 {
            topNeighbor = grid[row-1][column];
            neighbors?.append(topNeighbor!)
        }
        
        if row + 1 < grid_height {
            bottomNeighbor = grid[row+1][column]

            neighbors?.append(bottomNeighbor!);
        }
        
        if column + 1 < grid_width {
            rightNeighbor = grid[row][column+1]
            neighbors?.append(rightNeighbor!)
        }
    }
    
    public func checkNeighbors(location: CGPoint) -> Tile? {
        for tile in neighbors! {
            if (tile?.contains(location))! {
                return tile;
            }
        }
        return nil;
    }
    
    public func getDirectionFrom(tile: Tile) -> direction {
        if (tile == topNeighbor) {return .down}
        
        if (tile == bottomNeighbor) {return .up}
        
        if (tile == leftNeighbor) {return .right}
        
        if (tile == rightNeighbor) {return .left}
        
        return .none;
    }
    
    public func addLink(direction: direction, alpha: CGFloat) -> Link {
        let link_node = Link(texture: SKTexture.init(imageNamed: "LinkCoverHead"), size: self.size, direction: direction);
        link_node.zPosition = self.zPosition + 1;
        link_node.alpha = alpha;
        self.addChild(link_node);
        return link_node;
    }

    public func deallocateContent() {
        self.removeFromParent();
        leftNeighbor = nil;
        rightNeighbor = nil
        topNeighbor = nil;
        bottomNeighbor = nil;
        for i in 0 ..< (neighbors?.count)! {
            neighbors?[i] = nil;
        }
        neighbors?.removeAll();
        neighbors = nil;
    }
}
