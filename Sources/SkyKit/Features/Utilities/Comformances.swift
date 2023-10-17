//
//  File.swift
//  
//
//  Created by Adélaïde Sky on 08/10/2023.
//

import Foundation
import SwiftUI

extension AppStorage: Equatable where Value: Equatable {
    public static func == (lhs: AppStorage, rhs: AppStorage) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}
