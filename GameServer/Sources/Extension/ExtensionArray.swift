//
//  ExtensionArray.swift
//  GameServer
//
//  Created by Nguyen Dung on 9/30/16.
//
//

import Foundation

public extension Array where Element: Equatable{
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
