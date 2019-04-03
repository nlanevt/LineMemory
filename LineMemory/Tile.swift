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
    private var neighbors = [Tile]();
    private var row = 0;
    private var column = 0;
    private var value = 0;
    private var label = SKLabelNode();
    public var leftNeighbor:Tile? = nil;
    public var topNeighbor:Tile? = nil;
    public var bottomNeighbor:Tile? = nil;
    public var rightNeighbor:Tile? = nil;
    
    init(row: Int, column: Int, size: CGSize) {
        self.row = row;
        self.column = column;
        super.init(texture: uncovered_texture, color: .clear, size: size)
    }
    
    convenience init() {
        self.init(row: 0, column: 0, size: CGSize(width: 16.0, height: 16.0));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addNeighbor(tile: Tile)
    {
        self.neighbors.append(tile);
    }
    
    public func setNeighbors(grid_width: Int, grid_height: Int, grid: [[Tile]]) {
        neighbors.removeAll();
        leftNeighbor = nil;
        rightNeighbor = nil
        topNeighbor = nil;
        bottomNeighbor = nil;
        
        if column - 1 >= 0 {
            //leftNeighbor = (self.parent as? GameScene)?.grid[row][column-1];
            leftNeighbor = grid[row][column-1];
            neighbors.append(leftNeighbor!)
        }
        
        
        if row - 1 >= 0 {
            //topNeighbor = (self.parent as? GameScene)?.grid[row-1][column];
            topNeighbor = grid[row-1][column];
            neighbors.append(topNeighbor!)
        }
        
        if row + 1 < grid_height {
           // bottomNeighbor = (self.parent as? GameScene)?.grid[row+1][column]
            bottomNeighbor = grid[row+1][column]

            neighbors.append(bottomNeighbor!);
        }
        
        if column + 1 < grid_width {
            //rightNeighbor = (self.parent as? GameScene)?.grid[row][column+1]
            rightNeighbor = grid[row][column+1]
            neighbors.append(rightNeighbor!)
        }
    }
    
    public func getRowTiles() -> [Tile] {
        
        var row_tiles:[Tile] = [];
        var iterator:Tile? = self;
        while(iterator?.leftNeighbor != nil) {
            iterator = iterator?.leftNeighbor;
        }
        
        while(iterator != nil) {
            row_tiles.append(iterator!);
            iterator = iterator?.rightNeighbor;
        }
        
        return row_tiles;
    }
    
    public func getColumnTiles() -> [Tile] {
        var column_tiles:[Tile] = [];
        var iterator:Tile? = self;
        while(iterator?.bottomNeighbor != nil) {
            iterator = iterator?.bottomNeighbor;
        }
        
        while(iterator != nil) {
            column_tiles.append(iterator!);
            iterator = iterator?.topNeighbor;
        }
        
        return column_tiles;
    }
    
    public func checkNeighbors(location: CGPoint) -> Tile? {
        for tile in neighbors {
            if tile.contains(location) {
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
    
    public func addLink(direction: direction) -> Link {
        let link_texture = SKTexture.init(imageNamed: "LinkCoverHead");
        let link_node = Link(texture: link_texture, size: self.size, direction: direction);
        link_node.zPosition = self.zPosition + 1;
        self.addChild(link_node);
        return link_node;
    }

}
