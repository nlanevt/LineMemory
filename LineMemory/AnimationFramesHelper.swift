//
//  AnimationFramesHelper.swift
//  LineMemory
//
//  Created by Nathan Lane on 3/20/19.
//  Copyright © 2019 Nathan Lane. All rights reserved.
//
import Foundation
import SpriteKit
import GameplayKit
import UIKit

class AnimationFramesHelper {
    public var RoundShrinkFrames = [SKTexture]();
    public var LinkCoverUp = [SKTexture]();
    public var LinkCoverUpLeft = [SKTexture]();
    public var LinkCoverUpRight = [SKTexture]();
    public var LinkCoverDown = [SKTexture]();
    public var LinkCoverDownLeft = [SKTexture]();
    public var LinkCoverDownRight = [SKTexture]();
    public var LinkCoverLeft = [SKTexture]();
    public var LinkCoverLeftUp = [SKTexture]();
    public var LinkCoverLeftDown = [SKTexture]();
    public var LinkCoverRight = [SKTexture]();
    public var LinkCoverRightUp = [SKTexture]();
    public var LinkCoverRightDown = [SKTexture]();
    
    public var LinkCoverUpDissipation = [SKTexture]();
    public var LinkCoverUpLeftDissipation = [SKTexture]();
    public var LinkCoverUpRightDissipation = [SKTexture]();
    public var LinkCoverDownDissipation = [SKTexture]();
    public var LinkCoverDownLeftDissipation = [SKTexture]();
    public var LinkCoverDownRightDissipation = [SKTexture]();
    public var LinkCoverLeftDissipation = [SKTexture]();
    public var LinkCoverLeftUpDissipation = [SKTexture]();
    public var LinkCoverLeftDownDissipation = [SKTexture]();
    public var LinkCoverRightDissipation = [SKTexture]();
    public var LinkCoverRightUpDissipation = [SKTexture]();
    public var LinkCoverRightDownDissipation = [SKTexture]();
        
    init() {
        RoundShrinkFrames = buildAnimation(textureAtlasName: "RoundShrink");
        
        LinkCoverUp = buildLinkAnimation(textureAtlasName: "LinkCoverUp")
        LinkCoverUpLeft = buildLinkAnimation(textureAtlasName: "LinkCoverUpLeft")
        LinkCoverUpRight = buildLinkAnimation(textureAtlasName: "LinkCoverUpRight");
        LinkCoverDown = buildLinkAnimation(textureAtlasName: "LinkCoverDown");
        LinkCoverDownLeft = buildLinkAnimation(textureAtlasName: "LinkCoverDownLeft");
        LinkCoverDownRight = buildLinkAnimation(textureAtlasName: "LinkCoverDownRight");
        LinkCoverLeft = buildLinkAnimation(textureAtlasName: "LinkCoverLeft");
        LinkCoverLeftUp = buildLinkAnimation(textureAtlasName: "LinkCoverLeftUp");
        LinkCoverLeftDown = buildLinkAnimation(textureAtlasName: "LinkCoverLeftDown");
        LinkCoverRight = buildLinkAnimation(textureAtlasName: "LinkCoverRight");
        LinkCoverRightUp = buildLinkAnimation(textureAtlasName: "LinkCoverRightUp");
        LinkCoverRightDown = buildLinkAnimation(textureAtlasName: "LinkCoverRightDown");
        
        LinkCoverUpDissipation = LinkCoverDown.reversed();
        LinkCoverUpLeftDissipation = LinkCoverRightDown.reversed();
        LinkCoverUpRightDissipation = LinkCoverLeftDown.reversed();
        LinkCoverDownDissipation = LinkCoverUp.reversed();
        LinkCoverDownLeftDissipation = LinkCoverRightUp.reversed();
        LinkCoverDownRightDissipation = LinkCoverLeftUp.reversed();
        LinkCoverLeftDissipation = LinkCoverRight.reversed();
        LinkCoverLeftUpDissipation = LinkCoverDownRight.reversed();
        LinkCoverLeftDownDissipation = LinkCoverUpRight.reversed();
        LinkCoverRightDissipation = LinkCoverLeft.reversed();
        LinkCoverRightUpDissipation = LinkCoverDownLeft.reversed();
        LinkCoverRightDownDissipation = LinkCoverUpLeft.reversed();
    }
    
    private func buildAnimation(textureAtlasName: String) -> [SKTexture]
    {
        let atlas = SKTextureAtlas(named: textureAtlasName);
        var frames: [SKTexture] = [];
        let numImages = atlas.textureNames.count
        for i in 1...numImages {
            let name = "\(textureAtlasName)\(i)"
            frames.append(atlas.textureNamed(name))
        }
        
        return frames;
    }
    
    private func buildLinkAnimation(textureAtlasName: String) -> [SKTexture]
    {
        let atlas = SKTextureAtlas(named: textureAtlasName);
        var frames: [SKTexture] = [];
        let numImages = atlas.textureNames.count-1
        for i in 1...numImages {
            let name = "\(textureAtlasName)\(i)"
            frames.append(atlas.textureNamed(name))
        }
        
        return frames;
    }
}
