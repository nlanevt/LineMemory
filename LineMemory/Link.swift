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
    
    private func setDirection() {
        setDirection(direction: self.direction);
    }
    
    public func setDirection(direction: direction) {
        self.direction = direction;
        switch self.direction {
        case .left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeft");
            break;
        case .right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRight");
            break;
        case .up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUp");
            break;
        case .down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDown");
            break;
        case .left_up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeftUp");
            break;
        case .left_down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeftDown");
            break;
        case .right_up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRightUp");
            break;
        case .right_down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRightDown");
            break;
        case .up_left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUpLeft");
            break;
        case .up_right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUpRight");
            break;
        case .down_left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDownLeft");
            break;
        case .down_right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDownRight");
            break;
        case .none:
            self.texture = SKTexture.init(imageNamed: "LinkCoverHead");
            break;
        default:
            break;
        }
    }
    
    public func remove() {
        // run dissolving animations based off of direction.
        self.removeFromParent();
    }
    
    public func setAsHead() {
        self.texture = SKTexture.init(imageNamed: "LinkCoverHead");
    }
}
