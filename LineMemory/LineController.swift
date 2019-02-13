//
//  LineController.swift
//  LineMemory
//
//  Created by Nathan Lane on 2/12/19.
//  Copyright © 2019 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class LineController {
    private var grid_width = 8;
    private var grid_height = 8;
    private var turn_list = [direction]();
    
    init(grid_width: Int, grid_height: Int) {
        self.grid_width = grid_width;
        self.grid_height = grid_height;
    }
    
    public func generateLine(turn_count: Int) {
        let list = createLine(turn_count: turn_count);
        if (list != nil) {
            for i in 0..<list!.count {
                print("\(list![i])")
            }
        }
    }
    
    private func createLine(turn_count: Int) -> [CGPoint]? {
        
        let start_point = getRandomPoint();
        let start_edge = getClosestEdgeTo(point: start_point);
        if (start_point == start_edge) {return nil};
        
        var line_list = [start_edge];
        
        print("start_edge: \(start_edge), start_point: \(start_point)");
        if (start_edge.x == start_point.x) {
            var incrementer = 1;
            var length = Int(start_point.y) - Int(start_edge.y);
            if (start_edge.y > start_point.y) {
                incrementer = -1;
                length = -1 * length;
            }
            
            
            for i in 0..<length-1 {
                line_list.append(CGPoint(x: Int(start_edge.x), y: Int(start_edge.y)+incrementer))
            }
            
        }
        else if (start_edge.y == start_point.y) {
            var incrementer = 1;
            var length = Int(start_point.x) - Int(start_edge.x);
            if (start_edge.x > start_point.x) {
                incrementer = -1;
                length = -1 * length;
            }
            
            for i in 0..<length-1 {
                line_list.append(CGPoint(x: Int(start_edge.x)+incrementer, y: Int(start_edge.y)))
            }
        }
        else {
            return nil; // something fucked up. not supposed to happen.
        }
        
        line_list.append(start_point);
        
        var end_point = getRandomPoint();
        while (end_point == start_point) {end_point = getRandomPoint()};
        let end_edge = getClosestEdgeTo(point: end_point);
        
        //TO DO
        //(1) Create turn list (containing random turns) from turn_count
        //(2) Create line with turn list, adding the points to line_list
        //(3) Add the end_point and end_edge points to line_list
        
        return line_list;
    }
    
    private func getRandomPoint() -> CGPoint {
        var random_x = Int(arc4random_uniform(UInt32(grid_width)));
        if (random_x <= 0) {random_x = 1}
        else if (random_x >= grid_width-1) {random_x = grid_width-2}
        
        var random_y = Int(arc4random_uniform(UInt32(grid_height)));
        if (random_y <= 0) {random_y = 1}
        else if (random_y >= grid_height-1) {random_y = grid_height-2}
        
        return CGPoint(x: random_x, y: random_y);
    }
    
    private func getClosestEdgeTo(point: CGPoint) -> CGPoint {
        // top border       (0, 0) to               (grid_width - 1, 0)
        // bottom border    (0, grid_height - 1) to (grid_width - 1, grid_height - 1)
        // left border      (0, 0) to               (0, grid_height - 1)
        // right border     (grid_width - 1, 0) to  (grid_width - 1, grid_height - 1)
        let top_distance = Int(point.y - 0);
        let bottom_distance = grid_height - 1 - Int(point.y);
        let left_distance = Int(point.x - 0);
        let right_distance = grid_width - 1 - Int(point.x);
        
        let distances = [top_distance, bottom_distance, left_distance, right_distance];
        
        var smallest_distance = distances[0];
        var sd_index = 0;
        for i in 0..<4 {
            if (distances[i] <= smallest_distance) {
                if (smallest_distance == distances[i]) {
                    sd_index = Int(arc4random_uniform(UInt32(2))) > 0 ? sd_index : i;
                }
                else {
                    sd_index = i;
                    smallest_distance = distances[i];
                }
            }
        }
        
        switch sd_index {
        case 0:
            return CGPoint(x: Int(point.x), y: 0);
        case 1:
            return CGPoint(x: Int(point.x), y: grid_height-1);
        case 2:
            return CGPoint(x: 0, y: Int(point.y));
        case 3:
            return CGPoint(x: grid_width-1, y: Int(point.y));
        default:
            return CGPoint(x: Int(point.x), y: 0);
        }
    }
    
}

