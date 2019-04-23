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
    
    public func getDirectionPointing() -> direction {
        if (direction == .up || direction == .left_up || direction == .right_up) {
            return .up;
        }
        
        if (direction == .left || direction == .down_left || direction == .up_left) {
            return .left;
        }
        
        if (direction == .right || direction == .down_right || direction == .up_right) {
            return .right;
        }
        
        if (direction == .down || direction == .left_down || direction == .right_down) {
            return .down;
        }
        
        return .none;
    }
    
    private func setDirection() {
        setDirection(direction: self.direction);
    }
    
    public func setDirection(direction: direction) {
        self.direction = direction;
        switch self.direction {
        case .left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeft6");
            break;
        case .right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRight6");
            break;
        case .up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUp6");
            break;
        case .down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDown6");
            break;
        case .left_up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeftUp6");
            break;
        case .left_down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverLeftDown6");
            break;
        case .right_up:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRightUp6");
            break;
        case .right_down:
            self.texture = SKTexture.init(imageNamed: "LinkCoverRightDown6");
            break;
        case .up_left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUpLeft6");
            break;
        case .up_right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverUpRight6");
            break;
        case .down_left:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDownLeft6");
            break;
        case .down_right:
            self.texture = SKTexture.init(imageNamed: "LinkCoverDownRight6");
            break;
        case .none:
            self.texture = SKTexture.init(imageNamed: "LinkCoverHead");
            break;
        default:
            break;
        }
    }
    
    public func animateCreation(completion: @escaping ()->Void) {
        var animation_frames = [SKTexture]();
        var texture_name = "";
        self.texture = nil;
        switch self.direction {
        case .left:
            animation_frames = animation_frames_manager.LinkCoverLeft;
            texture_name = "LinkCoverLeft";
            break;
        case .right:
            animation_frames = animation_frames_manager.LinkCoverRight;
            texture_name = "LinkCoverRight";
            break;
        case .up:
            animation_frames = animation_frames_manager.LinkCoverUp;
            texture_name = "LinkCoverUp";
            break;
        case .down:
            animation_frames = animation_frames_manager.LinkCoverDown;
            texture_name = "LinkCoverDown";
            break;
        case .left_up:
            animation_frames = animation_frames_manager.LinkCoverLeftUp;
            texture_name = "LinkCoverLeftUp";
            break;
        case .left_down:
            animation_frames = animation_frames_manager.LinkCoverLeftDown;
            texture_name = "LinkCoverLeftDown";
            break;
        case .right_up:
            animation_frames = animation_frames_manager.LinkCoverRightUp;
            texture_name = "LinkCoverRightUp";
            break;
        case .right_down:
            animation_frames = animation_frames_manager.LinkCoverRightDown;
            texture_name = "LinkCoverRightDown";
            break;
        case .up_left:
            animation_frames = animation_frames_manager.LinkCoverUpLeft;
            texture_name = "LinkCoverUpLeft";
            break;
        case .up_right:
            animation_frames = animation_frames_manager.LinkCoverUpRight;
            texture_name = "LinkCoverUpRight";
            break;
        case .down_left:
            animation_frames = animation_frames_manager.LinkCoverDownLeft;
            texture_name = "LinkCoverDownLeft";
            break;
        case .down_right:
            animation_frames = animation_frames_manager.LinkCoverDownRight;
            texture_name = "LinkCoverDownRight";
            break;
        case .none:
            animation_frames = animation_frames_manager.LinkCoverUp;
            texture_name = "LinkCoverUp";
            break;
        default:
            break;
        }
        
        self.isHidden = false;
        texture_name = texture_name + "\(SKTextureAtlas(named: texture_name).textureNames.count)";
        
        self.run(SKAction.sequence([SKAction.animate(with: animation_frames, timePerFrame: 0.02),SKAction.setTexture(SKTexture.init(imageNamed: texture_name))]), completion: {
            [unowned self] in
            completion();
        })
    }
    
    public func animateDissipation(completion: @escaping ()->Void) {
        var animation_frames = [SKTexture]();
        var texture_name = "";
        //self.texture = nil;
        switch self.direction {
        case .left:
            animation_frames = animation_frames_manager.LinkCoverLeftDissipation;
            texture_name = "LinkCoverLeft";
            break;
        case .right:
            animation_frames = animation_frames_manager.LinkCoverRightDissipation;
            texture_name = "LinkCoverRight";
            break;
        case .up:
            animation_frames = animation_frames_manager.LinkCoverUpDissipation;
            texture_name = "LinkCoverUp";
            break;
        case .down:
            animation_frames = animation_frames_manager.LinkCoverDownDissipation;
            texture_name = "LinkCoverDown";
            break;
        case .left_up:
            animation_frames = animation_frames_manager.LinkCoverLeftUpDissipation;
            texture_name = "LinkCoverLeftUp";
            break;
        case .left_down:
            animation_frames = animation_frames_manager.LinkCoverLeftDownDissipation;
            texture_name = "LinkCoverLeftDown";
            break;
        case .right_up:
            animation_frames = animation_frames_manager.LinkCoverRightUpDissipation;
            texture_name = "LinkCoverRightUp";
            break;
        case .right_down:
            animation_frames = animation_frames_manager.LinkCoverRightDownDissipation;
            texture_name = "LinkCoverRightDown";
            break;
        case .up_left:
            animation_frames = animation_frames_manager.LinkCoverUpLeftDissipation;
            texture_name = "LinkCoverUpLeft";
            break;
        case .up_right:
            animation_frames = animation_frames_manager.LinkCoverUpRightDissipation;
            texture_name = "LinkCoverUpRight";
            break;
        case .down_left:
            animation_frames = animation_frames_manager.LinkCoverDownLeftDissipation;
            texture_name = "LinkCoverDownLeft";
            break;
        case .down_right:
            animation_frames = animation_frames_manager.LinkCoverDownRightDissipation;
            texture_name = "LinkCoverDownRight";
            break;
        case .none:
            animation_frames = animation_frames_manager.LinkCoverUpDissipation;
            texture_name = "LinkCoverUp";
            break;
        default:
            break;
        }
        
        texture_name = texture_name + "\(SKTextureAtlas(named: texture_name).textureNames.count)";
        
        self.run(SKAction.sequence([SKAction.unhide(), SKAction.animate(with: animation_frames, timePerFrame: 0.02), SKAction.hide()]), completion: {
            [unowned self] in
            self.removeFromParent();
            completion();
        })
    }
    
    public func remove() {
        // run dissolving animations based off of direction.
        self.removeFromParent();
    }
    
    public func setAsHead() {
        self.texture = SKTexture.init(imageNamed: "LinkCoverHead");
    }
}
