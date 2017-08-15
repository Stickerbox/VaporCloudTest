//
//  Alexa+Extensions.swift
//  AlexaSkillExample
//
//  Created by Jordan.Dixon on 14/08/2017.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
