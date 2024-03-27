//
//  Helpers.swift
//  HeadwayNibblePlayerTest
//
//  Created by Демьян on 27.03.2024.
//

import Foundation

final class Helpers {
    
    static var isProduction: Bool {
        if Bundle.main.infoDictionary?["PROD_BUILD"] as? String == "NO" {
            return false
        } else {
            return true
        }
    }
}
