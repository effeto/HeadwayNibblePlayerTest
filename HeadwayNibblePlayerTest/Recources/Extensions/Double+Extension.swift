//
//  Double+Extension.swift
//  HeadwayNibbleTest
//
//  Created by Демьян on 27.03.2024.
//

import Foundation

extension Double {
    func asString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? ""
    }
}
