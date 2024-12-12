//
//  ScrollPositionPreferenceKey.swift
//  Polaris
//
//  Created by Kevin Perez on 12/11/24.
//


// Create new file: ScrollPositionTypes.swift

import SwiftUI

struct ScrollPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [DateFrame] = []
    static func reduce(value: inout [DateFrame], nextValue: () -> [DateFrame]) {
        value.append(contentsOf: nextValue())
    }
}

struct DateFrame: Equatable {
    let date: Date
    let frame: CGRect
}

// End of file
