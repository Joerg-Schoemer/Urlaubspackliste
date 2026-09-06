//
//  Item.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
