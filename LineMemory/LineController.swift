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
    
    init(grid_width: Int, grid_height: Int) {
        self.grid_width = grid_width;
        self.grid_height = grid_height;
    }
    
    public func generateLine(turn_count: Int) -> [CGPoint] {
        var list = createLine(turn_count: turn_count);
        
        while (list == nil) {list = createLine(turn_count: turn_count)}
        
        if (list != nil) {
            for i in 0..<list!.count {
                print("\(list![i])")
            }
        }
        
        return list!;
    }
    
    private func createLine(turn_count: Int) -> [CGPoint]? {
        
        let start_point = getRandomPoint();
        let start_edge = getClosestEdgeTo(point: start_point);
        if (start_point == start_edge) {return nil};
        
        var line_list = [start_edge];
        var turn_list = [direction]();
        
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
                turn_list.append(getDirectionBetween(pointA: line_list[line_list.count-2
                    ], pointB: line_list.last!))
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
        turn_list.append(getDirectionBetween(pointA: line_list[line_list.count-2
            ], pointB: line_list.last!))
        
        var end_point = getRandomPoint();
        while (end_point == start_point) {end_point = getRandomPoint()};
        let end_edge = getClosestEdgeTo(point: end_point);
        let end_dir = getDirectionBetween(pointA: end_point, pointB: end_edge)
        
        //TO DO
        //(1) Create turn list (containing random turns) from turn_count
        
        // Note: Below will end up being looped based off turn_count;
        for turn_counter in 0..<turn_count {
            let prev_dir = turn_list.last;
            var new_dir = direction.none;
            if (prev_dir == .left || prev_dir == .right) {
                new_dir = Int(arc4random_uniform(UInt32(2))) > 0 ? .up : .down;
            }
            else {
                new_dir = Int(arc4random_uniform(UInt32(2))) > 0 ? .left : .right;
            }
            
            let line_segment_length = (new_dir == .left || new_dir == .right) ? Int(arc4random_uniform(UInt32(grid_width-1)))+1 : Int(arc4random_uniform(UInt32(grid_height-1)))+1;
            
            for i in 0..<line_segment_length {
                var new_point = line_list.last;
                if (new_dir == .left) {
                    new_point = CGPoint(x: Int(new_point!.x-1), y: Int(new_point!.y))
                }
                else if (new_dir == .right) {
                    new_point = CGPoint(x: Int(new_point!.x+1), y: Int(new_point!.y))
                }
                else if (new_dir == .up) {
                    new_point = CGPoint(x: Int(new_point!.x), y: Int(new_point!.y-1))
                }
                else {
                    new_point = CGPoint(x: Int(new_point!.x), y: Int(new_point!.y+1))
                }
                
                if (new_point!.x < 0 || Int(new_point!.x) >= grid_width || new_point!.y < 0 || Int(new_point!.y) >= grid_height) {break}
                
                line_list.append(new_point!);
                turn_list.append(new_dir);
            }
        }
        
        //(3) Connect line_list with border
        
        var error_counter = 0;
        while (true) {
            let prev_point = line_list.last;
            let wall_point = getClosestEdgeTo(point: prev_point!);
            let prev_dir = turn_list.last;
            var new_dir = getDirectionBetween(pointA: prev_point!, pointB: wall_point);
            if (isOppositeDirection(dirA: prev_dir!, dirB: new_dir)) {
                if (prev_dir == .left || prev_dir == .right)
                {
                    new_dir = Int(arc4random_uniform(UInt32(2))) > 0 ? .up : .down;
                    if (new_dir == .up && Int(prev_point!.y) == 0) {
                        new_dir = .down;
                    }
                    else if (new_dir == .down && Int(prev_point!.y) == grid_height-1) {
                        new_dir = .up;
                    }
                }
                else if (prev_dir == .up || prev_dir == .down) {
                    new_dir = Int(arc4random_uniform(UInt32(2))) > 0 ? .left : .right;
                    if (new_dir == .left && Int(prev_point!.x) == 0) {
                        new_dir = .right;
                    }
                    else if (new_dir == .right && Int(prev_point!.x) == grid_width-1) {
                        new_dir = .left;
                    }
                }
                else {
                    return nil; // something fucked up.
                }
            }
            
            let new_point = (new_dir == .up) ? CGPoint(x: prev_point!.x, y: prev_point!.y-1) : (new_dir == .down) ? CGPoint(x: prev_point!.x, y: prev_point!.y+1) : (new_dir == .left) ? CGPoint(x: prev_point!.x-1, y: prev_point!.y) : (new_dir == .right) ? CGPoint(x: prev_point!.x+1, y: prev_point!.y) : prev_point;
            
            if (new_point == prev_point) {return nil; /*something fucked up*/}
            
            turn_list.append(new_dir);
            
            if (prev_point == wall_point || error_counter >= 1000) {break}
            
            line_list.append(new_point!);
            
            error_counter = error_counter + 1;
        }
        
        if (error_counter >= 1000) {return nil; /*somethign fucked up*/}
        
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
    
    private func getDirectionBetween(pointA: CGPoint, pointB: CGPoint) -> direction {
        if ((pointA.x == pointB.x && pointA.y == pointB.y) ||
            (pointA.x != pointB.x && pointA.y != pointB.y)) {
            
            /*if (isWallPoint(point: pointA) && isWallPoint(point: pointB)) {
                return .none;
            }
            else */if (Int(pointB.x) == 0) {
                return .left;
            }
            else if (Int(pointB.x) == grid_width-1) {
                return .right;
            }
            else if (Int(pointB.y) == 0) {
                return .up;
            }
            else if (Int(pointB.y) == grid_height-1) {
                return .down;
            }
            else {
                return .none;
            }
        }
        
        if (pointA.x == pointB.x) {
            if (pointA.y < pointB.y) {
                return .down;
            }
            else {
                return .up;
            }
        }
        
        if (pointA.y == pointB.y) {
            if (pointA.x < pointB.x) {
                return .right;
            }
            else {
                return .left;
            }
        }
        
        return .none;
    }
    
    private func isOppositeDirection(dirA: direction, dirB: direction) -> Bool {
        if (dirA == .up && dirB == .down ||
            dirA == .down && dirB == .up) {
            return true;
        }
        
        if (dirA == .left && dirB == .right ||
            dirA == .right && dirB == .left) {
            return true;
        }
        
        return false;
    }
    
    private func isWallPoint(point: CGPoint) -> Bool {
        if (Int(point.x) == 0 ||
            Int(point.x) == grid_width-1 ||
            Int(point.y) == 0 ||
            Int(point.y) == grid_height-1) {
            return true;
        }
        
        return false;
    }
    
}

