//
//  LevelController.swift
//  Line Memory
//
//  Created by Nathan Lane on 01/08/2019.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class LevelController {
    private var level_counter:Int64 = 1;
    private var rounds_won_counter:Int = 0;
    private var rounds_default:Int = 8;
    private var lives_default = 5;
    private var lives_counter = 5;
    private var level_scores = [Int64]();
    private var score_reduction:Int64 = 0;
    private var level_score:Int64 = 0;
    private var max_level = 256;
    private var did_beat_game = false;
    private var total_score:Int64 = 0;
    
    init() {
        rounds_won_counter = 0;
        level_score = 0;
        lives_counter = lives_default;
        setRoundsAmount(); 
    }
    
    deinit {
        print("Level Controller has been deallocated");
    }
    
    /*
     * Current Level
     */
    public func level() -> Int64 {
        return level_counter;
    }
    
    /*
     * Current Score
     */
    public func score() -> Int64 {
        return total_score;
    }
    
    public func getLevelsBeaten() -> Int64 {
        return level_counter - 1;
    }
    
    public func getLevelRounds() -> Int {
        return rounds_default;
    }
    
    public func getLivesPerLevel() -> Int {
        return lives_default;
    }
    
    public func getLivesLeft() -> Int {
        return lives_counter;
    }
    
    public func getMaximumLevel() -> Int {
        return max_level;
    }
    
    public func didBeatGame() -> Bool {
        return did_beat_game;
    }
    
    public func setStartingValues(starting_level: Int64, starting_score: Int64) {
        level_counter = starting_level > max_level ? 1 : starting_level;
        total_score = starting_score < 0 ? 0 : starting_score;
    }
    
    public func getTurns() -> Int {
        switch level_counter {
        case 1:
            return 1
        case 2:
            return getRandomNumber(int_a: 1, int_b: 2);
        case 3:
            return createDifficulty(difficulty_a: 1, difficulty_b: getRandomNumber(int_a: 1, int_b: 2), difficulty_c: 3)
        case 4:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: 2, difficulty_c: 3)
        case 5:
            return getRandomNumber(int_a: 2, int_b: 3);
        case 6:
            return createDifficulty(difficulty_a: 2, difficulty_b: 3, difficulty_c: 3)
        case 7:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: 3, difficulty_c: 4);
        case 8:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: getRandomNumber(int_a: 2, int_b: 3), difficulty_c: 4);
        case 9:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: 3, difficulty_c: 4);
        case 10:
            return getRandomNumber(int_a: 3, int_b: 4);
        case 11:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: 3);
        case 12:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2),
                                    difficulty_b: 3,
                                    difficulty_c: 4);
        case 13:
            return getRandomNumber(int_a: 2, int_b: 3, int_c: 5);
        case 14:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: 4)
        case 15:
            return getRandomNumber(int_a: 4, int_b: 5);
        case 16:
            return getRandomNumber(int_a: 3, int_b: 4, int_c: 5);
        case 17:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 3, int_b: 4), difficulty_c: getRandomNumber(int_a: 5, int_b: 6));
        case 18:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: getRandomNumber(int_a: 3, int_b: 4))
        case 19:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: 5, difficulty_c: 6);
        case 20:
            return getRandomNumber(int_a: 5, int_b: 6);
        case 21:
            return getRandomNumber(int_a: 2, int_b: 3);
        case 22:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3),
                                    difficulty_b: 4,
                                    difficulty_c: 5);
        case 23:
            return getRandomNumber(int_a: 3, int_b: 4);
        case 24:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: 5);
        case 25:
            return getRandomNumber(int_a: 6, int_b: 7);
        case 26:
            return getRandomNumber(int_a: 5, int_b: 6, int_c: 7);
        case 27:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: getRandomNumber(int_a: 3, int_b: 4), difficulty_c: getRandomNumber(int_a: 4, int_b: 5));
        case 28:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: getRandomNumber(int_a: 4, int_b: 5));
        case 29:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 4, int_b: 5), difficulty_b: 6, difficulty_c: 7);
        case 30:
            return getRandomNumber(int_a: 7, int_b: 8);
        case 31:
            return getRandomNumber(int_a: 3, int_b: 4);
        case 32:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4),
                                    difficulty_b: 5,
                                    difficulty_c: 6);
        case 33:
            return getRandomNumber(int_a: 5, int_b: 6);
        case 34:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 4, int_b: 5), difficulty_b: 6);
        case 35:
            return getRandomNumber(int_a: 8, int_b: 9);
        case 36:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 2, int_b: 3), difficulty_b: getRandomNumber(int_a: 6, int_b: 7, int_c: 8))
        case 37:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: getRandomNumber(int_a: 4, int_b: 5), difficulty_c: getRandomNumber(int_a: 5, int_b: 6));
        case 38:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 4, int_b: 5), difficulty_b: getRandomNumber(int_a: 5, int_b: 6));
        case 39:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: 7, difficulty_c: 8);
        case 40:
            return getRandomNumber(int_a: 9, int_b: 10);
        case 41:
            return getRandomNumber(int_a: 4, int_b: 5);
        case 42:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 4, int_b: 5),
                                    difficulty_b: 6,
                                    difficulty_c: 7);
        case 43:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: 7);
        case 44:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: 9);
        case 45:
            return getRandomNumber(int_a: 10, int_b: 11);
        case 46:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 7, int_b: 8, int_c: 9))
        case 47:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 4, int_b: 5), difficulty_b: getRandomNumber(int_a: 5, int_b: 6), difficulty_c: getRandomNumber(int_a: 6, int_b: 7));
        case 48:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: getRandomNumber(int_a: 6, int_b: 7));
        case 49:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: 8, difficulty_c: 9);
        case 50:
            return getRandomNumber(int_a: 11, int_b: 12);
        case 51:
            return getRandomNumber(int_a: 11, int_b: 12);
        case 52:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6),
                                    difficulty_b: 7,
                                    difficulty_c: 8);
        case 53:
            return getRandomNumber(int_a: 6, int_b: 7);
        case 54:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: 8, difficulty_c: 10);
        case 55:
            return getRandomNumber(int_a: 12, int_b: 13);
        case 56:
            return getRandomNumber(int_a: 11, int_b: 12);
        case 57:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: getRandomNumber(int_a: 6, int_b: 7), difficulty_c: getRandomNumber(int_a: 7, int_b: 8));
        case 58:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: getRandomNumber(int_a: 7, int_b: 8), difficulty_c: 11);
        case 59:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 8), difficulty_b: 9, difficulty_c: 10);
        case 60:
            return getRandomNumber(int_a: 13, int_b: 14);
        case 61:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 6, int_b: 7));
        case 62:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: 8, difficulty_c: 9);
        case 63:
            return getRandomNumber(int_a: 7, int_b: 8);
        case 64:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 8), difficulty_b: 9);
        case 65:
            return getRandomNumber(int_a: 14, int_b: 15);
        case 66:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 5), difficulty_b: getRandomNumber(int_a: 9, int_b: 10, int_c: 11));
        case 67:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: getRandomNumber(int_a: 7, int_b: 8), difficulty_c: getRandomNumber(int_a: 8, int_b: 9));
        case 68:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 8), difficulty_b: getRandomNumber(int_a: 12, int_b: 13));
        case 69:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: 10, difficulty_c: 14);
        case 70:
            return getRandomNumber(int_a: 15, int_b: 16)
        case 71:
            return 2;
        case 72:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 8), difficulty_b: 9, difficulty_c: 10);
        case 73:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: 12);
        case 74:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: 15);
        case 75:
            return getRandomNumber(int_a: 16, int_b: 17);
        case 76:
            return getRandomNumber(int_a: 15, int_b: 16);
        case 77:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 8), difficulty_b: getRandomNumber(int_a: 8, int_b: 9), difficulty_c: getRandomNumber(int_a: 9, int_b: 10));
        case 78:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: getRandomNumber(int_a: 9, int_b: 10));
        case 79:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 9, int_b: 10), difficulty_b: 11, difficulty_c: 12);
        case 80:
            return getRandomNumber(int_a: 17, int_b: 18);
        case 81:
            return getRandomNumber(int_a: 8, int_b: 9);
        case 82:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: 10, difficulty_c: 11);
        case 83:
            return getRandomNumber(int_a: 2, int_b: 5, int_c: 12);
        case 84:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 9, int_b: 10), difficulty_b: 15, difficulty_c: 17);
        case 85:
            return getRandomNumber(int_a: 18, int_b: 19);
        case 86:
            return getRandomNumber(int_a: 11, int_b: 15, int_c: 17);
        case 87:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 8, int_b: 9), difficulty_b: getRandomNumber(int_a: 9, int_b: 10), difficulty_c: getRandomNumber(int_a: 10, int_b: 11));
        case 88:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: getRandomNumber(int_a: 10, int_b: 11));
        case 89:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: 12, difficulty_c: 17);
        case 90:
            return getRandomNumber(int_a: 19, int_b: 20);
        case 91:
            return getRandomNumber(int_a: 9, int_b: 10);
        case 92:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 9, int_b: 10), difficulty_b: 11, difficulty_c: 12);
        case 93:
            return getRandomNumber(int_a: 10, int_b: 11);
        case 94:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: 12);
        case 95:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 2, int_b: 3), difficulty_c: getRandomNumber(int_a: 20, int_b: 21));
        case 96:
            return getRandomNumber(int_a: 12, int_b: 13, int_c: 14);
        case 97:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: getRandomNumber(int_a: 10, int_b: 11), difficulty_c: getRandomNumber(int_a: 19, int_b: 20));
        case 98:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: getRandomNumber(int_a: 11, int_b: 12));
        case 99:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: 13, difficulty_c: 14);
        case 100:
            return getRandomNumber(int_a: 21, int_b: 22);
        case 101:
            return getRandomNumber(int_a: 21, int_b: 22);
        case 102:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: 12, difficulty_c: 13);
        case 103:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: 17);
        case 104:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: 19);
        case 105:
            return getRandomNumber(int_a: 22, int_b: 23);
        case 106:
            return getRandomNumber(int_a: 3, int_b: 14, int_c: 15);
        case 107:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: getRandomNumber(int_a: 11, int_b: 12), difficulty_c: getRandomNumber(int_a: 12, int_b: 13));
        case 108:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: getRandomNumber(int_a: 12, int_b: 13));
        case 109:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 12, int_b: 13), difficulty_b: 14, difficulty_c: 15);
        case 110:
            return getRandomNumber(int_a: 23, int_b: 24);
        case 111:
            return getRandomNumber(int_a: 11, int_b: 12);
        case 112:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: 13, difficulty_c: 14);
        case 113:
            return getRandomNumber(int_a: 17, int_b: 18);
        case 114:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 12, int_b: 13), difficulty_b: 14);
        case 115:
            return getRandomNumber(int_a: 24, int_b: 25);
        case 116:
            return getRandomNumber(int_a: 14, int_b: 15, int_c: 16);
        case 117:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 11, int_b: 12), difficulty_b: getRandomNumber(int_a: 12, int_b: 13), difficulty_c: getRandomNumber(int_a: 13, int_b: 14));
        case 118:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 12, int_b: 13), difficulty_b: getRandomNumber(int_a: 13, int_b: 14));
        case 119:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 13, int_b: 14), difficulty_b: 15, difficulty_c: 20);
        case 120:
            return getRandomNumber(int_a: 25, int_b: 26);
        case 121:
            return getRandomNumber(int_a: 12, int_b: 13);
        case 122:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 12, int_b: 13), difficulty_b: 14, difficulty_c: 15);
        case 123:
            return getRandomNumber(int_a: 13, int_b: 14);
        case 124:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 13, int_b: 14), difficulty_b: 15);
        case 125:
            return getRandomNumber(int_a: 26, int_b: 27);
        case 126:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 10, int_b: 12));
        case 127:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 12, int_b: 13), difficulty_b: getRandomNumber(int_a: 13, int_b: 14), difficulty_c: getRandomNumber(int_a: 14, int_b: 15));
        case 128:
            return 6;
        case 129:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 5, int_b: 6), difficulty_b: getRandomNumber(int_a: 14, int_b: 15), difficulty_c: 17);
        case 130:
            return getRandomNumber(int_a: 27, int_b: 28);
        case 131:
            return getRandomNumber(int_a: 13, int_b: 14);
        case 132:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 13, int_b: 14), difficulty_b: 15, difficulty_c: 16);
        case 133:
            return getRandomNumber(int_a: 14, int_b: 15);
        case 134:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 14, int_b: 15), difficulty_b: 16);
        case 135:
            return getRandomNumber(int_a: 28, int_b: 29);
        case 136:
            return getRandomNumber(int_a: 16, int_b: 17, int_c: 18);
        case 137:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 14, int_b: 15), difficulty_c: getRandomNumber(int_a: 15, int_b: 16));
        case 138:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 14, int_b: 15), difficulty_b: getRandomNumber(int_a: 15, int_b: 16));
        case 139:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 15, int_b: 16), difficulty_b: 17, difficulty_c: 18);
        case 140:
            return getRandomNumber(int_a: 29, int_b: 30);
        case 141:
            return getRandomNumber(int_a: 14, int_b: 15);
        case 142:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 14, int_b: 15), difficulty_b: 16, difficulty_c: 17);
        case 143:
            return 2
        case 144:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 15, int_b: 16), difficulty_b: 17);
        case 145:
            return getRandomNumber(int_a: 30, int_b: 31);
        case 146:
            return getRandomNumber(int_a: 20, int_b: 25);
        case 147:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 14, int_b: 15), difficulty_b: getRandomNumber(int_a: 15, int_b: 16), difficulty_c: getRandomNumber(int_a: 16, int_b: 17));
        case 148:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 15, int_b: 16), difficulty_b: getRandomNumber(int_a: 16, int_b: 17));
        case 149:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 16, int_b: 17), difficulty_b: 18, difficulty_c: 19);
        case 150:
            return getRandomNumber(int_a: 31, int_b: 32);
        case 151:
            return getRandomNumber(int_a: 15, int_b: 16);
        case 152:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 15, int_b: 16), difficulty_b: 17, difficulty_c: 18);
        case 153:
            return getRandomNumber(int_a: 26, int_b: 27);
        case 154:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 16, int_b: 17), difficulty_b: 18);
        case 155:
            return getRandomNumber(int_a: 32, int_b: 33);
        case 156:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 3, int_b: 4), difficulty_b: getRandomNumber(int_a: 7, int_b: 8), difficulty_c: getRandomNumber(int_a: 19, int_b: 20));
        case 157:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 15, int_b: 16), difficulty_b: getRandomNumber(int_a: 16, int_b: 17), difficulty_c: getRandomNumber(int_a: 17, int_b: 18));
        case 158:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 16, int_b: 17), difficulty_b: 17, difficulty_c: 18)
        case 159:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 17, int_b: 18), difficulty_b: 19, difficulty_c: 30);
        case 160:
            return getRandomNumber(int_a: 33, int_b: 34);
        case 161:
            return getRandomNumber(int_a: 16, int_b: 17);
        case 162:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 16, int_b: 17), difficulty_b: 18, difficulty_c: 19)
        case 163:
            return getRandomNumber(int_a: 3, int_b: 5);
        case 164:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 17, int_b: 18), difficulty_b: 19)
        case 165:
            return getRandomNumber(int_a: 34, int_b: 35);
        case 166:
            return createDifficulty(difficulty_a: 1, difficulty_b: getRandomNumber(int_a: 5, int_b: 19, int_c: 21))
        case 167:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 16, int_b: 17), difficulty_b: getRandomNumber(int_a: 17, int_b: 18), difficulty_c: getRandomNumber(int_a: 18, int_b: 19))
        case 168:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 7, int_b: 18), difficulty_b: getRandomNumber(int_a: 18, int_b: 19))
        case 169:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 18, int_b: 19), difficulty_b: 20, difficulty_c: 21);
        case 170:
            return getRandomNumber(int_a: 35, int_b: 36);
        case 171:
            return createDifficulty(difficulty_a: 1, difficulty_b: 2, difficulty_c: 3)
        case 172:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 17, int_b: 18), difficulty_b: 19, difficulty_c: 20)
        case 173:
            return getRandomNumber(int_a: 18, int_b: 19);
        case 174:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 18, int_b: 19), difficulty_b: 20)
        case 175:
            return createDifficulty(difficulty_a: 20, difficulty_b: getRandomNumber(int_a: 36, int_b: 37));
        case 176:
            return getRandomNumber(int_a: 20, int_b: 21, int_c: 22);
        case 177:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 17, int_b: 18), difficulty_b: getRandomNumber(int_a: 18, int_b: 19), difficulty_c: getRandomNumber(int_a: 19, int_b: 20))
        case 178:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 18, int_b: 19), difficulty_b: 30)
        case 179:
            return getRandomNumber(int_a: 2, int_b: 20)
        case 180:
            return getRandomNumber(int_a: 37, int_b: 38)
        case 181:
            return getRandomNumber(int_a: 1, int_b: 3)
        case 182:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 18, int_b: 19), difficulty_c: 30)
        case 183:
            return getRandomNumber(int_a: 19, int_b: 20)
        case 184:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 19, int_b: 20), difficulty_b: 21)
        case 185:
            return getRandomNumber(int_a: 38, int_b: 39)
        case 186:
            return 25
        case 187:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 18, int_b: 19), difficulty_b: getRandomNumber(int_a: 19, int_b: 20), difficulty_c: getRandomNumber(int_a: 20, int_b: 21))
        case 188:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 10, int_b: 11), difficulty_b: getRandomNumber(int_a: 20, int_b: 21))
        case 189:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 20, int_b: 21), difficulty_b: 22, difficulty_c: 23)
        case 190:
            return getRandomNumber(int_a: 39, int_b: 40)
        case 191:
            return getRandomNumber(int_a: 19, int_b: 20)
        case 192:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 19, int_b: 20), difficulty_b: 21, difficulty_c: 22)
        case 193:
            return getRandomNumber(int_a: 5, int_b: 6)
        case 194:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 6, int_b: 7), difficulty_b: getRandomNumber(int_a: 20, int_b: 21), difficulty_c: 27)
        case 195:
            return getRandomNumber(int_a: 40, int_b: 41)
        case 196:
            return getRandomNumber(int_a: 22, int_b: 23, int_c: 24)
        case 197:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 7, int_b: 8))
        case 198:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 20, int_b: 21), difficulty_b: getRandomNumber(int_a: 4, int_b: 22))
        case 199:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 21, int_b: 22), difficulty_b: 25, difficulty_c: 35)
        case 200:
            return getRandomNumber(int_a: 41, int_b: 42)
        case 201:
            return getRandomNumber(int_a: 41, int_b: 42)
        case 202:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 20, int_b: 21), difficulty_b: 22, difficulty_c: 23)
        case 203:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 21, int_b: 22), difficulty_b: getRandomNumber(int_a: 30, int_b: 31))
        case 204:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 31, int_b: 32), difficulty_b: 40)
        case 205:
            return getRandomNumber(int_a: 42, int_b: 43)
        case 206:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 23, int_b: 24, int_c: 25), difficulty_b: 40)
        case 207:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 20, int_b: 21), difficulty_b: getRandomNumber(int_a: 21, int_b: 22), difficulty_c: getRandomNumber(int_a: 22, int_b: 23))
        case 208:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 21, int_b: 22), difficulty_b: getRandomNumber(int_a: 22, int_b: 23), difficulty_c: getRandomNumber(int_a: 30, int_b: 35))
        case 209:
            return getRandomNumber(int_a: 20, int_b: 40)
        case 210:
            return getRandomNumber(int_a: 43, int_b: 44)
        case 211:
            return getRandomNumber(int_a: 21, int_b: 22)
        case 212:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 21, int_b: 22), difficulty_b: 30, difficulty_c: 40)
        case 213:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 22, int_b: 23), difficulty_b: getRandomNumber(int_a: 30, int_b: 40))
        case 214:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 22, int_b: 23), difficulty_b: 25, difficulty_c: 30)
        case 215:
            return getRandomNumber(int_a: 44, int_b: 45)
        case 216:
            return getRandomNumber(int_a: 35, int_b: 45)
        case 217:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 21, int_b: 22), difficulty_b: getRandomNumber(int_a: 31, int_b: 32), difficulty_c: getRandomNumber(int_a: 41, int_b: 42))
        case 218:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 30, int_b: 40), difficulty_b: getRandomNumber(int_a: 35, int_b: 45))
        case 219:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 23, int_b: 24), difficulty_b: 38, difficulty_c: 42)
        case 220:
            return getRandomNumber(int_a: 45, int_b: 46)
        case 221:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 1, int_b: 2), difficulty_b: getRandomNumber(int_a: 3, int_b: 4), difficulty_c: 30)
        case 222:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 22, int_b: 23), difficulty_b: getRandomNumber(int_a: 2, int_b: 24), difficulty_c: 45)
        case 223:
            return getRandomNumber(int_a: 35, int_b: 40)
        case 224:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 23, int_b: 24), difficulty_b: 40)
        case 225:
            return getRandomNumber(int_a: 46, int_b: 47)
        case 226:
            return getRandomNumber(int_a: 45, int_b: 46, int_c: 47)
        case 227:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 22, int_b: 23), difficulty_b: getRandomNumber(int_a: 23, int_b: 24), difficulty_c: getRandomNumber(int_a: 24, int_b: 25))
        case 228:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 23, int_b: 24), difficulty_b: getRandomNumber(int_a: 30, int_b: 35), difficulty_c: 45)
        case 229:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 24, int_b: 25), difficulty_b: 36, difficulty_c: 46)
        case 230:
            return getRandomNumber(int_a: 47, int_b: 48)
        case 231:
            return getRandomNumber(int_a: 23, int_b: 24)
        case 232:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 23, int_b: 24), difficulty_b: 38, difficulty_c: 48)
        case 233:
            return getRandomNumber(int_a: 24, int_b: 25)
        case 234:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 24, int_b: 30), difficulty_b: 40)
        case 235:
            return getRandomNumber(int_a: 48, int_b: 49)
        case 236:
            return getRandomNumber(int_a: 48, int_b: 49)
        case 237:
            return getRandomNumber(int_a: 48, int_b: 49)
        case 238:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 24, int_b: 25), difficulty_b: getRandomNumber(int_a: 40, int_b: 45))
        case 239:
            return createDifficulty(difficulty_a: getRandomNumber(int_a: 25, int_b: 26), difficulty_b: 45, difficulty_c: 48)
        case 240:
            return getRandomNumber(int_a: 49, int_b: 50)
        case 241:
            return getRandomNumber(int_a: 50, int_b: 51)
        case 242:
            return getRandomNumber(int_a: 51, int_b: 52)
        case 243:
            return getRandomNumber(int_a: 52, int_b: 53)
        case 244:
            return getRandomNumber(int_a: 53, int_b: 54)
        case 245:
            return 54
        case 246:
            return getRandomNumber(int_a: 54, int_b: 55)
        case 247:
            return 55
        case 248:
            return getRandomNumber(int_a: 55, int_b: 56)
        case 249:
            return getRandomNumber(int_a: 56, int_b: 57)
        case 250:
            return getRandomNumber(int_a: 57, int_b: 58)
        case 251:
            return getRandomNumber(int_a: 58, int_b: 59)
        case 252:
            return getRandomNumber(int_a: 59, int_b: 60)
        case 253:
            return getRandomNumber(int_a: 60, int_b: 61)
        case 254:
            return getRandomNumber(int_a: 61, int_b: 62)
        case 255:
            return getRandomNumber(int_a: 62, int_b: 63)
            //return 1;
        case 256:
            return 64;
            //return 1; // MARK: For testing final level
        default:
            return 0;
        }
    }
    
    private func createDifficulty(difficulty_a: Int, difficulty_b: Int, difficulty_c: Int) -> Int {
        if (rounds_won_counter < rounds_default / 3) {
            return difficulty_a;
        }
        else if (rounds_won_counter < (rounds_default*2)/3) {
            return difficulty_b;
        }
        else {
            return difficulty_c;
        }
    }
    
    private func createDifficulty(difficulty_a: Int, difficulty_b: Int) -> Int {
        if (rounds_won_counter < rounds_default / 2) {
            return difficulty_a;
        }
        else {
            return difficulty_b;
        }
    }
    
    private func getRandomNumber(int_a: Int, int_b: Int) -> Int {
        return Int(arc4random_uniform(UInt32(2))) > 0 ? int_a : int_b;
    }
    
    private func getRandomNumber(int_a: Int, int_b: Int, int_c: Int) -> Int {
        return Int(arc4random_uniform(UInt32(3))) == 0 ? int_a : Int(arc4random_uniform(UInt32(2))) > 0 ? int_b : int_c;
    }
    
    public func getTimerMultiplier() -> TimeInterval {
        if (level_counter <= 50) {
            return 3.0;
        }
        else if (level_counter <= 100) {
            return 2.0;
        }
        else if (level_counter <= 150){
            return 1.5;
        }
        else {
            return 1.0;
        }
    }
    
    // Returns true if the level was increased
    // Returns false if the level wasn't increased
    public func roundWonAndIncreaseLevel(by_amount: Int64) -> Bool {
        rounds_won_counter = rounds_won_counter + 1;
        level_score = level_score + by_amount;
        if (rounds_won_counter == rounds_default) {
            increaseLevel(score: level_score);
            rounds_won_counter = 0;
            lives_counter = getLivesPerLevel();
            return true;
        }
        return false;
    }
    
    public func roundLost() -> Bool {
        lives_counter = lives_counter - 1;
        if (lives_counter <= 0) {
            undoLevel();
            lives_counter = getLivesPerLevel();
            return true;
        }
        
        return false;
    }
    
    public func increaseScoreBy(amount: Int64) {
        total_score = total_score + amount;
    }
    
    public func decreaseScoreBy(amount: Int64) {
        total_score = (total_score - amount) >= 0 ? total_score - amount : 0;
    }
    
    public func getRoundsLeft() -> Int {
        let result = getLevelRounds() - rounds_won_counter;
        return result;
    }
    
    public func getScoreReduction() -> Int64 {
        return score_reduction;
    }
    
    private func increaseLevel(score: Int64) {
        if (level_counter >= 256) {
            did_beat_game = true;
            return;
        }
        level_counter = level_counter + 1;
        level_score = 0;
        level_scores.append(score);
        setRoundsAmount();
    }
    
    private func setRoundsAmount() {
        if (level_counter <= 50) {
            rounds_default = 8;
        }
        else if (level_counter <= 100) {
            rounds_default = 9;
        }
        else if (level_counter <= 150) {
            rounds_default = 10;
        }
        else if (level_counter <= 200) {
            rounds_default = 11;
        }
        else if (level_counter <= 250) {
            rounds_default = 12;
        }
        else {
            rounds_default = 13;
        }
    }
    
    private func undoLevel() {
       /* if (level_counter > 1) {
           // score_reduction = level_score + level_scores.popLast()!;
            level_counter = level_counter - 1;
        }
        else {
            level_counter = 1;
            score_reduction = level_score;
        }*/
        score_reduction = level_score
        setRoundsAmount();
        rounds_won_counter = 0;
        level_score = 0;
    }
}
