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
    
    init() {
        RoundShrinkFrames = buildAnimation(textureAtlasName: "RoundShrink");
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
}
