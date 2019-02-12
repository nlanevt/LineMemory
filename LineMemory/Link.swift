//
//  Link.swift
//  LineMemory
//
//  Created by Nathan Lane on 2/11/19.
//  Copyright © 2019 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Link: SKSpriteNode {
    
    private var direction:direction = .none;
    
    init(texture: SKTexture, size: CGSize, direction: direction) {
        self.direction = direction;
        super.init(texture: texture, color: .clear, size: size);
        self.alpha = 0.5;
    }
    
    convenience init() {
        self.init(texture: SKTexture.init(imageNamed: "CoveredTile"), size: CGSize(width: 16, height: 16), direction: .up);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getDirection() -> direction {
        return direction;
    }
    
    public func setDirection(direction: direction) {
        self.direction = direction;
        switch self.direction {
        case .left:
            break;
        case .right:
            break;
        case .up:
            break;
        case .down:
            break;
        case .left_up:
            break;
        case .left_down:
            break;
        case .right_up:
            break;
        case .right_down:
            break;
        case .up_left:
            break;
        case .up_right:
            break;
        case .down_left:
            break;
        case .down_right:
            break;
        case .none:
            break;
        default:
            break;
        }
    }
    
    public func remove() {
        // run dissolving animations based off of direction.
        self.removeFromParent();
    }
}
